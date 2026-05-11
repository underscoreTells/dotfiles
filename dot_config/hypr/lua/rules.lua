local M = {}

function M.apply(_ctx)
  hl.window_rule({
    match = {
      class = ".*",
    },
    suppress_event = "maximize",
  })

  hl.window_rule({
    match = {
      class = "^$",
      title = "^$",
      xwayland = true,
      float = true,
      fullscreen = false,
      pin = false,
    },
    no_initial_focus = true,
  })

  hl.window_rule({
    match = {
      class = "^(photo\\.exe)$",
      xwayland = true,
    },
    monitor = "DP-1",
  })

  hl.window_rule({
    match = {
      class = "^(photo\\.exe)$",
      title = "^Affinity Photo 2$",
      xwayland = true,
    },
    maximize = true,
  })

  hl.layer_rule({
    match = {
      namespace = "rofi",
    },
    blur = true,
  })

  hl.layer_rule({
    match = {
      namespace = "rofi",
    },
    ignore_alpha = 1,
  })

  hl.layer_rule({
    match = {
      namespace = "waybar",
    },
    blur = true,
  })

  hl.layer_rule({
    match = {
      namespace = "waybar",
    },
    ignore_alpha = 0.1,
  })

  hl.layer_rule({
    match = {
      namespace = "wofi",
    },
    ignore_alpha = 1,
  })

  hl.layer_rule({
    match = {
      namespace = "waybar_widgets",
    },
    blur = true,
  })

  hl.layer_rule({
    match = {
      namespace = "waybar_widgets",
    },
    ignore_alpha = 1,
  })
end

return M
