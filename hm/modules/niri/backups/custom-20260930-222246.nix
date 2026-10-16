{ ... }: {
  # Home Manager does not currently expose a structured Niri settings module;
  # manage Niri's native KDL configuration directly.
  xdg.configFile."niri/config.kdl".text = ''
    input {
        // Mod is Super in a standalone session; nested sessions default to Alt.
        mod-key "Super"
        focus-follows-mouse

        keyboard {
            xkb {
                layout "us,lt,gr"
                options "ctrl:nocaps,grp:ctrl_space_toggle"
            }
        }
    }

    layout {
        gaps 1
        focus-ring {
            width 2
        }
    }

    // Upstream workaround for WezTerm's initial Wayland configure event.
    window-rule {
        match app-id=r#"^org\.wezfurlong\.wezterm$"#
        default-column-width {}
    }

    // Waybar is managed by Home Manager's graphical-session.target service.
    // Start a standalone session with niri-session, not plain niri.

    binds {
        Mod+Shift+Slash { show-hotkey-overlay; }
        Mod+D hotkey-overlay-title="Open launcher: wofi" { spawn "wofi" "--show" "run"; }
        Mod+Return hotkey-overlay-title="Open terminal: WezTerm" { spawn "wezterm"; }
        Mod+Shift+Q { close-window; }
        Mod+F { fullscreen-window; }

        Ctrl+Mod+Up { focus-window-up; }
        Ctrl+Mod+Down { focus-window-down; }
        Ctrl+Mod+Left { focus-workspace-up; }
        Ctrl+Mod+Right { focus-workspace-down; }

        Mod+Left { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Shift+T { spawn "trimgrim"; }
        Mod+Shift+B { spawn "wofi-emoji"; }
        Mod+Shift+C { quit; }

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+Shift+1 { move-window-to-workspace 1; }
        Mod+Shift+2 { move-window-to-workspace 2; }
        Mod+Shift+3 { move-window-to-workspace 3; }
        Mod+Shift+4 { move-window-to-workspace 4; }
        Mod+Shift+5 { move-window-to-workspace 5; }
        Mod+Shift+6 { move-window-to-workspace 6; }
        Mod+Shift+7 { move-window-to-workspace 7; }
        Mod+Shift+8 { move-window-to-workspace 8; }
    }
  '';
}
