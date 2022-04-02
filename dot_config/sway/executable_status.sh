battery=$(cat /sys/class/power_supply/BAT0/capacity)
time=$(date +'%H:%M %d-%m-%Y')
lang=$(swaymsg -t get_inputs | jq -r '.[] | select(.identifier == "1:1:AT_Translated_Set_2_keyboard") | .xkb_active_layout_name' | cut -b 1-2)

echo $lang -- $battery -- $time ""
