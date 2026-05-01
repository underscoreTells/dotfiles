local M = {}

function M.apply(_ctx)
  hl.config({
    decoration = {
      rounding = 5,
      active_opacity = 1.0,
      inactive_opacity = 0.6,
      shadow = {
        enabled = true,
        range = 4,
        render_power = 3,
        color = "rgba(1a1a1aee)",
      },
      blur = {
        enabled = true,
        size = 5,
        passes = 2,
        vibrancy = 1,
      },
    },
  })
end

return M
