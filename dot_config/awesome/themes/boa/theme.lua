local dpi = require("beautiful.xresources").apply_dpi
local dir = os.getenv("HOME") .. "/.config/awesome/themes/boa/"
local icons = dir .. "icons/"
local layouts = dir .. "layouts/"
local fixed_font = "Iosevka Monkoose"
local font = "Cantarell"
local grey = "#362f2c"
local black = "#0b0700"
local yellow = "#b19a71"
local red = "#c73c42"
local brown = "#5c4b42"
local orange = "#bf7643"

local theme = {
    english             = icons .. "english.png",
    russian             = icons .. "russian.png",
    font                = font .. " 12",
    clockhour           = fixed_font .. " 20",
    clockminute         = fixed_font .. " 18",

    grey                = "#362f2c",
    black               = "#0b0700",
    yellow              = "#b19a71",
    red                 = "#c73c42",
    brown               = "#5c4b42",
    orange              = "#bf7643",

    fg_normal           = brown,
    fg_focus            = yellow,
    fg_urgent           = red,
    bg_normal           = black,
    bg_focus            = black,
    bg_urgent           = black,
    bg_systray          = black,

    useless_gap         = dpi(1),
    border_width        = dpi(1),
    border_normal       = grey,
    border_focus        = orange,
    border_marked       = red,

    layout_tile         = layouts .. "tile.png",
    layout_tilebottom   = layouts .. "tilebottom.png",
    layout_floating     = layouts .. "floating.png",

    taglist_fg_empty    = black,
    taglist_fg_occupied = grey,
    taglist_fg_urgent   = red,
    taglist_fg_focus    = yellow,
    taglist_font        = fixed_font .. " Bold 16",
    tasklist_bg_focus   = grey,

    menu_height         = dpi(40),
    menu_width          = dpi(180),
    menu_font           = font .. " 16",
}

return theme
