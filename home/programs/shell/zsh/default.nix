_:
{
  programs.zsh = {
    enable = true;
    initExtraFirst = ''
      PS1='[%n@%m] %2~%# '
    '';
  };
}
