function bright-low --wraps='xrandr --output DVI-D-0 --brightness 0.6 --gamma 1:1:0.8' --description 'alias bright-low xrandr --output DVI-D-0 --brightness 0.6 --gamma 1:1:0.8'
  xrandr --output DVI-D-0 --brightness 0.6 --gamma 1:1:0.8 $argv
        
end
