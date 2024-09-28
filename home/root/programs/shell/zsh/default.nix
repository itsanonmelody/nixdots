_:
{
  programs.zsh = {
    enable = true;
    initExtraFirst = ''
      PS1='[%n] %2~%# '
    '';
  };
}
