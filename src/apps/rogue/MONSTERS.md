# Monster roster

This list comes from the bundled Rogue 3.6 source: `3.6-unix-source/init.c`
defines the 26 monsters, and `3.6-unix-source/monsters.c` gives their rough
depth order. That order is not an exact spawn level for each monster. Apart
from the stationary bat and room-roaming kobold, the choices below are a
proposed smaller roster, not implemented behavior.

The current game places one stationary bat and one room-roaming kobold per
floor. The kobold patrols after successful player steps and approaches the
player in its room. Both block movement but have no health or attack yet. The
rest of this roster remains a proposal.

The source's rough weak-to-strong glyph order is
`KJBSHEAOZGLCRQNYTWFIXUMVDP`.

## Original A–Z roster

| Glyph | Original monster | For C68 ROGUE |
| --- | --- | --- |
| A | giant ant | Later: poison and strength loss |
| B | bat | Keep: erratic movement |
| C | centaur | Keep: strong melee |
| D | dragon | Keep: rare late threat |
| E | floating eye | Later: paralysis |
| F | violet fungi | Later: holds the player |
| G | gnome | Later: overlaps with early melee foes |
| H | hobgoblin | Keep: basic early foe |
| I | invisible stalker | Later: invisibility needs more visibility rules |
| J | jackal | Later: overlaps with other early foes |
| K | kobold | Keep: weakest early foe |
| L | leprechaun | Keep: steals gold and escapes |
| M | mimic | Keep: disguises itself as loot |
| N | nymph | Later: steals inventory items |
| O | orc | Keep: tougher basic foe |
| P | purple worm | Keep: rare deepest-floor threat |
| Q | quasit | Later: another melee foe |
| R | rust monster | Keep: damages equipped armor |
| S | snake | Later: overlaps with other early foes |
| T | troll | Keep: regenerates health |
| U | umber hulk | Later: confusion needs extra controls |
| V | vampire | Later: another regenerating foe |
| W | wraith | Later: experience drain needs leveling rules |
| X | xorn | Later: another strong melee foe |
| Y | yeti | Later: another strong melee foe |
| Z | zombie | Keep: slow, sturdy melee foe |

## Proposed first roster: 12 of 26

| Stage | Monsters | What they add |
| --- | --- | --- |
| First combat slice | K kobold, H hobgoblin, O orc, Z zombie | Basic attacks and different health/damage; zombie moves less often. |
| Movement and combat variety | B bat, C centaur | Erratic movement and a stronger attacker. |
| Gold and inventory | L leprechaun, M mimic, R rust monster | Theft, disguise, and equipment damage once those systems work. |
| Deeper levels | T troll, D dragon, P purple worm | Regeneration and two rare high-risk encounters. |

Use the original names and letters, but tune hit points, damage, spawn odds,
and depth bands for a 26-floor C68 game. Do not copy the original numbers
blindly. Keep the starting room empty, cap live monsters per floor, and make
every placed monster reachable without blocking the only route to the stairs.
The dragon and purple worm should be threats, not mandatory fights.

Monster turns happen only on the active floor. If floors are later saved to
disk, store each monster's position, health, and state, then leave it frozen
while the player is elsewhere.
