let
  pkgs = import <nixpkgs> {};
in
(pkgs.writeShellScriptBin "touchp"
  ''
    declare -r OK=0
    declare -r NOK=1 #funny

    getopt_result=`(getopt -oacdfhmrt -lno-create,date,no-dereference,reference,time,help,version -- $@) 2> /dev/null`
    if [ $? -eq $OK ];
    then
      # TODO: Quoted strings with multiple words aren't
      # treated as one argument. I hate bash scripting.
      sorted_args=(`xargs <<< "$getopt_result"`)
      create=$OK
      index=0
      while [ -n "''${sorted_args[$index]}" ] \
        && [ ":''${sorted_args[$index]}" != ":--" ];
      do
        arg=''${sorted_args[$index]}
        if [ ":$arg" = ":-c" ] || [ ":$arg" = ":--no-create" ] \
          || [ ":$arg" = ":-h" ] || [ ":$arg" = ":--no-dereference" ] \
          || [ ":$arg" = ":--help" ] || [ ":$arg" = ":--version" ];
        then
          create=$NOK
          break
        fi
        let "index+=1"
      done

      if [ $create -eq $OK ];
      then
        # Ignore '--'.
        let "index+=1"
        # Create parent directories if they don't exist.
        while [ -n "''${sorted_args[$index]}" ];
        do
          mkdir -p -- "$(dirname "''${sorted_args[$index]}")"
          let "index+=1"
        done
      fi
    fi

    touch $@
  '')
