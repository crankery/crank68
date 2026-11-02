#include <gtest/gtest.h>
#include <cerrno>
#include <vector>
#include <fcntl.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>
#include "terminal/tcpConsole.h"

namespace {
struct Client {
    int fd;
    explicit Client(uint16_t port) : fd(socket(AF_INET,SOCK_STREAM,0)) {
        if (fd<0) throw std::runtime_error("client socket");
        sockaddr_in address{}; address.sin_family=AF_INET;
        address.sin_addr.s_addr=htonl(INADDR_LOOPBACK); address.sin_port=htons(port);
        if (connect(fd,reinterpret_cast<sockaddr*>(&address),sizeof(address))<0) {
            close(fd); throw std::runtime_error("client connect");
        }
        fcntl(fd,F_SETFL,fcntl(fd,F_GETFL,0)|O_NONBLOCK);
    }
    ~Client() { if(fd>=0) close(fd); }
    void disconnect() { close(fd); fd=-1; }
};
void accept_client(TcpConsole &console) {
    for(unsigned n=0;n<1000 && !console.connected();++n) {console.poll();usleep(1000);}
}
}
TEST(TcpConsoleTest, BytesAreTransparentInBothDirections) {
    TcpConsole console(0);
    Client client(console.port());
    accept_client(console); ASSERT_TRUE(console.connected());
    std::vector<uint8_t> bytes;
    for(unsigned i=0;i<256;++i) bytes.push_back(i);
    ASSERT_EQ(send(client.fd,bytes.data(),bytes.size(),0),ssize_t(bytes.size()));
    std::vector<uint8_t> received;
    for(unsigned n=0;n<1000 && received.size()<bytes.size();++n) {
        console.poll();
        while(auto value=console.read()) received.push_back(*value);
        if(received.size()<bytes.size()) usleep(1000);
    }
    EXPECT_EQ(received,bytes); // includes both cases, Ctrl-], NUL, ESC and FF
    for(auto value:bytes) console.write(value);
    received.clear();
    for(unsigned n=0;n<1000 && received.size()<bytes.size();++n) {
        console.poll(); uint8_t data[512]; auto count=recv(client.fd,data,sizeof(data),0);
        if(count>0) received.insert(received.end(),data,data+count);
        else usleep(1000);
    }
    EXPECT_EQ(received,bytes);
}
TEST(TcpConsoleTest, DisconnectAndReconnectWithoutReplacingLiveClient) {
    TcpConsole console(0);
    Client first(console.port()); accept_client(console); ASSERT_TRUE(console.connected());
    Client extra(console.port()); console.poll();
    uint8_t byte=0;
    ssize_t closed=-1;
    for(unsigned n=0;n<1000;++n) {
        closed=recv(extra.fd,&byte,1,0);
        if(closed==0) break;
        usleep(1000);
    }
    EXPECT_EQ(closed,0);
    first.disconnect();
    for(unsigned n=0;n<1000 && console.connected();++n) {console.poll();usleep(1000);}
    ASSERT_FALSE(console.connected());
    Client next(console.port()); accept_client(console); ASSERT_TRUE(console.connected());
    byte='x'; ASSERT_EQ(send(next.fd,&byte,1,0),1);
    for(unsigned n=0;n<1000;++n) {
        console.poll();
        if(auto value=console.read()) {EXPECT_EQ(*value,'x');return;}
        usleep(1000);
    }
    FAIL()<<"Reconnect did not deliver input";
}
TEST(TcpConsoleTest, QueuedOutputIsBoundedAndDrainedWithoutLosingBytes) {
    TcpConsole console(0); Client client(console.port()); console.poll();
    for(size_t i=0;i<TcpConsole::BufferLimit;++i) console.write(uint8_t(i));
    EXPECT_FALSE(console.writable());
    EXPECT_THROW(console.write(0),std::runtime_error);
    std::vector<uint8_t> received;
    for(unsigned n=0;n<2000 && received.size()<TcpConsole::BufferLimit;++n) {
        console.poll(); uint8_t data[4096]; auto count=recv(client.fd,data,sizeof(data),0);
        if(count>0) received.insert(received.end(),data,data+count);
        else usleep(1000);
    }
    ASSERT_EQ(received.size(),TcpConsole::BufferLimit);
    for(size_t i=0;i<received.size();++i) ASSERT_EQ(received[i],uint8_t(i));
    EXPECT_TRUE(console.writable());
}
TEST(TcpConsoleTest, OccupiedPortFailsCleanly) {
    TcpConsole console(0);
    EXPECT_THROW(TcpConsole duplicate(console.port()),std::runtime_error);
}
