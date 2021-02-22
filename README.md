
Patch enables quicksave to save to separate slots.


Gothic INI Entries from this Patch:

```ini
# Main Section, defines Slots and other options
[NINJA_QUICKSAVESLOTS]
Enabled=1
# List of slots that will be used
# Slot '0' is the Quicksave slot (only G2)
Slots=16,17,18,19,20,0
# Set numbered slot-names (e.g. 1, 2, ..., 152)
UseNumbering=1

# Per-Game Section. Stores total and current slots per mod
[NINJA_QUICKSAVESLOTS_PER_GAME]
# Total number of saves for that mod. Used with "UseNumbering"
GOTHICGAME_total=5
# Current Slot in the list of slots that will be used next
GOTHICGAME_curSlot=5
```

Gothic 1 has 15 slots while Gothic 2 has 20 slots + Quickslot available.
