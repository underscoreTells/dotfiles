local M = {}

local function bind(keys, dispatcher, flags)
  if flags then
    hl.bind(keys, dispatcher, flags)
    return
  end

  hl.bind(keys, dispatcher)
end

local function bind_exec(keys, command, flags)
  bind(keys, hl.dsp.exec_cmd(command), flags)
end

function M.apply(ctx)
  local programs = ctx.vars.programs
  local main = ctx.vars.mods.main
  local secondary = ctx.vars.mods.secondary

  bind_exec(main .. " + RETURN", programs.terminal)
  bind(secondary .. " + Q", hl.dsp.window.kill())
  bind_exec(main .. " + U", programs.file_manager)
  bind(main .. " + V", hl.dsp.window.float())
  bind_exec(main .. " + SPACE", programs.menu)
  bind(main .. " + P", hl.dsp.window.pseudo())
  bind(main .. " + J", hl.dsp.layout("togglesplit"))
  bind(main .. " + F", hl.dsp.window.fullscreen())
  bind_exec(main .. " + L", "hyprlock")
  bind_exec(main .. " + O", programs.browser)
  bind_exec(main .. " + B", "rofi-wallpaper")

  bind(secondary .. " + H", hl.dsp.focus({ direction = "l" }))
  bind(secondary .. " + L", hl.dsp.focus({ direction = "r" }))
  bind(secondary .. " + K", hl.dsp.focus({ direction = "u" }))
  bind(secondary .. " + J", hl.dsp.focus({ direction = "d" }))

  bind(secondary .. " + SHIFT + H", hl.dsp.window.swap({ direction = "l" }))
  bind(secondary .. " + SHIFT + L", hl.dsp.window.swap({ direction = "r" }))
  bind(secondary .. " + SHIFT + K", hl.dsp.window.swap({ direction = "u" }))
  bind(secondary .. " + SHIFT + J", hl.dsp.window.swap({ direction = "d" }))

  for workspace = 1, 9 do
    local workspace_id = tostring(workspace)
    bind(secondary .. " + " .. workspace_id, hl.dsp.focus({ workspace = workspace_id }))
    bind(
      secondary .. " + SHIFT + " .. workspace_id,
      hl.dsp.window.move({ workspace = workspace_id, follow = true })
    )
  end

  bind(secondary .. " + 0", hl.dsp.focus({ workspace = "10" }))
  bind(secondary .. " + SHIFT + 0", hl.dsp.window.move({ workspace = "10", follow = true }))

  bind(secondary .. " + S", hl.dsp.workspace.toggle_special("magic"))
  bind(secondary .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic", follow = true }))

  bind(main .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
  bind(main .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

  bind(main .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
  bind(main .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

  bind_exec(main .. " + DELETE", "sh -c /bin/shot-edit")

  local repeating_locked = { locked = true, repeating = true }
  local locked = { locked = true }

  bind_exec("XF86AudioRaiseVolume", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+", repeating_locked)
  bind_exec("XF86AudioLowerVolume", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-", repeating_locked)
  bind_exec("XF86AudioMute", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", repeating_locked)
  bind_exec("XF86AudioMicMute", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle", repeating_locked)
  bind_exec("XF86MonBrightnessUp", "brightnessctl -e4 -n2 set 5%+", repeating_locked)
  bind_exec("XF86MonBrightnessDown", "brightnessctl -e4 -n2 set 5%-", repeating_locked)

  bind_exec("XF86AudioNext", "playerctl next", locked)
  bind_exec("XF86AudioPause", "playerctl play-pause", locked)
  bind_exec("XF86AudioPlay", "playerctl play-pause", locked)
  bind_exec("XF86AudioPrev", "playerctl previous", locked)
end

return M
