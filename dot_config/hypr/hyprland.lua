-- Future primary config for Hyprland >= 0.55.
-- Keep hyprland.conf as the rollback entrypoint until launcher cutover is complete.

local source = debug.getinfo(1, "S").source:sub(2)
local config_dir = source:match("(.*/)")

package.path = table.concat({
  config_dir .. "lua/?.lua",
  config_dir .. "lua/?/init.lua",
  package.path,
}, ";")

local function read_hostname()
  local host = os.getenv("HOSTNAME") or os.getenv("HOST")
  if host and host ~= "" then
    return host
  end

  local handle = io.open("/etc/hostname", "r")
  if not handle then
    return "unknown"
  end

  local line = handle:read("*l")
  handle:close()

  if not line or line == "" then
    return "unknown"
  end

  return (line:gsub("%s+$", ""))
end

local function load_host_module(hostname)
  local host_path = config_dir .. "hosts/" .. hostname .. ".lua"
  local ok, module_or_error = pcall(dofile, host_path)
  if ok then
    return module_or_error
  end

  return nil, module_or_error
end

local vars = require("vars")
local ctx = {
  config_dir = config_dir,
  host = read_hostname(),
  vars = vars,
}

vars.apply_env()

require("general").apply(ctx)
require("decoration").apply(ctx)
require("animations").apply(ctx)
require("input").apply(ctx)
require("keybinds").apply(ctx)
require("rules").apply(ctx)

local host_module, host_error = load_host_module(ctx.host)
if host_module and type(host_module.apply) == "function" then
  host_module.apply(ctx)
elseif host_error then
  ctx.host_load_error = host_error
end

require("autostart").apply(ctx)
