# RVR - Cooldown Cleanup

![RVR - Cooldown Cleanup logo](_logo.png)

Adds utility buttons to Blizzard's Cooldown Viewer settings panel for quickly moving entire Cooldown Manager sections out of active display bars.

## Preview

<video src="_preview.mp4" controls></video>

## What It Does

When the Blizzard Cooldown Viewer settings window is open, the addon shows four buttons outside the bottom-right edge of the settings frame:

- Clear Essential
- Clear Utility
- Clear Tracked Buffs
- Clear Tracked Bars

Clicking a button moves every item in that section to Blizzard's hidden category for that item type. Essential and Utility items move to the hidden spell category. Tracked Buffs and Tracked Bars move to the hidden aura category.

The addon does not save the Cooldown Viewer layout when you click a cleanup button. After using a cleanup button, Blizzard's own settings frame remains responsible for saving or reverting the pending layout changes unless you choose Reload in the addon prompt.

## Why Reload Is Recommended

World of Warcraft 12.0.5 marks several Cooldown Viewer values as secret and untainted-sensitive. Addon-side category changes can leave Blizzard's Cooldown Viewer execution path tainted until the UI is reloaded, which may later produce errors when Blizzard refreshes spell, aura, or totem cooldown data.

For that reason, after the addon successfully moves one or more items, it shows a reload prompt. Reloading the UI through this dialog saves the Cooldown layout first, then reloads the UI to avoid taint behavior. The prompt includes:

- Reload: saves the Cooldown layout, then reloads the UI.
- Later: closes the prompt so you can keep editing and reload manually.

Use Reload when you are sure you want to keep the cleanup changes. Use Later if you want to review the layout and save or revert through Blizzard's settings frame yourself.

## Combat Behavior

The cleanup buttons are hidden and disabled while in combat. If a cleanup is attempted during combat, the addon prints a message and does not make changes.

## Notes

This addon intentionally does one narrow job: bulk-clearing Blizzard Cooldown Viewer categories. It does not replace Blizzard's settings UI, and it only saves layouts when you explicitly choose Reload in the addon prompt.
