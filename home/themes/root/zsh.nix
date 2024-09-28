_:
{
  programs.zsh = {
    initExtraFirst = ''
      PS1='[%n] %2~%# '
    '';
  };
}
