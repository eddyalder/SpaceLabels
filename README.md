# Space Labels 🚀

Space Labels is a macOS utility designed for MacBook users with a hardware notch. It seamlessly extends your notch to display the name of your current Desktop (Space) and provides an interactive carousel to manage your workflow.

---

## 🛠 Installation & "First Run" Fix

Because this app is independently developed and not notarized by Apple, macOS will prevent it from running by default when downloaded from the web. Follow these steps to install:

1.  **Download and Open**: Open the `SpaceLabels.dmg` file.
2.  **Install**: Drag the `SpaceLabels` icon into the `Applications` folder.
3.  **Bypass Security Warning**: 
    *   Try to open the app from your `/Applications` folder. You will see a warning that it cannot be verified.
    *   Open **System Settings** on your Mac.
    *   Navigate to **Privacy & Security**.
    *   Scroll down to the **Security** section.
    *   You will see a message saying "`SpaceLabels` was blocked from use because it is not from an identified developer." 
    *   Click the **"Open Anyway"** button.
    *   Authenticate with your password/TouchID, and then click **Open** one last time.
    *   *Note: You only need to do this once.*

---

## 🛰 Getting Space Switching to Work

Because macOS protects desktop switching behind system shortcuts, you must enable them for the "Click to Switch" feature to function:

1. Open **System Settings** on your Mac.
2. Navigate to **Keyboard** > **Keyboard Shortcuts...**.
3. Select **Mission Control** from the left sidebar.
4. Locate the list of **"Switch to Desktop 1"**, **"Switch to Desktop 2"**, etc.
5. **Enable the checkboxes** for the desktops you use (e.g., Desktops 1-9).
   - *Note: Space Labels simulates the `Control + [Digit]` shortcut to navigate. Ensure these shortcuts are assigned to those keys.*

---

## 📖 Usage Guide

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
