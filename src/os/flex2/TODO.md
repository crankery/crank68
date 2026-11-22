# C68 FLEX follow-ups

- [ ] Extend `DATE.CMD` with an explicit RTC refresh option. Read the RP5C01A
      calendar at `$E070/$E071`, convert its BCD digits to binary, and update
      FLEX's month/day/year bytes at `$AC0E..$AC10`. Keep bare `DATE` display
      and manual date arguments working; handle an absent RTC gracefully.
- [ ] If automatic date refresh is wanted later, consider the `WARMS3` path
      immediately before the `+++` prompt. Decide how it should interact with
      a manually set date and commands continued from the same input line.
