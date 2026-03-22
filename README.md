# dotfiles

## Caps Lock Remap: Reliable Caps Lock Toggle + CJK Input Method Guard

Solves two common pain points on macOS:

- **Unreliable Caps Lock**: Caps Lock and input method switching share the same key, making accidental toggles extremely common
- **CJK input while Caps Lock is on**: With Rime (Squirrel) active, Caps Lock produces uppercase CJK-encoded characters instead of plain English — so a mutual exclusion mechanism is needed

> Hard to believe that in 2026, Apple still can't get Caps Lock and CJK input method switching right — and implementing a workaround with third-party tools is absurdly complex. This repo exists so others with the same problem can find a solution.

---

### Behavior

| Action | Result |
|--------|--------|
| `Shift + Caps Lock` | Toggle Caps Lock |
| `Caps Lock` | Toggle input method (CJK / English) |
| Caps Lock turned on | Automatically switches to ABC input source |
| Manually switch to Rime while Caps Lock is on | Immediately forced back to ABC |
| Caps Lock turned off | Input source unchanged, free to switch |

---

### Dependencies

- [Karabiner-Elements](https://karabiner-elements.pqrs.org/)
- [Hammerspoon](https://www.hammerspoon.org/)

> Karabiner handles key remapping; Hammerspoon monitors state. Due to tightened permissions in macOS 26, Karabiner alone can't do the job.

---

### How It Works

macOS native Caps Lock has two issues: state synchronization is unreliable under CJK input methods, and there's no mechanism to enforce an English-only input source while Caps Lock is on.

The solution has two layers:

**Layer 1: Karabiner-Elements**

Maps `Shift + Caps Lock` to `Shift + F19`. The reason for sending `Shift + F19` rather than bare `F19`: when Karabiner handles a mandatory modifier, it temporarily lifts and restores Shift. This isolated Shift key-up/key-down gets picked up by macOS input source switching, causing an unintended input method change. Including Shift in the `to` event eliminates this issue.

**Layer 2: Hammerspoon**

Listens for `Shift + F19` and reads the actual system Caps Lock state (`hs.hid.capslock.get()`) before toggling, avoiding desync between a local variable and the real state.

Additionally, it watches for all input source changes via the native distributed notification `TISNotifySelectedKeyboardInputSourceChanged`. Whenever Caps Lock is on, it forces the input source back to ABC.

**System Settings**

Disable: Settings → Keyboard → Input Sources → "Use Caps Lock to switch to ABC input source"

---

### Installation

**1. Karabiner-Elements**

Open Karabiner-Elements → Complex Modifications → Add rule, or manually add the rule from `karabiner/shift_capslock_f19.json` into the `manipulators` array in your `~/.config/karabiner/karabiner.json`.

**2. Hammerspoon**

Copy `hammerspoon/init.lua` to `~/.hammerspoon/init.lua`, then reload with `hs.reload()`.

If you already have an `init.lua`, merge the contents in.

> If you have Claude Code, just install both tools via Homebrew and let Claude handle the config merging.

---

### File Structure

```
dotfiles/
├── hammerspoon/
│   └── init.lua                  # Hammerspoon config
└── karabiner/
    └── shift_capslock_f19.json   # Karabiner rule fragment
```
