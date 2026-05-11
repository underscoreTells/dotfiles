local M = {}

function M.apply(_ctx)
  hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
  })

  hl.config({
    input = {
      sensitivity = 0.5,
      touchpad = {
        natural_scroll = false,
        tap_to_click = true,
        disable_while_typing = true,
      },
    },
  })

  hl.gesture({
    fingers = 3,
    direction = "right",
    action = "workspace",
  })

  hl.gesture({
    fingers = 3,
    direction = "left",
    action = "workspace",
  })

  for workspace = 1, 6 do
    hl.workspace_rule({
      workspace = tostring(workspace),
      persistent = true,
    })
  end
end

return M
