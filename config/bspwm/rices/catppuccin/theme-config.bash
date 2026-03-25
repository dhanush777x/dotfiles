#############################
#		Catppuccin Theme		#
#############################
# Copyright (C) 2021-2025 gh0stzk <z0mbi3.zk@protonmail.com>
# https://github.com/gh0stzk/dotfiles

# (Catppuccin) colorscheme
bg="#1E1E2E"
fg="#CDD6F4"

black="#181825"       # mantle
red="#F38BA8"
green="#A6E3A1"
yellow="#F9E2AF"
blue="#89B4FA"
magenta="#B4BEFE"     # lavender accent
cyan="#89DCEB"
white="#BAC2DE"

blackb="#313244"      # surface0
redb="#F38BA8"
greenb="#A6E3A1"
yellowb="#F9E2AF"
blueb="#89B4FA"
magentab="#B4BEFE"    # lavender bright
cyanb="#89DCEB"
whiteb="#CDD6F4"      # text

accent_color="#45475A"  # surface1
arch_icon="#B4BEFE"     # blue-ish lavender-friendly

# Bspwm options
BORDER_WIDTH="1"
TOP_PADDING="50"
BOTTOM_PADDING="1"
LEFT_PADDING="1"
RIGHT_PADDING="1"
NORMAL_BC="#313244"    # surface0
FOCUSED_BC="#B4BEFE"   # lavender

# Terminal font & size
term_font_size="10"
term_font_name="JetBrainsMono Nerd Font"

# Picom options
P_FADE="true"			# Fade true|false
P_SHADOWS="true"		# Shadows true|false
SHADOW_C="#000000"		# Shadow color
P_CORNER_R="12"			# Corner radius (0 = disabled)
P_BLUR="true"			# Blur true|false
P_ANIMATIONS="@"		# (@ = enable) (# = disable)
P_TERM_OPACITY="0.98"	# Terminal transparency. Range: 0.1 - 1.0 (1.0 = disabled)

# Dunst
dunst_offset='(15, 50)'
dunst_origin='top-right'
dunst_transparency='8'
dunst_corner_radius='12'
dunst_font='SF Pro Text 10'
dunst_border='1'
dunst_frame_color="$accent_color"
dunst_icon_theme="Papirus-Dark"

# Dunst animations
dunst_close_preset="fly-out"
dunst_close_direction="right"
dunst_open_preset="slide-in"
dunst_open_direction="left"

# Jgmenu colors
jg_bg="$bg"
jg_fg="$fg"
jg_sel_bg="$accent_color"
jg_sel_fg="$fg"
jg_sep="$blackb"

# Rofi menu font and colors
rofi_font="JetBrainsMono NF Bold 9"
rofi_background="$bg"
rofi_bg_alt="$accent_color"
rofi_background_alt="${bg}E0"
rofi_fg="$fg"
rofi_selected="$magenta"
rofi_active="$green"
rofi_urgent="$red"

# Screenlocker
sl_bg="${bg}"
sl_fg="${fg}"
sl_ring="${black}"
sl_wrong="${red}"
sl_date="${fg}"
sl_verify="${magentab}"

# Gtk theme
gtk_theme="Catppuccin-Mocha-Lavender-Dark" 
gtk_icons="Papirus-Dark"
gtk_cursor="Qogirr-Dark"
geany_theme="z0mbi3-TokyoNight"

# Wallpaper engine
# Available engines:
# - Random  (Set a random wallpaper from Walls rice directory)
# - CustomDir   (Set a random wallpaper from the directory you specified)
# - Default (Sets a specific image as wallpaper) *Default
# - Animated (Set an animated wallpaper. "mp4, mkv, gif")
# - Slideshow (Change randomly every 15 minutes your wallpaper from Walls rice directory)
ENGINE="Default"

CUSTOM_DIR="/path/to/your/wallpapers/directory"
DEFAULT_WALL="/mnt/f461fd97-f475-4727-aacb-dc5487ef52fd/Wallpapers/black-panther-3840x2160-13195.jpg"
ANIMATED_WALL="$HOME/.config/bspwm/config/assets/animated_wall.mp4"
