#include "tcpConsole.h"

#include <algorithm>
#include <cerrno>
#include <cstring>
#include <stdexcept>
#include <string>
#include <fcntl.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <sys/socket.h>
#include <unistd.h>

namespace {
bool would_block() { return errno == EAGAIN || errno == EWOULDBLOCK; }
void fail(const char *operation) {
    throw std::runtime_error(std::string("TCP console ")+operation+": "+std::strerror(errno));
}
void nonblocking(int fd) {
    int flags=fcntl(fd,F_GETFL,0);
    if (flags<0 || fcntl(fd,F_SETFL,flags|O_NONBLOCK)<0) fail("fcntl");
    if (fcntl(fd,F_SETFD,FD_CLOEXEC)<0) fail("close-on-exec");
}
}

TcpConsole::TcpConsole(uint16_t port) {
    listener_=socket(AF_INET,SOCK_STREAM,0);
    if (listener_<0) fail("socket");
    try {
        int yes=1;
        if (setsockopt(listener_,SOL_SOCKET,SO_REUSEADDR,&yes,sizeof(yes))<0) fail("reuse address");
        nonblocking(listener_);
        sockaddr_in address{};
        address.sin_family=AF_INET;
        address.sin_addr.s_addr=htonl(INADDR_LOOPBACK);
        address.sin_port=htons(port);
        if (bind(listener_,reinterpret_cast<sockaddr*>(&address),sizeof(address))<0) fail("bind");
        if (listen(listener_,4)<0) fail("listen");
        socklen_t length=sizeof(address);
        if (getsockname(listener_,reinterpret_cast<sockaddr*>(&address),&length)<0) fail("getsockname");
        port_=ntohs(address.sin_port);
    } catch (...) {
        close(listener_); listener_=-1;
        throw;
    }
}
TcpConsole::~TcpConsole() {
    disconnect();
    if (listener_>=0) close(listener_);
}
void TcpConsole::disconnect() {
    if (client_>=0) close(client_);
    client_=-1;
    input_.clear();
    output_.clear();
}
void TcpConsole::poll() {
    // Reject extra clients rather than letting them take over a live console.
    for (;;) {
        int fd=accept(listener_,nullptr,nullptr);
        if (fd<0) {
            if (errno==EINTR) continue;
            if (would_block()) break;
            fail("accept");
        }
        if (client_>=0) { close(fd); continue; }
        try {
            nonblocking(fd);
            int yes=1;
            if (setsockopt(fd,IPPROTO_TCP,TCP_NODELAY,&yes,sizeof(yes))<0) fail("TCP_NODELAY");
#ifdef SO_NOSIGPIPE
            if (setsockopt(fd,SOL_SOCKET,SO_NOSIGPIPE,&yes,sizeof(yes))<0) fail("SO_NOSIGPIPE");
#endif
        } catch (...) { close(fd); throw; }
        client_=fd;
    }
    if (client_<0) return;
    uint8_t buffer[4096];
    while (input_.size()<BufferLimit) {
        auto count=recv(client_,buffer,std::min(sizeof(buffer),BufferLimit-input_.size()),0);
        if (count>0) input_.insert(input_.end(),buffer,buffer+count);
        else if (count==0) { disconnect(); return; }
        else if (errno==EINTR) continue;
        else if (would_block()) break;
        else { disconnect(); return; }
    }
    while (!output_.empty()) {
        auto size=std::min(sizeof(buffer),output_.size());
        std::copy_n(output_.begin(),size,buffer);
#ifdef MSG_NOSIGNAL
        constexpr int flags=MSG_NOSIGNAL;
#else
        constexpr int flags=0;
#endif
        auto count=send(client_,buffer,size,flags);
        if (count>0) output_.erase(output_.begin(),output_.begin()+count);
        else if (count<0 && errno==EINTR) continue;
        else if (count<0 && would_block()) break;
        else { disconnect(); return; }
    }
}
std::optional<uint8_t> TcpConsole::read() {
    if (input_.empty()) return std::nullopt;
    auto value=input_.front(); input_.pop_front(); return value;
}
void TcpConsole::write(uint8_t value) {
    if (!writable()) throw std::runtime_error("TCP console output queue is full");
    output_.push_back(value);
}
