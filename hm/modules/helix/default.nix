{ lib
, config
, ...
}:
with lib; let
  helixEnabled = config.programs.helix.enable;
in
{
  imports = [ ./languages.nix ];
  config.programs.helix = mkIf helixEnabled {
    settings = {
      theme = "catppuccin_frappe";
      editor = {
        file-picker.hidden = false;
        line-number = "relative";
        cursorline = true;
        scrolloff = 6;
        lsp = {
          display-messages = true;
          display-signature-help-docs = false;
          display-inlay-hints = true;
        };
        cursor-shape = {
          insert = "bar";
          select = "underline";
        };
        bufferline = "always";
        soft-wrap.enable = true;
        statusline = {
          left = [ "mode" "spacer" "spinner" "spacer" "version-control" "workspace-diagnostics" ];
          center = [ "file-name" "file-modification-indicator" "spacer" "diagnostics" ];
          right = [ "position" "total-line-numbers" ];
          separator = "|";
          mode.normal = "NORMAL";
          mode.insert = "INSERT";
          mode.select = "SELECT";
        };
      };

      keys.select = {
        "esc" = [ "collapse_selection" "keep_primary_selection" "normal_mode" ];
      };
      keys.normal = {
        "V" = [ "select_mode" "extend_line_below" ];
        "C-c" = "normal_mode";
        "C-/" = "toggle_comments";
        "tab" = ":buffer-next";
        "S-tab" = ":buffer-previous";

        "C-n" = [ "extend_to_line_bounds" "delete_selection" "paste_after" ];
        "C-e" = [ "extend_to_line_bounds" "delete_selection" "move_line_up" "paste_before" ];
        "esc" = [ "collapse_selection" "keep_primary_selection" ];
      };
      keys.normal.g = {
        "m" = "goto_line_start";
        "n" = "goto_last_line";
        "e" = "goto_file_start";
        "i" = "goto_line_end";
      };

      keys.normal.space.w = {
        "m" = "jump_view_left";
        "n" = "jump_view_down";
        "e" = "jump_view_up";
        "i" = "jump_view_right";
      };

      keys.normal.C-w = {
        "m" = "jump_view_left";
        "n" = "jump_view_down";
        "e" = "jump_view_up";
        "i" = "jump_view_right";
        "C-x" = ":buffer-close";
      };

      keys.insert = {
        "C-c" = "normal_mode";
        "C-/" = "toggle_comments";
      };

      keys.normal.z = {
        "n" = "scroll_down";
        "e" = "scroll_up";
      };

      keys.normal.Z = {
        "n" = "scroll_down";
        "e" = "scroll_up";
      };
    };
  };
}
