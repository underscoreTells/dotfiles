local M = {}

function M.apply(ctx)
  local commands = {}

  for _, command in ipairs(ctx.vars.autostart.common) do
    table.insert(commands, command)
  end

  for _, command in ipairs(ctx.host_autostart or {}) do
    table.insert(commands, command)
  end

  hl.on("hyprland.start", function()
    if ctx.host_load_error and hl.notification and hl.notification.create then
      hl.notification.create({
        text = "No Lua host module loaded for " .. ctx.host,
        duration = 10000,
        icon = "warn",
      })
    end

    for _, command in ipairs(commands) do
      hl.exec_cmd(command)
    end
  end)
end

return M
