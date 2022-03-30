-- Imports {{{
local awful = require("awful")
local gears = require("gears")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local apw = require("apw/widget")
local theme = require("themes/boa/theme")
-- }}}
-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification({
        urgency = "critical",
        title = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message
    })
end)
-- }}}
-- Variable definitions {{{
-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/themes/boa/theme.lua")

-- This is used later as default programs.
local filemanager = "pcmanfm"
local rofi = "rofi -show run"
local rofi_win = "rofi -show window"
local terminal = "kitty"
local browser = "opera" or os.getenv("BROWSER")
local reboot = "sh -c \"reboot\""
local poweroff = "sh -c \"poweroff\""
local screenshot = "mkdir -p ~/Pictures/screenshots; " ..
                   "scrot '%Y-%m-%d_%H:%M:%S.png' -e 'mv $f ~/Pictures/screenshots/ 2>/dev/null'"

-- Default modkey.
local modkey = "Mod4"

awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.floating,
}
-- }}}
-- Menu {{{
local mymainmenu = awful.menu({
    items = {
        { "browser", browser },
        { "terminal", terminal },
        { "filemanager", filemanager },
        { "refresh", awesome.restart },
        { "reboot", reboot },
        { "poweroff", poweroff }
    }
})
-- }}}
-- Wibox {{{
-- battery widget
local batterywidget = wibox.widget({
    align = "center",
    widget = wibox.widget.textbox
})

local function getBatteryCapacity()
    local cap = io.popen("cat /sys/class/power_supply/BAT0/capacity", "r")
    batterywidget.text = cap:read("*l")
    cap:close()
end

getBatteryCapacity()
local batterywidgettimer = gears.timer({ timeout = 30 })
batterywidgettimer:connect_signal("timeout", getBatteryCapacity)
batterywidgettimer:start()

-- Clock
local separator_clock = wibox.widget.separator({
    layout = wibox.layout.fixed.vertical,
    forced_height = 5,
})

local hours = wibox.widget({
    format = "%H",
    font = theme.clockhour,
    align = "center",
    refresh = 60,
    widget = wibox.widget.textclock
})

local minutes = wibox.widget({
    format = "%M",
    font = theme.clockminute,
    align = "center",
    refresh = 60,
    widget = wibox.widget.textclock
})

local myclock_t = awful.tooltip({
    objects = { hours, minutes, separator_clock },
    timer_function = function()
        return os.date('%A\n%d %B %Y\n%T')
    end,
    delay_show = 0.5,
    margins = 10,
    mode = "outside"
})

-- Keyboard map indicator and changer
local kbdcfg = {
    cmd = "setxkbmap ",
    widget = wibox.widget({
        image = theme.english,
        widget = wibox.widget.imagebox
    })
}

kbdcfg.switch = function()
    local us, ru = "us", "ru"
    local f = io.popen(kbdcfg.cmd .. "-query | grep layout")
    local is_us = string.find(f:read("*l"), "us")
    f:close()

    if is_us then
        kbdcfg.widget.image = theme.russian
        os.execute(kbdcfg.cmd .. ru)
    else
        kbdcfg.widget.image = theme.english
        os.execute(kbdcfg.cmd .. us)
    end
end

kbdcfg.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () kbdcfg.switch() end))
)

-- Create wibox
local taglist_buttons = awful.util.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = awful.util.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            c.minimized = false
            if not c:isvisible() and c.first_tag then
                c.first_tag:view_only()
            end
            client.focus = c
            c:raise()
        end
    end),
    awful.button({ }, 2, function (c) c:kill() end),
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
    awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
)

awful.screen.connect_for_each_screen(function(s)
    -- set_wallpaper(s)

    awful.tag({ " 1", " 2", " 3", " 4" }, s, awful.layout.layouts[1])
    s.mylayoutbox = wibox.container.margin(awful.widget.layoutbox(s))
    s.mylayoutbox.margins = 3
    s.mylayoutbox:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.layout.inc( 1) end),
        awful.button({ }, 3, function () awful.layout.inc(-1) end),
        awful.button({ }, 4, function () awful.layout.inc( 1) end),
        awful.button({ }, 5, function () awful.layout.inc(-1) end)
    ))
    s.mytaglist = awful.widget.taglist({
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
        layout = {
            spacing = 8,
            layout = wibox.layout.fixed.vertical,
            forced_width = 30,
            valign = "center",
            align = "center",
        },
    })
    s.mytasklist = awful.widget.tasklist({
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        layout = {
            spacing = 8,
            -- forced_num_cols = 1,
            layout = wibox.layout.grid.vertical,
        },
        widget_template = {
            {
                {
                    id = 'clienticon',
                    widget = awful.widget.clienticon,
                },
                margins = 3,
                widget = wibox.container.margin
            },
            id = 'background_role',
            forced_width = 36,
            forced_height = 36,
            widget = wibox.container.background,
            create_callback = function(self, c)
                self:get_children_by_id('clienticon')[1].client = c
                local tooltip = awful.tooltip({
                    objects = { self },
                    timer_function = function()
                        return c.name
                    end,
                    delay_show = 0.5
                })
                tooltip.mode = "outside"
            end,

      -- Then you can set tooltip props if required (should work as is)
      -- tooltip.align = "left"
      -- tooltip.mode = "outside"
      -- tooltip.preferred_positions = {"left"}
        },
    })
    -- s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)
    s.mywibox = awful.wibar({ position = "left", width = 40, screen = s })
    s.mywibox:setup({
        layout = wibox.layout.align.vertical,
        { -- Left widgets
            layout = wibox.layout.fixed.vertical,
            {
                { widget = s.mytaglist },
                top = 20,
                bottom = 30,
                widget = wibox.container.margin
            },
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.vertical,
            {
                { widget = batterywidget },
                top = 10,
                bottom = 10,
                widget = wibox.container.margin
            },
            {
                { widget = kbdcfg.widget },
                margins = 4,
                widget = wibox.container.margin
            },
            wibox.widget.systray(),
            {
                { widget = hours },
                top = 10,
                widget = wibox.container.margin
            },
            {
                { widget = separator_clock },
                left = 12,
                right = 13,
                widget = wibox.container.margin
            },
            {
                { widget = minutes },
                bottom = 10,
                widget = wibox.container.margin
            },
            {
                { widget = apw },
                top = 10,
                bottom = 10,
                widget = wibox.container.margin
            },
            s.mylayoutbox,
        },
    })
