local dpi = require("beautiful.xresources").apply_dpi
local dir = "~/.config/awesome/themes/boa/"
local layouts = dir .. "layouts/"

local fonts = {
  mono = "Iosevka Monkoose Bold",
  sans = "Noto Sans Medium",
}

local colors = {
  grey = "#362f2c",
  black = "#0b0700",
  yellow = "#b19a71",
  red = "#c73c42",
  brown = "#5c4b42",
  orange = "#bf7643",
  titlebar_normal = "#362f2c",
  titlebar_focus = "#a86b41",
}

return {
  font                      = fonts.sans .. " 12",
  clock_font                = fonts.mono .. " 16",
  keyboardlayout_font       = fonts.mono .. " 18",

  grey                      = colors.grey,
  black                     = colors.black,
  yellow                    = colors.yellow,
  red                       = colors.red,
  brown                     = colors.brown,
  orange                    = colors.orange,

  fg_normal                 = colors.brown,
  fg_focus                  = colors.yellow,
  fg_urgent                 = colors.red,
  bg_normal                 = colors.black,
  bg_focus                  = colors.black,
  bg_urgent                 = colors.black,
  bg_systray                = colors.black,

  useless_gap               = dpi(1),
  border_width              = dpi(1),
  border_normal             = colors.grey,
  border_focus              = colors.orange,
  border_marked             = colors.red,

  layout_tile               = layouts .. "tile.png",
  layout_tilebottom         = layouts .. "tilebottom.png",
  layout_floating           = layouts .. "floating.png",

  taglist_fg_empty          = colors.black,
  taglist_fg_occupied       = colors.grey,
  taglist_fg_urgent         = colors.red,
  taglist_fg_focus          = colors.yellow,
  taglist_font              = fonts.mono .. " 16",

  tasklist_bg_focus         = colors.yellow,
  tasklist_bg_normal        = colors.grey,
  tasklist_fg_urgent        = colors.red,

  menu_height               = dpi(40),
  menu_width                = dpi(190),
  menu_font                 = fonts.sans .. " 16",

  notification_border_width = dpi(1),
  notification_border_color = colors.yellow,
  notification_font         = fonts.sans .. " 14",
  notification_fg           = colors.yellow,

  tooltip_border_color      = colors.yellow,
  tooltip_border_width      = dpi(1),
  tooltip_font              = fonts.sans .. " 14",

  titlebar_fg_normal = "#545151",
  titlebar_fg_focus  = "#2c2727",
  titlebar_bg_normal = colors.titlebar_normal,
  titlebar_bg_focus  = colors.titlebar_focus,
  titlebar_close_button_normal = layouts .. "close_button.png",
  titlebar_close_button_focus = layouts .. "close_button_focus.png",
  titlebar_close_button_focus_hover = layouts .. "close_button_hover.png",
  titlebar_close_button_focus_press = layouts .. "close_button_press.png",
}
