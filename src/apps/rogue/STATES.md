# Conditions and timed effects

The bundled Rogue 3.6 source uses hunger counters, actor flags, temporary
timers, and changed attributes. They are different kinds of state. The table
below records the original behavior and a possible order for adding it to C68
ROGUE. None of these conditions is implemented in the current game.

| Condition | Rogue 3.6 behavior | C68 plan |
| --- | --- | --- |
| Hungry → weak → fainting | Food runs down with turns; at zero, the player can lose turns to fainting. | Later, after food pickup and eating work. |
| Confused | Movement can go in an unintended direction for a limited time. | Later; show it visibly and give it a clear expiry. |
| Blind | Severely restricts what the player can see until sight returns. | Later, once visibility rules are stable. |
| Held | Violet fungi can stop the player from moving. | Later; killing or escaping the holder must release the player. |
| Asleep or paralyzed | The player loses a number of turns after traps, scrolls, or potions. | Later, with a clear countdown and combat balance. |
| Trapped | A bear trap blocks movement for several turns. | Later, when traps are added. |
| Hasted | The player gets extra actions for a limited time. | Later; define the turn order before adding it. |
| See invisible | Temporarily or through a ring, reveals invisible monsters. | Later, alongside invisible monsters. |
| Strength reduced | Poison, ants, or darts lower the strength attribute; restoration can reverse it. | Later, if strength becomes a useful combat stat. |
| Regenerating | A ring restores player health; some monsters regenerate. | Monster regeneration comes with trolls; player regeneration can wait. |
| Cursed equipment | A property of worn items that prevents easy removal. | Later; keep it on the item, not in the player's condition flags. |

**Poisoned over time is an addition we may choose for C68 ROGUE, not a direct
copy of Rogue 3.6.** In the bundled source, a poison potion causes immediate
strength loss, while the poisoned bite of a giant ant can also reduce strength.
If we add ongoing poison damage, it needs a duration, a visible indicator, and
a reliable cure before it appears in random loot or monster attacks.

Monsters can also be invisible, confused, held, hasted, slowed, regenerating,
or magically cancelled in the original source. We can add these only when a
chosen monster or item needs them; they do not all need a first implementation.
Dark rooms are a property of the map, not a player condition.

## Implementation rules for later

- Count durations in game turns, never wall-clock time. Decide whether a
  blocked move, item use, or menu view spends a turn before adding effects.
- Show active harmful conditions near health or in the message area, and say
  when they begin and end. Do not hide a loss of control from the player.
- Decide how repeated doses combine (refresh, extend, or do nothing) for each
  condition, with a fixed cap where needed.
- Carry player conditions between floors. Monsters on inactive floors remain
  frozen, including their condition timers, until that floor is active again.
- Add one condition at a time with tests for expiry, cure, floor transition,
  death, and its interaction with inventory or combat.
