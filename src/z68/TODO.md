# Z68 TODO

Keep this visible: interactive V3 play works, but the interpreter is unfinished.
Zork can open the mailbox/read the leaflet; Deadline processes LOOK. QUIT and
confirmation work. CZECH passes 349 automatic checks; 19 print checks remain
visual checks, not automatic conformance claims.

## Recent improvements

- [x] Use both reserved 252-byte cache slots with two-slot LRU replacement.
- [x] Replace repeated subtraction on cache misses with a bounded 17-bit divider.
- [x] Measure the change in modeled CPU cycles and indexed story-sector reads:
  OPEN MAILBOX uses 35% fewer cycles; Deadline LOOK uses 28% fewer. See the
  performance notes in README.md. These are emulator measurements, not board
  timings; the initial loader/indexing pause remains separate work.

## Next useful work

- [ ] Reduce the initial loading pause: profile the per-byte FMS dynamic loader
  and full file-chain indexing separately. Consider bulk payload copies while
  preserving binary mode, header copying, file position, bounds and chain checks.
- [ ] Add a MORE prompt for long output on the 23-row VT100 story area, without
  losing the status row or cursor position.
- [ ] Make terminal width/height configurable; use the selected width for word
  wrapping. Keep a usable plain-terminal mode.
- [ ] Improve input editing across wrapped terminal rows (backspace/DEL).
- [ ] Implement RESTART with a fresh writable-story image, initial PC, empty
  frames/stack, refreshed header capabilities and correct terminal state.
- [ ] Implement V3 SPLIT_WINDOW / SET_WINDOW when a story needs them. The VT100
  status row is not the Z-machine upper window; keep those concepts separate.
- [ ] Expand command-level regressions: multi-turn exploration, movement,
  inventory, objects, unknown words, punctuation and repeated empty input.
- [ ] Exercise more locally supplied V3 stories and preserve small synthetic
  regressions for any bugs they expose.
- [ ] Test on the physical C68 with its serial terminal, including sustained
  output, disk failures, RAM/stack guards and terminal cleanup after errors.

## Deliberately deferred

These are reminders, not requirements for the current round of work.

- [ ] SAVE / RESTORE (including a file format, FLEX file ownership, error paths
  and restoring the complete VM state). No persistence yet; QUIT does work.
- [ ] Transcript/log-file output and OUTPUT_STREAM control.
- [ ] Command recording/replay and INPUT_STREAM control.
- [ ] SOUND_EFFECT / a simple terminal bell policy.
- [ ] Extended ZSCII characters/transliteration beyond the current ASCII subset.
- [ ] RTC/timer-backed entropy once the hardware is available; the current
  random source uses FLEX date and console polling, not a wall clock.
- [ ] V1/V2 story compatibility. V4+ remains outside the intended scope.

## Storage layout and removable media

- [x] Consolidate SRAM into drives 0/1 (512 KiB each): system/BASIC on 0,
  games/stories/user files on 1.
- [ ] Add a removable backend on logical drive 2. See
  [the FLEX dispatch and boot plan](../flex2/REMOVABLE.md) for driver vectors,
  bridge protocol requirements, media changes and boot-device handoff.
- [ ] Boot from either SRAM or removable media; the existing bootstrap reads
  SRAM drive 0 directly and needs a separate transport or ROM block service.

## Guardrails for further changes

- Recalculate the full RAM layout as code grows. Keep code, dynamic memory,
  index/cache and both stacks below FLEX's memory ceiling; do not silently borrow
  SRAM disk pages. The spare window bank is a future escape hatch, not allocated
  RAM today.
- Keep malformed-file and disk-chain rejection when optimizing I/O. A cache
  hit must preserve story address semantics; writes still target dynamic RAM.
- Run `make -C flex2 test` from this directory's parent (`src`), or `make test`
  here. Keep CZECH automatic checks distinct from manual print checks.
- Stop the emulator before replacing its working image. `LIST 0.BUILD.TXT`
  identifies the loaded build; use a separate session image for mutable disks.
