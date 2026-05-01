local M = {}

function M.apply(ctx)
  hl.monitor({
    output = "DP-1",
    mode = "2560x1440@179.95",
    position = "0x0",
    scale = 1.25,
  })

  hl.monitor({
    output = "HDMI-A-1",
    mode = "1920x1080@60",
    position = "-1080x-300",
    scale = 1,
    transform = 3,
  })

  for workspace = 1, 6 do
    hl.workspace_rule({
      workspace = tostring(workspace),
      monitor = "DP-1",
      persistent = true,
    })
  end

  for workspace = 7, 10 do
    hl.workspace_rule({
      workspace = tostring(workspace),
      monitor = "HDMI-A-1",
      persistent = true,
    })
  end

  ctx.host_autostart = {
    "~/.config/hypr/scripts/openrgb-autostart.sh",
    "xrandr --output DP-1 --primary",
  }
end

return M
