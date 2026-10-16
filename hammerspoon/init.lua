require("hs.ipc")

local abcSource = "com.apple.keylayout.ABC"
local lastFire = 0

local function ensureABCIfCaps()
    if hs.hid.capslock.get() and hs.keycodes.currentSourceID() ~= abcSource then
        hs.keycodes.currentSourceID(abcSource)
    end
end

hs.hotkey.bind({"shift"}, "f19", function()
    local now = hs.timer.secondsSinceEpoch()
    if now - lastFire < 0.2 then return end  -- 200ms debounce
    lastFire = now

    hs.hid.capslock.set(not hs.hid.capslock.get())
    ensureABCIfCaps()
end)

-- Force ABC input source while Caps Lock is on (kept in a global variable to prevent Lua GC)
if InputSourceWatcher then
    InputSourceWatcher:stop()
end
InputSourceWatcher = hs.distributednotifications.new(
    ensureABCIfCaps,
    "com.apple.Carbon.TISNotifySelectedKeyboardInputSourceChanged"
):start()
