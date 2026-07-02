# RVR - Cooldown Cleanup

Adds utility buttons to Blizzard's Cooldown Viewer settings panel for quickly moving entire Cooldown Manager sections out of active display bars.

## What It Does

When the Blizzard Cooldown Viewer settings window is open, the addon shows four buttons outside the bottom-right edge of the settings frame:

- Clear Essential
- Clear Utility
- Clear Tracked Buffs
- Clear Tracked Bars

Clicking a button moves every item in that section to Blizzard's hidden category for that item type. Essential and Utility items move to the hidden spell category. Tracked Buffs and Tracked Bars move to the hidden aura category.

The addon does not automatically save the Cooldown Viewer layout. After using a cleanup button, Blizzard's own settings frame remains responsible for saving or reverting the pending layout changes. This lets you review the result and revert if needed.

## Why Reload Is Recommended

World of Warcraft 12.0.5 marks several Cooldown Viewer values as secret and untainted-sensitive. Addon-side category changes can leave Blizzard's Cooldown Viewer execution path tainted until the UI is reloaded, which may later produce errors when Blizzard refreshes spell, aura, or totem cooldown data.

For that reason, after the addon successfully moves one or more items, it shows a reload prompt. Reloading immediately after the cleanup applies the change cleanly and avoids leaving the tainted state active during normal gameplay. Or cancel and reload when done editing and saving the CDM.

## Combat Behavior

The cleanup buttons are hidden and disabled while in combat. If a cleanup is attempted during combat, the addon prints a message and does not make changes.

## Notes

This addon intentionally does one narrow job: bulk-clearing Blizzard Cooldown Viewer categories. It does not replace Blizzard's settings UI, and does not automatically save layouts.
