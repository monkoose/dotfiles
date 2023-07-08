function bright-norm --wraps='xrandr --output DVI-D-0 --brightness 1 --gamma 1:1:1' --description 'alias bright-norm xrandr --output DVI-D-0 --brightness 1 --gamma 1:1:1'
  xrandr --output DVI-D-0 --brightness 1 --gamma 1:1:1 $argv
        
end
