-- Copyright 2013 mokasin
-- Copyright 2016 monkoose
-- This file is part of the Awesome Pulseaudio Widget (APW).
--
-- APW is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- APW is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with APW. If not, see <http://www.gnu.org/licenses/>.

-- Configuration variables
local theme = require("../themes/boa/theme")
local mixer = 'pavucontrol' -- mixer command
local step = 0.166
-- End of configuration

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local pulseaudio = require("apw.pulseaudio")
beautiful.init("~/.config/awesome/themes/boa/theme.lua")
local spawn_with_shell = awful.util.spawn_with_shell or awful.spawn.with_shell

local p = pulseaudio:Create()

local pulseWidget = wibox.widget.imagebox()

local function _update()
    if p.Mute then
        pulseWidget:set_image(theme.volume000m)
    else
        if p.Volume >= 0.99 then
            pulseWidget:set_image(theme.volume1000)
        elseif p.Volume > 0.8 then
            pulseWidget:set_image(theme.volume833)
        elseif p.Volume > 0.6 then
            pulseWidget:set_image(theme.volume667)
        elseif p.Volume > 0.4 then
            pulseWidget:set_image(theme.volume500)
        elseif p.Volume > 0.2 then
            pulseWidget:set_image(theme.volume333)
        elseif p.Volume > 0.05 then
            pulseWidget:set_image(theme.volume167)
        else
            pulseWidget:set_image(theme.volume000)
        end
    end
end

function pulseWidget.SetMixer(command)
    mixer = command
end

function pulseWidget.Up()
    p:SetVolume(p.Volume + step)
    _update()
end

function pulseWidget.Down()
    p:SetVolume(p.Volume - step)
    _update()
end


function pulseWidget.ToggleMute()
    p:ToggleMute()
    _update()
end

function pulseWidget.Update()
    p:UpdateState()
    _update()
end

function pulseWidget.LaunchMixer()
    spawn_with_shell( mixer )
end


-- register mouse button actions
pulseWidget:buttons(awful.util.table.join(
        awful.button({ }, 1, pulseWidget.ToggleMute),
        awful.button({ }, 3, pulseWidget.LaunchMixer),
        awful.button({ }, 4, pulseWidget.Up),
        awful.button({ }, 5, pulseWidget.Down)
    )
)

pulseWidget.pulse = p

-- initialize
_update()

return pulseWidget
