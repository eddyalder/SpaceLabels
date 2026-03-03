# Space Labels V2 🚀

Space Labels V2 is a macOS utility designed for MacBook users with a hardware notch. It seamlessly extends your notch to display the name of your current Desktop (Space) and provides an interactive carousel to manage your workflow.

## Features

- **Notch Label Extension**: Displays the current desktop name to the **Left**, **Right**, or **Bottom** of the physical notch.
- **Dynamic Pill UI**: The black background of the notch physically grows and shrinks to fit your custom space name.
- **Interactive Carousel**: Hover over the physical notch area to reveal a horizontal HUD showing all active desktops with real-time snapshots.
- **Instant Desktop Switching**: Click any preview image in the carousel to instantly jump to that desktop.
- **Custom Naming**: Click the name under any preview in the carousel to rename your desktop.
- **Privacy First Snapshots**: Snapshots are only captured when you visit a desktop and are kept strictly in-memory.
- **Minimal Footprint**: Operates as a background accessory app with a lean menu bar icon for preferences.

---

## Getting Space Switching to Work

Because macOS protects desktop switching behind system shortcuts, you must enable them for the "Click to Switch" feature to function:

1. Open **System Settings** on your Mac.
2. Navigate to **Keyboard** > **Keyboard Shortcuts...**.
3. Select **Mission Control** from the left sidebar.
4. Locate the list of **"Switch to Desktop 1"**, **"Switch to Desktop 2"**, etc.
5. **Enable the checkboxes** for the desktops you use (e.g., Desktops 1-9).
   - *Note: Space Labels V2 simulates the `Control + [Digit]` shortcut to navigate. Ensure these shortcuts are assigned to those keys.*

---

## Usage Guide

### Expanding & Collapsing the Notch
- **Expand**: If the notch is collapsed (standard size), **Click the central notch area** to reveal your desktop name label.
- **Collapse**: To hide your desktop name and return to a standard notch look, **Click the extended label area** (where the text is).

### Using the Carousel
- **Reveal**: Move your mouse pointer directly over the **physical hardware notch** (center top of screen). The carousel will smoothly animate down.
- **Dismiss**: Move your mouse away from the carousel and notch area.
- **Switching**: Click any **Snapshot Image** to switch to that space.
- **Renaming**: Click the **Text Label** below a snapshot, type a new name, and press `Enter`. Press `Esc` to cancel.

### Settings
- Click the **Gear Icon** in the top-right corner of the carousel modal to change the notch extension position (**Left**, **Right**, or **Bottom**).
- Access the **Menu Bar Icon** (Small window symbol) to open Preferences or Quit the app.

---

## Technical Details
- **APIs**: Uses `ScreenCaptureKit` for high-performance, secure snapshots.
- **Events**: Uses HID-level `CGEvent` simulation for instantaneous desktop switching.
- **UI**: Built entirely with **SwiftUI** and native **AppKit** window management for a cohesive macOS experience.
