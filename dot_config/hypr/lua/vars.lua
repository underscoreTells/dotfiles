local M = {}

M.programs = {
  terminal = "kitty",
  file_manager = "env QT_QPA_PLATFORMTHEME=kde QT_STYLE_OVERRIDE=kvantum KVANTUM_THEME=Nordic /usr/bin/dolphin",
  menu = "rofi -show drun",
  browser = "brave",
}

M.mods = {
  main = "SUPER",
  secondary = "ALT",
}

-- Mirror the current env.conf until the uwsm launcher env cutover is completed.
M.environment = {
  { key = "XCURSOR_SIZE", value = "16" },
  { key = "HYPRCURSOR_SIZE", value = "16" },
  { key = "QT_QPA_PLATFORMTHEME", value = "qt6ct" },
  { key = "QT_STYLE_OVERRIDE", value = "kvantum" },
  { key = "KVANTUM_THEME", value = "Nordic" },
  { key = "ELECTRON_OZONE_PLATFORM_HINT", value = "auto" },
}

M.autostart = {
  common = {
    'gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"',
    "~/.config/waybar/launch.sh",
    "swaybg -i /usr/share/backgrounds/nordic-wallpapers/ign_dudeOnBuilding2.png -m fill",
    "eww daemon",
    "hypridle",
  },
}

function M.apply_env()
  for _, env_var in ipairs(M.environment) do
    hl.env(env_var.key, env_var.value)
  end
end

return M
