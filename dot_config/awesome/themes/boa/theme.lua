local theme               = {}
local dir                 = os.getenv("HOME") .. "/.config/awesome/themes/boa"
local dpi                 = require("beautiful.xresources").apply_dpi
local gears = require("gears")
theme.english             = dir .. "/icons/english.png"
theme.russian             = dir .. "/icons/russian.png"
theme.font                = "Cantarell 12"
theme.clockhour           = "Iosevka Monkoose 20"
theme.clockminute         = "Iosevka Monkoose 18"

theme.grey                = "#362f2c"
theme.black               = "#0b0700"
theme.yellow              = "#b19a71"
theme.red                 = "#c73c42"
theme.brown               = "#5c4b42"
theme.orange              = "#bf7643"

theme.fg_normal           = theme.brown
theme.fg_focus            = theme.yellow
theme.fg_urgent           = theme.red
theme.bg_normal           = theme.black
theme.bg_focus            = theme.black
theme.bg_urgent           = theme.black
theme.bg_systray          = theme.black

theme.useless_gap         = dpi(1)
theme.border_width        = dpi(1)
theme.border_normal       = theme.grey
theme.border_focus        = theme.orange
theme.border_marked       = theme.red

theme.layout_tile         = dir .. "/layouts/tile.png"
theme.layout_tilebottom   = dir .. "/layouts/tilebottom.png"
theme.layout_floating     = dir .. "/layouts/floating.png"

-- theme.taglist_bg_empty    = "png:" .. dir .. "/icons/rectangle_empty.png"
-- theme.taglist_bg_occupied = "png:" .. dir .. "/icons/rectangle_brown.png"
-- theme.taglist_bg_urgent   = "png:" .. dir .. "/icons/rectangle_red.png"
-- theme.taglist_bg_focus    = "png:" .. dir .. "/icons/rectangle_yellow.png"
theme.taglist_fg_empty    = theme.black
theme.taglist_fg_occupied = theme.grey
theme.taglist_fg_urgent   = theme.red
theme.taglist_fg_focus    = theme.yellow
theme.taglist_font = "Iosevka Monkoose Bold 16"

theme.tasklist_bg_focus   = theme.grey
-- theme.tasklist_disable_icon = true
-- theme.tasklist_floating             = ""
-- theme.tasklist_sticky               = ""
-- theme.tasklist_maximized_horizontal = ""
-- theme.tasklist_maximized_vertical   = ""
-- theme.tasklist_maximized            = ""


theme.menu_height         = dpi(40)
theme.menu_width          = dpi(180)
theme.menu_font           = "Cantarell 16"

-- APW widget
theme.volume1000          = dir .. "/icons/volume1000.png"
theme.volume833           = dir .. "/icons/volume833.png"
theme.volume667           = dir .. "/icons/volume667.png"
theme.volume500           = dir .. "/icons/volume500.png"
theme.volume333           = dir .. "/icons/volume333.png"
theme.volume167           = dir .. "/icons/volume167.png"
theme.volume000           = dir .. "/icons/volume000.png"
theme.volume000m          = dir .. "/icons/volume000m.png"

return theme
