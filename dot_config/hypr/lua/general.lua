local M = {}

local fallback_monitor = {
  output = "",
  mode = "preferred",
  position = "auto",
  scale = 1,
}

local general_config = {
  general = {
    gaps_in = 5,
    gaps_out = 8,
    border_size = 1,
    ["col.active_border"] = "rgb(81a1c1)",
    ["col.inactive_border"] = "rgba(595959aa)",
    resize_on_border = false,
    allow_tearing = false,
    layout = "dwindle",
  },
  dwindle = {
    preserve_split = true,
  },
  master = {
    new_status = "master",
  },
  xwayland = {
    force_zero_scaling = true,
  },
  misc = {
    force_default_wallpaper = -1,
    disable_hyprland_logo = false,
  },
}

function M.apply(_ctx)
  hl.monitor(fallback_monitor)
  hl.config(general_config)
end

return M
