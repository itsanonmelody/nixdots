{ ... }:
{
  hjem.users.dev.files = {
    ".config/kitty/kitty.conf" = {
      text =
        ''
          globinclude kitty.d/**/*.conf

          confirm_os_window_close 0
        '';
    };
  };
}
