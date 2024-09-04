-- Imports {{{1
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
-- pcall(require, "luarocks.loader")

-- Standard awesome library
local awful = require("awful")
local gears = require("gears")
require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup").widget

-- Error handling {{{1
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors
  })
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal("debug::error", function(err)
    -- Make sure we don't go into an endless error loop
    if in_error then return end
    in_error = true

    naughty.notify({
      preset = naughty.config.presets.critical,
      title = "Oops, an error happened!",
      text = tostring(err)
    })
    in_error = false
  end)
end

-- Variable definitions {{{1
-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/themes/boa/theme.lua")
local theme_assets = require("beautiful.theme_assets")
theme_assets.recolor_layout(beautiful, beautiful.yellow)

-- This is used later as default programs.
local filemanager = "pcmanfm"
local launcher = "rofi -show run"
local rofi_win = "rofi -show window"
local terminal = "st"
local browser = os.getenv("BROWSER")
local reboot = 'sh -c "reboot"'
local poweroff = 'sh -c "poweroff"'
local brnorm = 'sh -c "xrandr --output DVI-D-0 --brightness 1 --gamma 1:1:1"'
local brlow = 'sh -c "xrandr --output DVI-D-0 --brightness 0.6 --gamma 1:1:0.9"'
local broff = 'sh -c "xrandr --output DVI-D-0 --brightness 0.4 --gamma 1:1:0.9"'
local screenshot = "mkdir -p ~/Pictures/screenshots; " ..
    "scrot '%Y-%m-%d_%H:%M:%S.png' -e 'mv $f ~/Pictures/screenshots/ 2>/dev/null'"

-- Default modkey.
local modkey = "Mod4"

awful.layout.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.floating,
}

-- Menu {{{1
local mymainmenu = awful.menu({
  items = {
    { "browser",     browser },
    { "terminal",    terminal },
    { "filemanager", filemanager },
    { "refresh",     awesome.restart },
    { "reboot",      reboot },
    { "poweroff",    poweroff },
    { "logout",        function() awesome.quit() end },
  }
})

-- Widgets {{{1

local pulse = wibox.container.margin(require("widgets.pulseaudio"), 4, 0, 2, 4)

-- Clock
local clock = wibox.widget({
  {
    {
      format = "%H:%M",
      font = beautiful.clock_font,
      align = "center",
      refresh = 60,
      widget = wibox.widget.textclock
    },
    fg = beautiful.yellow,
    widget = wibox.container.background,
  },
  left = 20,
  right = 15,
  bottom = 2,
  widget = wibox.container.margin,
})

local clock_tooltip = awful.tooltip({
  objects = { clock },
  delay_show = 0.2,
  margins_leftright = 10,
  margins_topbottom = 6,
  ontop = true,
})
clock_tooltip:set_text(os.date('%d %B %Y\n%A'))

-- Keyboard layout switcher
local function switch_kbd_layout()
  local lang_nexts = setmetatable({ us = "ru", ru = "us" }, {
    __index = function() return "us" end,
  })

  awful.spawn.easy_async_with_shell("setxkbmap -query | grep '^layout'", function(out)
    local curr_lang = string.match(out, "%s*(%a*)", 8)
    awful.spawn.with_shell("setxkbmap " .. lang_nexts[curr_lang])
  end)
end

local function keyboardlayout_with_font(font)
  local result = awful.widget.keyboardlayout()
  result.widget.font = font
  return result
end

local mykeyboardlayout = wibox.widget({
  keyboardlayout_with_font(beautiful.keyboardlayout_font),
  fg = beautiful.yellow,
  widget = wibox.container.background,
})
mykeyboardlayout:buttons(awful.util.table.join(
  awful.button({}, 1, function() switch_kbd_layout() end))
)

-- Wibox {{{1
local taglist_buttons = awful.util.table.join(
  awful.button({}, 1, function(t) t:view_only() end),
  awful.button({ modkey }, 1, function(t)
    if client.focus then
      client.focus:move_to_tag(t)
    end
  end),
  awful.button({}, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, function(t)
    if client.focus then
      client.focus:toggle_tag(t)
    end
  end),
  awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
  awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = awful.util.table.join(
  awful.button({}, 1, function(c)
    if c == client.focus then
      -- c.minimized = true
    else
      c.minimized = false
      if not c:isvisible() and c.first_tag then
        c.first_tag:view_only()
      end
      client.focus = c
      c:raise()
    end
  end),
  awful.button({}, 2, function(c) c:kill() end),
  awful.button({}, 3, function() mymainmenu:toggle() end)
-- awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
-- awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
)

awful.screen.connect_for_each_screen(function(s)
  awful.tag({ " 1", " 2", " 3", " 4" }, s, awful.layout.layouts[1])

  s.mylayoutbox = awful.widget.layoutbox(s)
  s.mylayoutbox:buttons(awful.util.table.join(
    awful.button({}, 1, function() awful.layout.inc(1) end),
    awful.button({}, 3, function() awful.layout.inc(-1) end),
    awful.button({}, 4, function() awful.layout.inc(1) end),
    awful.button({}, 5, function() awful.layout.inc(-1) end)))

  s.mytaglist = awful.widget.taglist({
    screen = s,
    filter = awful.widget.taglist.filter.all,
    buttons = taglist_buttons,
    layout = {
      spacing = 2,
      layout = wibox.layout.fixed.horizontal,
      valign = "center",
      align = "center",
    },
  })

  s.mytasklist = awful.widget.tasklist({
    screen = s,
    filter = function(c, screen)
      if not c.name then return false end
      return awful.widget.tasklist.filter.currenttags(c, screen)
    end,
    buttons = tasklist_buttons,
    layout = {
      spacing = 10,
      layout = wibox.layout.flex.horizontal,
    },
    widget_template = {
      {
        wibox.widget.base.make_widget(),
        forced_height = 1,
        id            = 'background_role',
        widget        = wibox.container.background,
      },
      {
        {
          {
            id     = 'icon_role',
            widget = wibox.widget.imagebox,
          },
          margins = 2,
          widget = wibox.container.margin,
        },
        {
          id     = 'text_role',
          widget = wibox.widget.textbox,
        },
        layout = wibox.layout.align.horizontal,
      },
      layout = wibox.layout.align.vertical,
    },
  })

  s.mywibox = awful.wibar({ position = "top", height = 34, screen = s })
  s.mywibox:setup({
    layout = wibox.layout.align.horizontal,
    {     -- Left widgets
      layout = wibox.layout.fixed.horizontal,
      wibox.container.margin(s.mytaglist, 5, 8)
    },
    s.mytasklist,
    {     -- Right widgets
      layout = wibox.layout.fixed.horizontal,
      wibox.container.margin(mykeyboardlayout, 4, 0, 0, 4),
      -- power,
      pulse,
      -- connman,
      wibox.container.margin(wibox.widget.systray(), 2, 2, 2, 4),
      clock,
      wibox.container.margin(s.mylayoutbox, 3, 3, 2, 4)
    },
  })
end)

-- Mouse bindings {{{1
root.buttons(awful.util.table.join(
  awful.button({}, 3, function() mymainmenu:toggle() end)
))

local clientbuttons = awful.util.table.join(
  awful.button({}, 1, function() mymainmenu:hide() end),
  awful.button({}, 1, function(c)
    client.focus = c; c:raise()
  end),
  awful.button({ modkey }, 1, awful.mouse.client.move),
  awful.button({}, 3, function() mymainmenu:hide() end),
  awful.button({ modkey }, 3, awful.mouse.client.resize)
)

-- Key bindings {{{1
local globalkeys = awful.util.table.join(

  awful.key({ modkey, }, "s", hotkeys_popup.show_help,
    { description = "show help", group = "awesome" }),
  -- Switch the current keyboard layout
  awful.key({ modkey, }, "space", function() switch_kbd_layout() end),

  -- Volume control keys
  -- awful.key({ }, "XF86AudioRaiseVolume", apw.up ),
  -- awful.key({ }, "XF86AudioLowerVolume", apw.down ),
  -- awful.key({ modkey }, "Up", apw.up ),
  -- awful.key({ modkey }, "Down", apw.down ),
  -- awful.key({ }, "XF86AudioMute", apw.toggle_mute ),

  -- Switch tags
  awful.key({ modkey }, "Left", awful.tag.viewprev,
    { description = "view previous", group = "tag" }),
  awful.key({ modkey }, "Right", awful.tag.viewnext,
    { description = "view next", group = "tag" }),
  awful.key({ modkey }, "Escape", awful.tag.history.restore,
    { description = "go back", group = "tag" }),
  awful.key({ modkey }, "F1", function() awful.util.spawn_with_shell(brnorm) end),
  awful.key({ modkey }, "F2", function() awful.util.spawn_with_shell(brlow) end),
  awful.key({ modkey }, "F3", function() awful.util.spawn_with_shell(broff) end),
  -- Layout manipulation
  awful.key({ modkey }, "j",
    function()
      awful.client.focus.byidx(1)
    end,
    { description = "focus next by index", group = "client" }
  ),
  awful.key({ modkey }, "k",
    function()
      awful.client.focus.byidx(-1)
    end,
    { description = "focus previous by index", group = "client" }
  ),
  awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
    { description = "swap with next client by index", group = "client" }),
  awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
    { description = "swap with previous client by index", group = "client" }),
  awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
    { description = "focus the next screen", group = "screen" }),
  awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
    { description = "focus the previous screen", group = "screen" }),
  awful.key({ modkey }, "u", awful.client.urgent.jumpto,
    { description = "jump to urgent client", group = "client" }),
  awful.key({ modkey }, "Tab",
    function()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end,
    { description = "go back", group = "client" }),
  awful.key({ modkey }, "l", function() awful.tag.incmwfact(0.05) end,
    { description = "increase master width factor", group = "layout" }),
  awful.key({ modkey }, "h", function() awful.tag.incmwfact(-0.05) end,
    { description = "decrease master width factor", group = "layout" }),
  awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end,
    { description = "increase the number of master clients", group = "layout" }),
  awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
    { description = "decrease the number of master clients", group = "layout" }),
  awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end,
    { description = "increase the number of columns", group = "layout" }),
  awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
    { description = "decrease the number of columns", group = "layout" }),
  awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(1) end,
    { description = "select next", group = "layout" }),

  awful.key({ modkey, "Shift" }, "n",
    function()
      local c = awful.client.restore()
      if c then
        client.focus = c
        c:raise()
      end
    end,
    { description = "restore minimized", group = "client" }),

  -- Standard program
  awful.key({ modkey }, "Return", function() awful.spawn(terminal) end,
    { description = "open a terminal", group = "launcher" }),
  awful.key({}, "Print",
    function()
      awful.util.spawn_with_shell(screenshot)
    end),
  awful.key({ modkey, "Shift" }, "r", function() mymainmenu:show() end,
    { description = "show main menu", group = "awesome" }),
  awful.key({ modkey }, "r", function() awful.spawn(launcher) end,
    { description = "open launcher", group = "launcher" }),
  awful.key({ modkey }, "w", function() awful.spawn(rofi_win) end,
    { description = "launch rofi_win", group = "launcher" })
)

local clientkeys = awful.util.table.join(
  awful.key({ modkey }, "f",
    function(c)
      c.fullscreen = not c.fullscreen
      c:raise()
    end,
    { description = "toggle fullscreen", group = "client" }),
  awful.key({ modkey, "Shift" }, "q", function(c) c:kill() end,
    { description = "close", group = "client" }),
  awful.key({ modkey, "Shift" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
    { description = "move to master", group = "client" }),
  awful.key({ modkey }, "o", function(c) c:move_to_screen() end,
    { description = "move to screen", group = "client" }),
  awful.key({ modkey }, "t", function(c) c.ontop = not c.ontop end,
    { description = "toggle keep on top", group = "client" }),
  awful.key({ modkey }, "n", function(c) c.minimized = true end,
    { description = "minimize", group = "client" }),

  awful.key({ modkey }, "e", function(c)
      if c.floating then
        awful.titlebar.hide(c)
        c.floating = false
      else
        c.floating = true
        if not c.maximized then
          awful.titlebar.show(c)
        end
      end
    end,
    { description = "toggle floating", group = "client" }),

  awful.key({ modkey }, "m", function(c)
      if c.maximized then
        c.maximized = false
        c.border_width = beautiful.border_width
        if c.floating then
          awful.titlebar.show(c)
        end
      else
        awful.titlebar.hide(c)
        c.maximized = true
        c.border_width = 0
      end
    end,
    { description = "maximize", group = "client" })
)

for i = 1, 4 do
  globalkeys = awful.util.table.join(globalkeys,
    -- View tag only.
    awful.key({ modkey }, "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          tag:view_only()
        end
      end,
      { description = "view tag #" .. i, group = "tag" }),
    -- Toggle tag display.
    awful.key({ modkey, "Control" }, "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end,
      { description = "toggle tag #" .. i, group = "tag" }),
    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
      function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:move_to_tag(tag)
          end
        end
      end,
      { description = "move focused client to tag #" .. i, group = "tag" }),
    -- Toggle tag on focused client.
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
      function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:toggle_tag(tag)
          end
        end
      end,
      { description = "toggle focused client on tag #" .. i, group = "tag" })
  )
end

-- Set keys
root.keys(globalkeys)

-- Rules {{{1
awful.rules.rules = {
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      size_hints_honor = false,
      focus = awful.client.focus.filter,
      raise = true,
      keys = clientkeys,
      screen = awful.screen.preferred,
      placement = awful.placement.centered + awful.placement.no_offscreen,
      buttons = clientbuttons,
    },
  },

  {
    rule_any = {
      class = {
        "st-256color",
        "Zathura",
      },
    },
    properties = { maximized = true },
  },

  {
    rule_any = {
      class = {
        "Gpick",
        "Git-gui--askpass",
        "Lxappearance",
        "pavucontrol",
        "Gcr-prompter",
        "Gimp",
        "Blender",
        "Godot",
        "dmengine",
      },
      type = {
        "dialog",
      },
      role = {
        "pop-up",
      },
    },
    properties = {
      floating = true,
    },
  },

  { rule = { instance = "Godot_Engine" },
    properties = { floating = true },
  },
}

-- Signals {{{1
client.connect_signal("manage", function(c)
  if awesome.startup and
      not c.size_hints.user_position and
      not c.size_hints.program_position then
    awful.placement.no_offscreen(c)
  end
  if c.maximized then
    c.border_width = 0
  else
    c.border_width = beautiful.border_width
    if c.floating then
      awful.titlebar.show(c)
    end
  end
end)

client.connect_signal("property::size", function(c)
  if c.maximized then
    local _, titlebar_height = c:titlebar_top()
    if titlebar_height ~= 0 then
      awful.titlebar.hide(c)
      c.maximized = false
      c.maximized = true
    end
    c.border_width = 0
  else
    c.border_width = beautiful.border_width
  end
end)

client.connect_signal("focus", function(c)
  c.border_color = beautiful.border_focus
end)

client.connect_signal("unfocus", function(c)
  c.border_color = beautiful.border_normal
end)

client.connect_signal("request::titlebars", function(c)
    if c.class == "Godot" and not c.name then
      c.border_width = 0
      return
    end

    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    local top_titlebar = awful.titlebar(c, {
        size = 26,
    })

    top_titlebar:setup {
        { -- Left
            wibox.container.margin(awful.titlebar.widget.iconwidget(c), 5, 5),
            buttons = buttons,
            layout = wibox.layout.fixed.horizontal,
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout = wibox.layout.flex.horizontal
        },
        { -- Right
            wibox.container.margin(awful.titlebar.widget.closebutton(c), 5, 6, 5, 5),
            layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- vim:foldmethod=marker
