# Level-one display capture

The one-key iz-cpm run in [KEY_TRACE.md](KEY_TRACE.md) also saved iz-cpm's
ADM-3A-to-ANSI terminal output. `right-run.ansi.gz` is that byte stream.
It is separate from the CPU call trace: the trace records runtime transfers,
while this stream records what the game actually drew.

`tools/replay_ladder.py` interprets cursor addressing, clear-screen
commands, carriage returns, and line feeds on an 80-by-24 grid. The text
captures below contain the reconstructed character cells. The replayer can
also render optional PNGs using a bitmap font supplied with `--font`.

| Frame | Lad `p` at row, column | What is visible |
| --- | ---: | --- |
| [Early](right-early.txt) | 19, 13 | Beginning of the rightward run |
| [Middle](right-middle.txt) | 19, 46 | Lad and moving `o` hazards |
| [Edge](right-edge.txt) | 19, 79 | Far right edge, with hazards in new positions |

Only one ASCII `6` was injected at the first level-one poll. The game keeps
that direction, so the lad traversed the bottom row without further keys.
After reaching column 79, he stayed at the edge; the run later recorded a
lost life. This capture gives us a baseline for timed direction changes.

Regenerate the frames from the saved output with Python 3:

```sh
python3 ../tools/replay_ladder.py right-run.ansi.gz /tmp/ladder-frames \
  --every 100 --select move-100,move-500,move-900
```

The selected frame labels count ANSI cursor-address commands, not CPU cycles
or game ticks. The replayer can save any interval using `--every` and can
export all frames by omitting `--select`.

The next run [climbed the ladder at column 58](CLIMB_CAPTURE.md).
