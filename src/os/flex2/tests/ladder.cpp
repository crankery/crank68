#include "flex_harness.h"
#include <functional>
#include <cstdlib>

int main(int argc, char **argv) {
    try {
        require(argc == 3, "usage: ladder-test BIN LIST");
        Bus bus;
        Cpu cpu(bus);
        auto system = file("build/c68flex.bin");
        std::copy(system.begin(), system.end(), bus.ram.begin() + 0xA100);
        auto game = file(argv[1]);
        require(game.size() < 0x7B00, "game too large");
        std::copy(game.begin(), game.end(), bus.ram.begin() + 0x0300);
        call(bus,cpu,0xb400,0);
        cpu.s_.pc = 0x0300;
        cpu.s_.sp = 0x9FFD;
        auto address = [&](const char *name) { return symbol(argv[2], name); };
        auto game_loop = address("game_loop");
        auto x = address("player_x"), y = address("player_y");
        auto direction = address("direction"), jump = address("jump_step");
        auto level = address("level_number"), lives = address("lives");
        auto won = address("won_level");
        auto score = address("score");
        auto points = [&]{ return (bus.ram[score] << 8) | bus.ram[score + 1]; };
        auto run_until = [&](std::function<bool()> predicate, unsigned limit=20000000) {
            for (unsigned i=0; i<limit; ++i) {
                if (predicate()) return;
                cpu.step();
            }
            throw std::runtime_error("timed out at PC="+std::to_string(cpu.s_.pc)+
                " game="+std::to_string(cpu.s_.pc==game_loop)+
                " fcb_err="+std::to_string(bus.ram[address("score_fcb")+1])+" out="+std::to_string(bus.output.size()));
        };
        if (!std::getenv("LADDER_SCORE_ONLY")) {
        bus.input = 'p';
        run_until([&]{ return cpu.s_.pc == game_loop; });
        require(bus.output.find("LLLLLLLL") != std::string::npos, "start logo absent");
        require(bus.output.find("1-7 = Practice from that level") != std::string::npos,
                "level choices absent from menu");
        require(bus.ram[address("highscore_eligible")] == 1,
                "P start should qualify for high scores");
        require(bus.output.find("Q = Quit to FLEX") != std::string::npos,
                "menu does not show Q as the FLEX exit key");
        require(bus.output.find("Easy Street") != std::string::npos, "map/status absent");
        require(bus.output.find("\x1b[2J") != std::string::npos, "screen not cleared");
        require(bus.output.find("\x1b[19;6Hg") != std::string::npos, "Lad not at start");
        require(bus.output.find("\x1b[21;30HScore: 00000") != std::string::npos &&
                    bus.output.find("\x1b[21;64HLads: 5") != std::string::npos,
                "score and Lads were not displayed on the board status line");
        const auto board_clear = bus.output.rfind("\x1b[2J");
        require(bus.output.find("h/j/k/l or WASD move", board_clear)
                    == std::string::npos,
                "movement help remained on the board status line");
        require(bus.ram[x] == 6 && bus.ram[y] == 19, "wrong start");
        bus.ram[x] = 17;
        bus.ram[y] = 8;
        bus.ram[direction] = 4;
        run_until([&]{ return points() == 35 &&
                              bus.output.find("Score: 00035") != std::string::npos; });
        const auto statue = address("level_map") + 8 * 79 + 16;
        require(bus.ram[statue] == ' ', "collected statue was not removed");
        bus.ram[x] = 6;
        bus.ram[y] = 19;
        bus.ram[direction] = 0;
        bus.input = 'l';
        run_until([&]{ return bus.ram[x] == 7; });
        require(bus.ram[y] == 19, "walking fell through floor");
        bus.input = 'x';
        run_until([&]{ return bus.ram[direction] == 0 && bus.input < 0; });
        bus.ram[x] = 58;
        bus.ram[y] = 19;
        bus.input = 'k';
        run_until([&]{ return bus.ram[y] == 18; });
        require(bus.ram[x] == 58, "climb shifted column");
        bus.ram[direction] = 0;
        bus.ram[x] = 6;
        bus.ram[y] = 19;
        bus.input = ' ';
        run_until([&]{ return bus.ram[jump] != 0 && bus.ram[y] == 18; });
        require(bus.ram[x] == 6, "standing jump shifted column");
        bus.ram[x] = 58;
        bus.ram[y] = 2;
        bus.ram[jump] = 0;
        bus.ram[direction] = 3;
        run_until([&]{ return bus.ram[level] == 2 && cpu.s_.pc == game_loop; });
        require(bus.output.find("Hooka!") != std::string::npos,
                "treasure did not flash Hooka!");
        require(bus.output.find("Long Island") != std::string::npos,
                "Long Island board was not drawn");
        require(bus.ram[x] == 18 && bus.ram[y] == 19,
                "Long Island did not start at its player marker");
        require(bus.ram[lives] == 5, "treasure reset remaining lives");
        require(points() == 70 &&
                    bus.output.find("Score: 00070") != std::string::npos,
                "Easy Street treasure did not add its bonus to score");
        bus.ram[score] = 0x03;
        bus.ram[score + 1] = 0xE3;  // 995, to exercise the thousands digit.
        bus.ram[x] = 75;
        bus.ram[y] = 2;
        bus.ram[direction] = 3;
        run_until([&]{ return bus.ram[level] == 3 && cpu.s_.pc == game_loop; });
        require(bus.output.find("Ghost Town") != std::string::npos,
                "second treasure did not draw Ghost Town");
        require(bus.ram[x] == 6 && bus.ram[y] == 3,
                "Ghost Town did not start at its player marker");
        require(points() == 1040 &&
                    bus.output.find("Score: 01040") != std::string::npos,
                "Long Island treasure did not display a four-digit score");
        const auto menu_redraw = bus.output.size();
        bus.input = 'q';
        run_until([&]{ return cpu.s_.pc == address("menu_wait") &&
                              bus.output.find("1-7 = Practice from that level", menu_redraw)
                                  != std::string::npos; });
        require(bus.output.find("\x1b[?25h") == std::string::npos,
                "Q exited Ladder instead of opening the menu");
        bus.input = '1';
        run_until([&]{ return cpu.s_.pc == game_loop && bus.ram[level] == 1; });
        require(bus.ram[address("highscore_eligible")] == 0,
                "numeric level start should be practice only");
        require(points() == 0 && bus.ram[statue] == '&',
                "new game did not reset score and statue");
        const auto second_menu = bus.output.size();
        bus.input = 'q';
        run_until([&]{ return cpu.s_.pc == address("menu_wait") &&
                              bus.output.find("1-7 = Practice from that level", second_menu)
                                  != std::string::npos; });
        bus.input = 'q';
        run_until([&]{ return bus.output.find("\x1b[?25h") != std::string::npos; });

        struct Board { const char *name, *map; int x, y, rocks, bonus; };
        const Board boards[] = {
            {"Easy Street", "level_map", 6, 19, 5, 35},
            {"Long Island", "long_island_map", 18, 19, 8, 45},
            {"Ghost Town", "ghost_town_map", 6, 3, 5, 35},
            {"Tunnel Vision", "tunnel_vision_map", 77, 17, 5, 36},
            {"Point of No Return", "point_of_no_return_map", 74, 4, 7, 35},
            {"Bug City", "bug_city_map", 34, 9, 6, 37},
            {"GangLand", "gangland_map", 7, 3, 6, 32},
        };
        auto active_map = address("active_map"), rock_limit = address("rock_limit");
        for (int index = 0; index < 7; ++index) {
            Bus practice;
            Cpu player(practice);
            std::copy(system.begin(), system.end(), practice.ram.begin() + 0xA100);
            std::copy(game.begin(), game.end(), practice.ram.begin() + 0x0300);
            call(practice,player,0xb400,0);
            player.s_.pc = 0x0300;
            player.s_.sp = 0x9FFD;
            practice.input = '1' + index;
            bool started = false;
            for (unsigned steps = 0; steps < 3000000; ++steps) {
                if (player.s_.pc == game_loop) { started = true; break; }
                player.step();
            }
            require(started, "numeric menu choice did not start the game");
            require(practice.ram[address("highscore_eligible")] == 0,
                    "practice start was high score eligible");
            const auto &board = boards[index];
            require(practice.ram[level] == index + 1, "wrong board number");
            require(practice.ram[x] == board.x && practice.ram[y] == board.y,
                    "board did not start at its player marker");
            require(practice.ram[rock_limit] == board.rocks, "wrong rock limit");
            require(practice.ram[address("bonus_points")] == board.bonus,
                    "wrong board bonus");
            require(practice.output.find(board.name) != std::string::npos,
                    "board name was not drawn");
            const int map_address = (practice.ram[active_map] << 8) |
                                    practice.ram[active_map + 1];
            require(map_address == address(board.map), "wrong playfield selected");
            if (index == 1) {
                // The sixth Long Island rock must be visible, then harmless
                // once the eater has made its slot inactive.
                const auto slots = address("rock_slots");
                const auto sixth = slots + 5 * 3;
                practice.ram[address("rock_count")] = 8;
                practice.ram[sixth] = 27;
                practice.ram[sixth + 1] = 19;
                practice.ram[sixth + 2] = 4;
                practice.ram[x] = 29;
                practice.ram[y] = 19;
                const auto before_rock = practice.output.size();
                bool eaten = false;
                for (unsigned steps = 0; steps < 3000000; ++steps) {
                    if (practice.ram[sixth + 2] == 0 && player.s_.pc == game_loop) {
                        eaten = true;
                        break;
                    }
                    player.step();
                }
                require(eaten, "Long Island eater did not retire the sixth rock");
                require(practice.output.find("\x1b[19;28Ho", before_rock)
                            != std::string::npos,
                        "sixth rock was invisible at the eater");
                practice.ram[x] = 28;
                player.step();
                for (unsigned steps = 0; steps < 3000000 && player.s_.pc != game_loop;
                     ++steps) player.step();
                require(player.s_.pc == game_loop && practice.ram[lives] == 5 &&
                            practice.ram[address("death_flag")] == 0,
                        "inactive eaten rock killed Lad");
                practice.ram[sixth] = 28;
                practice.ram[sixth + 1] = 19;
                practice.ram[sixth + 2] = 4;
                practice.ram[address("rock_count")] = 8;
                bool contact = false;
                for (unsigned steps = 0; steps < 3000000; ++steps) {
                    if (player.s_.pc == address("game_restart")) {
                        contact = true;
                        break;
                    }
                    player.step();
                }
                require(contact, "active sixth rock did not collide with Lad");
            }
            if (index == 6) {
                practice.ram[x] = 34;
                practice.ram[y] = 19;
                practice.ram[direction] = 3;
                bool finished = false;
                for (unsigned steps = 0; steps < 3000000; ++steps) {
                    if (practice.ram[won] == 1 &&
                        practice.output.find("You found the treasure!") != std::string::npos) {
                        finished = true;
                        break;
                    }
                    player.step();
                }
                require(finished, "seventh treasure did not finish the game");
            }
        }
        }
        // A first score creates LADDER.HIS on the command's drive; a later
        // score updates it. Reopen from a fresh game image to prove persistence.
        Bus scores;
        Cpu scorer(scores);
        std::copy(system.begin(), system.end(), scores.ram.begin() + 0xA100);
        std::copy(game.begin(), game.end(), scores.ram.begin() + 0x0300);
        call(scores,scorer,0xb400,0);
        scores.ram[0xa843]=1;
        scores.ram[address("score_drive")]=1;
        scores.ram[0xac0e]=11;
        scores.ram[0xac0f]=22;
        scores.ram[0xac10]=26;
        auto saved = address("top_scores");
        scores.ram[score]=0x04; scores.ram[score+1]=0xd2;
        auto before_practice = scores.output.size();
        call(scores,scorer,address("highscore_finish"),0);
        require(scores.output.size()==before_practice && scores.ram[saved]==0,
                "practice score prompted for a name or entered the table");
        scores.ram[address("highscore_eligible")]=1;
        scores.input=13;
        call(scores,scorer,address("highscore_finish"),0);
        require(scores.output.find("Could not save") == std::string::npos,
                "first high score save failed");
        std::fill_n(scores.ram.begin()+saved,80,0);
        call(scores,scorer,address("highscore_init"),0);
        require(scores.ram[saved]==0x04 && scores.ram[saved+1]==0xd2 &&
                    scores.ram[saved+2]==11 && scores.ram[saved+3]==22 &&
                    scores.ram[saved+4]==26 && scores.ram[saved+5]=='L',
                "first high score was not reloaded");
        scores.ram[score]=0x09; scores.ram[score+1]=0x29;
        scores.input=13;
        call(scores,scorer,address("highscore_finish"),0);
        require(scores.output.find("Could not save") == std::string::npos,
                "high score update failed");
        std::fill_n(scores.ram.begin()+saved,80,0);
        call(scores,scorer,address("highscore_init"),0);
        require(scores.ram[saved]==0x09 && scores.ram[saved+1]==0x29 &&
                    scores.ram[saved+16]==0x04 && scores.ram[saved+17]==0xd2,
                "updated high scores were not reloaded in rank order");
        std::cout << "LADDER: high score file create, reload and update passed";
        if (!std::getenv("LADDER_SCORE_ONLY"))
            std::cout << "; seven starts, Q menu/FLEX, Long Island eater and final treasure passed";
        std::cout << ".\n";
        return 0;
    } catch (const std::exception &e) {
        std::cerr << e.what() << "\n";
        return 1;
    }
}
