-- Host-specific Hyprland Lua configuration.

local launcher = "wofi --show run"
local terminal = "wezterm"

hl.config({
  xwayland = {
    enabled = false,
  },
  general = {
    gaps_in = 1,
    gaps_out = 2,
    layout = "dwindle",
  },
  input = {
    kb_layout = "us,lt,gr",
    kb_options = "ctrl:nocaps,grp:ctrl_space_toggle",
  },
  misc = {
    force_default_wallpaper = 2,
  },

  dwindle = {
    preserve_split = true,
    smart_split = true,
  },
})

hl.device({
  name = "tpps/2-synaptics-trackpoint",
  sensitivity = -0.9,
})

-- https://easings.net/#easeOutQuint
hl.curve("ease_out_quint", {
  type = "bezier",
  points = { { 0.22, 1 }, { 0.36, 1 } },
})

-- Disable all animations, except for workspace switching.
hl.animation({
  leaf = "workspaces",
  enabled = true,
  speed = 5,
  bezier = "ease_out_quint",
  style = "slide",
})

for _, leaf in ipairs({ "windows", "layers", "fade", "border", "borderangle" }) do
  hl.animation({
    leaf = leaf,
    enabled = false,
  })
end

-- Launch programs.
hl.bind("SUPER + D", hl.dsp.exec_cmd(launcher))
hl.bind("SUPER + Return", hl.dsp.exec_cmd(terminal))

-- Window actions.
hl.bind("SUPER + SHIFT + Q", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.window.fullscreen())

-- Focus windows.
for _, direction in ipairs({ "up", "down", "left", "right" }) do
  hl.bind("CTRL + SUPER + " .. direction, hl.dsp.focus({ direction = direction }))
end

-- Focus and move to numbered workspaces.
for workspace = 1, 8 do
  hl.bind("SUPER + " .. workspace, hl.dsp.focus({ workspace = workspace }))
  hl.bind("SUPER + SHIFT + " .. workspace, hl.dsp.window.move({ workspace = workspace }))
end

-- Focus prev/next workspace.
hl.bind("SUPER + left", hl.dsp.focus({ workspace = "r-1" }))
hl.bind("SUPER + right", hl.dsp.focus({ workspace = "r+1" }))

-- Utilities.
hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd("trimgrim"))
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("wofi-emoji"))

-- Quit Hyprland.
hl.bind("SUPER + SHIFT + C", hl.dsp.exit())

-- Move/resize windows with super + drag.
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
