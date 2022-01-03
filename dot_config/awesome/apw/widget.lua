local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local Pulseaudio = require("apw.pulseaudio")

local mixer = 'pavucontrol'
local step = 5

local p = Pulseaudio:new()
p:get_state()

local pulsewidget = wibox.widget {
    max_value     = 100,
    forced_height = 10,
    margins = { left = 5, right = 5 },
    shape = gears.shape.rounded_bar,
    widget = wibox.widget.progressbar,
}

local function _update()
    pulsewidget:set_value(p.volume)
end

local function _colorize()
    if p.mute then
        pulsewidget.color = '#9e3d3d'
        pulsewidget.background_color = '#222222'
    else
        pulsewidget.color = '#9e7e3d'
        pulsewidget.background_color = '#444444'
    end
end

function pulsewidget.up()
    p:set_volume(p.volume + step)
    _update()
end

function pulsewidget.down()
    p:set_volume(p.volume - step)
    _update()
end

function pulsewidget.toggle_mute()
    p:toggle_mute()
    _colorize()
end

function pulsewidget.lauch_mixer()
    awful.util.spawn_with_shell(mixer)
end


-- register mouse button actions
pulsewidget:buttons(awful.util.table.join(
        awful.button({}, 1, pulsewidget.toggle_mute),
        awful.button({}, 3, pulsewidget.lauch_mixer),
        awful.button({}, 4, pulsewidget.up),
        awful.button({}, 5, pulsewidget.down)
    )
)

pulsewidget.pulse = p

-- initialize
_update()
_colorize()

return pulsewidget