end)
-- }}}
-- Mouse bindings {{{
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
))

local clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function () mymainmenu:hide() end),
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ }, 3, function () mymainmenu:hide() end),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)
-- }}}
-- Key bindings {{{
local globalkeys = awful.util.table.join(

    awful.key({ modkey, }, "s", hotkeys_popup.show_help,
              {description = "show help", group = "awesome"}),
    -- Switch the current keyboard layout
    awful.key({ modkey, }, "space", function () kbdcfg.switch() end),

    -- Volume control keys
    awful.key({ }, "XF86AudioRaiseVolume", apw.up ),
    awful.key({ }, "XF86AudioLowerVolume", apw.down ),
    awful.key({ modkey }, "Up", apw.up ),
    awful.key({ modkey }, "Down", apw.down ),
    awful.key({ }, "XF86AudioMute", apw.toggle_mute ),

    -- Switch tags
    awful.key({ modkey }, "Left", awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey }, "Right", awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),


    -- Layout manipulation
    awful.key({ modkey }, "j",
        function ()
            awful.client.focus.byidx(1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey, "Shift" }, "j", function () awful.client.swap.byidx(1) end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift" }, "k", function () awful.client.swap.byidx(-1) end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative(1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),
    awful.key({ modkey }, "l", function () awful.tag.incmwfact( 0.05) end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey }, "h", function () awful.tag.incmwfact(-0.05) end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift" }, "h", function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift" }, "l", function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h", function () awful.tag.incncol( 1, nil, true) end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l", function () awful.tag.incncol(-1, nil, true) end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey, "Shift" }, "space", function () awful.layout.inc(1) end,
              {description = "select next", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Standard program
    awful.key({ modkey }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ }, "Print",
        function ()
            awful.util.spawn_with_shell(screenshot)
        end),
    awful.key({ modkey, "Shift" }, "r", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),
    awful.key({ modkey }, "r", function() awful.spawn(rofi) end,
              {description = "launch rofi", group = "launcher"}),
    awful.key({ modkey }, "w", function() awful.spawn(rofi_win) end,
              {description = "launch rofi_win", group = "launcher"})
)

local clientkeys = awful.util.table.join(
    awful.key({ modkey }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift" }, "q", function (c) c:kill() end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey }, "o", function (c) c:move_to_screen() end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey }, "t", function (c) c.ontop = not c.ontop end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey }, "n",
        function (c)
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey }, "m",
        function (c)
            if c.maximized then
                c.maximized = not c.maximized
                c:raise()
                c.border_width = beautiful.border_width
            else
                c.maximized = not c.maximized
                c:raise()
                c.border_width = "0"
            end
        end ,
        {description = "maximize", group = "client"})
)

for i = 1, 4 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

-- Set keys
root.keys(globalkeys)
-- }}}
-- Rules {{{
awful.rules.rules = {
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     size_hints_honor = false,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     buttons = clientbuttons }
    },
    { rule_any = {
        class = {
          "mpv",
          "kitty",
          "Zathura",
          "Sxiv",
          "Opera",
        },
      }, properties = { maximized = true }},
    { rule_any = {
        class = {
          "Blender"
        },
      }, properties = { maximized = true, floating = true }},
    { rule_any = {
        class = {
          "Gpick",
          "Git-gui--askpass",
          "Lxappearance",
          "Pavucontrol",
          "Gcr-prompter",
          "Gimp"
        },
        type = {
          "dialog",
        },
        role = {
          "pop-up",
        }
      }, properties = { floating = true },
         callback = function (c) awful.placement.centered(c, nil) end },
}
-- }}}
-- Signals {{{
client.connect_signal("manage", function (c)
    if awesome.startup and not c.size_hints.user_position
                       and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
    if c.maximized then
        c.border_width = "0"
    else
        c.border_width = beautiful.border_width
    end
end)

client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
    if c.maximized then
        c.border_width = "0"
    else
        c.border_width = beautiful.border_width
    end
end)
-- }}}

-- vim:foldmethod=marker
