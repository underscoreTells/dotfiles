local M = {}

local devices = {
  {
    name = "mouse-passthrough",
    enabled = false,
  },
  {
    name = "mouse-passthrough-(absolute)",
    enabled = false,
  },
  {
    name = "keyboard-passthrough",
    enabled = false,
    keybinds = false,
  },
}

function M.apply(_ctx)
  hl.config({
    input = {
      kb_layout = "us",
      kb_variant = "",
      kb_model = "",
      kb_options = "caps:swapescape",
      kb_rules = "",
      numlock_by_default = true,
      follow_mouse = 1,
      sensitivity = 1,
      accel_profile = "flat",
    },
  })

  for _, device in ipairs(devices) do
    hl.device(device)
  end
end

return M
