local function run(command)
    local p = io.popen(command)
    p:close()
end

local function run_with_output(command)
    local p = io.popen(command)
    local out = p:read("*l")
    p:close()
    return out
end

local cmd = "pactl"
local default_sink = run_with_output(cmd .. " get-default-sink")
local Pulseaudio = {}

function Pulseaudio:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Pulseaudio:get_state()
    -- update volume state
    local vol
    while not vol do
        vol = run_with_output(cmd .. " get-sink-volume " .. default_sink)
    end
    self.volume = tonumber(string.match(vol, "front%-left: %d+ /%s+(%d+)"))

    -- update mute state
    local mute = run_with_output(cmd .. " get-sink-mute " .. default_sink)
    self.mute = mute == "Mute: yes"
end

-- Sets the volume of the default sink to vol from 0 to 100%
function Pulseaudio:set_volume(vol)
    vol = math.max(0, math.min(100, vol))
    run(string.format("%s set-sink-volume %s %d%%", cmd, default_sink, vol))
    self.volume = vol
end

-- Toggles the mute flag of the default sink.
function Pulseaudio:toggle_mute()
    run(cmd .. " set-sink-mute " .. default_sink .. " 'toggle'")
    self.mute = not self.mute
end

return Pulseaudio
