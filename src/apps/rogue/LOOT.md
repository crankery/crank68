# Loot roster

The bundled Rogue 3.6 source defines the item classes and magic effects in
`3.6-unix-source/init.c`, weapon names in `weapons.c`, and glyphs in `rogue.h`.
These are the original options; the smaller C68 selection below is a proposal,
not implemented game content. The current game has gold (`*`) and an inert
starter pocket-lint item in the inventory view.

## Original item classes

| Class | Glyph | Original choices | C68 plan |
| --- | --- | --- | --- |
| Gold | `*` | Score treasure | Keep automatic pickup; no pack slot. |
| Weapons | `)` | 12 weapon types | Start with three melee weapons. |
| Armor | `]` | 8 armor types | Start with three protection tiers. |
| Potions | `!` | 14 effects | Start with healing; defer status effects. |
| Scrolls | `?` | 16 effects | Start with magic mapping. |
| Food | `:` | Rations and fruit | Defer until hunger exists. |
| Rings | `=` | 13 effects | Start with protection. |
| Wands and staves | `/` | 14 effects | Defer until targeting and charges exist. |
| Amulet of Yendor | `,` | Unique quest item | Add for the depth-26 win condition. |

Original variants, grouped by class:

- **Weapons:** mace, long sword, short bow, arrow, dagger, rock, two-handed
  sword, sling, dart, crossbow, crossbow bolt, spear.
- **Armor:** leather armor, ring mail, studded leather armor, scale mail,
  chain mail, splint mail, banded mail, plate mail.
- **Potions:** confusion, paralysis, poison, gain strength, see invisible,
  healing, monster detection, magic detection, raise level, extra healing,
  haste self, restore strength, blindness, thirst quenching.
- **Scrolls:** monster confusion, magic mapping, light, hold monster, sleep,
  enchant armor, identify, scare monster, gold detection, teleportation,
  enchant weapon, create monster, remove curse, aggravate monsters, blank paper,
  genocide.
- **Rings:** protection, add strength, sustain strength, searching, see
  invisible, adornment, aggravate monster, dexterity, increase damage,
  regeneration, slow digestion, teleportation, stealth. The original table
  spells the teleportation entry `telportation`.
- **Wands and staves:** light, striking, lightning, fire, cold, polymorph,
  magic missile, haste monster, slow monster, drain life, nothing, teleport
  away, teleport to, cancellation.

The original also has a scroll of light: it removes the current room's dark
flag without a duration. It is planned for the dark-room work item in
[TODO.md](TODO.md).

## Proposed first roster: 12 entries

| Stage | Items | Purpose |
| --- | --- | --- |
| Already present | Gold | Score and a reason to explore; auto-pickup. |
| First inventory slice | Dagger, mace, leather armor, chain mail, potion of healing | Pickup, inspect, equip, drink, and drop. |
| Equipment progression | Long sword, plate mail, potion of extra healing | Better finds deeper in the dungeon. |
| Simple magic | Scroll of magic mapping, ring of protection | Exploration and a passive defense choice. |
| Quest | Amulet of Yendor | Carry it from depth 26 back to the surface. |

Show item names and effects plainly at first. Randomized potion colors,
unidentified scroll titles, curses, enchantment bonuses, and harmful items can
come later. The player should be able to compare equipment without guessing at
hidden numbers. Keep gold and any later score treasure separate from the pack:
they have no weight and no item slot. Treat the Amulet as a unique, weightless
carried quest item, not random ordinary loot.

For ordinary items, use a small carrying-capacity budget rather than allowing
unlimited copies. Weapons and armor use more capacity than potions, scrolls,
or rings; equipped gear still counts. Show the capacity used in the inventory
view and leave an item on the floor if it would exceed the limit. Choose actual
weights and the budget by playtesting, so a useful spare weapon is possible
but a pile of swords is not. The current gold counter is only one byte; widen
it before a full 26-floor run can overflow it, and show gold in decimal on the
status line. Three bytes of packed BCD would hold six decimal digits; a wider
binary counter plus decimal conversion is another option. Choose whichever
keeps gold addition and display simpler in 6800 assembly.

Balance the 26-floor run so healing appears often enough to recover from
normal fights and useful equipment is available before late monsters appear.
Spawn items only on valid, unoccupied floor cells. If the pack is full, leave
the item on the floor and explain why pickup failed.
