{ pkgs, ... }:

{
  services.dunst.enable = true;
  services.dunst.package = pkgs.dunst.override { withWayland = false; };
  services.dunst.settings = {
    # definitely not copied from some random config
    global = {
      # Display
      monitor = 0;
      follow = "mouse";
      
      # Geometry
      width = 350;
      height = 100;
      origin = "top-right";
      offset = "20x50";
      scale = 0;
      notification_limit = 5;
      
      # Progress bar
      progress_bar = true;
      progress_bar_height = 3;
      progress_bar_frame_width = 1;
      progress_bar_min_width = 150;
      progress_bar_max_width = 300;
      
      # Appearance - Increased transparency for more glass-like effect
      transparency = 35;  # Increased from 15 to 35 for more transparency
      separator_height = 2;
      padding = 16;
      horizontal_padding = 20;
      text_icon_padding = 16;
      frame_width = 1;
      frame_color = "#ffffff20";  # More subtle frame with transparency
      separator_color = "frame";
      sort = true;
      idle_threshold = 120;
      
      # Typography
      font = "SF Pro Display 11";
      line_height = 0;
      markup = "full";
      format = "<b>%s</b>\\n%b";
      alignment = "left";
      vertical_alignment = "center";
      show_age_threshold = 60;
      word_wrap = true;
      ellipsize = "middle";
      ignore_newline = false;
      stack_duplicates = true;
      hide_duplicate_count = false;
      show_indicators = true;
      
      # Icons
      icon_position = "left";
      min_icon_size = 32;
      max_icon_size = 48;
      icon_path = "/usr/share/icons/Papirus-Dark/16x16/status/:/usr/share/icons/Papirus-Dark/16x16/devices/:/usr/share/icons/Papirus-Dark/16x16/apps/";
      
      # History
      sticky_history = true;
      history_length = 20;
      
      # Misc/Advanced
      dmenu = "/usr/bin/dmenu -p dunst:";
      browser = "/usr/bin/firefox -new-tab";
      always_run_script = true;
      title = "Dunst";
      class = "Dunst";
      startup_notification = false;
      verbosity = "mesg";
      corner_radius = 12;
      ignore_dbusclose = false;
      force_xinerama = false;
      mouse_left_click = "close_current";
      mouse_middle_click = "do_action, close_current";
      mouse_right_click = "close_all";
    };

    experimental = {
      per_monitor_dpi = false;
    };

    urgency_low = {
      # More transparent backgrounds for glass effect
      background = "#1a202c80";  # Added alpha channel for transparency
      foreground = "#e2e8f0";
      timeout = 5;
      frame_color = "#ffffff15";
    };
    
    urgency_normal = {
      # Main macOS-style with increased transparency
      background = "#1a202c85";  # More transparent background
      foreground = "#ffffff";
      timeout = 8;
      frame_color = "#ffffff20";
    };
    
    urgency_critical = {
      # Critical notifications with transparency
      background = "#2d1b1b90";  # Slightly red-tinted transparent background
      foreground = "#ffffff";
      timeout = 0;
      frame_color = "#e53e3e60";
    };

    # Custom rules for specific applications
    spotify = {
      appname = "Spotify";
      background = "#1db95480";  # Added transparency
      foreground = "#ffffff";
      frame_color = "#1ed76040";
      timeout = 6;
    };

    discord = {
      appname = "Discord";
      background = "#5865f280";  # Added transparency
      foreground = "#ffffff";
      frame_color = "#7289da40";
      timeout = 8;
    };

    telegram = {
      appname = "Telegram";
      background = "#0088cc80";  # Added transparency
      foreground = "#ffffff";
      frame_color = "#229ed940";
      timeout = 8;
    };

    # Call-like notifications
    call_notification = {
      summary = "*call*";
      background = "#1a202c85";
      foreground = "#ffffff";
      frame_color = "#48bb7840";
      timeout = 0;
      format = "<b>📞 %s</b>\\n%b";
    };
    
    video_call = {
      summary = "*video*";
      background = "#1a202c85";
      foreground = "#ffffff";
      frame_color = "#4299e140";
      timeout = 0;
      format = "<b>📹 %s</b>\\n%b";
    };
  };

}
