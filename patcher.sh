#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function patcher_main () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SGD_HEAD='# Super Grub Disk - '

  local -A CFG=(
    [orig]='orig.iso'
    [dest]='custom.iso'
    [action]='where'
    [bufsz]=16000
    [nullbytes]=$'\x7F'
    )

  local ARG= OPT=
  while [ "$#" -ge 1 ]; do
    ARG="$1"; shift
    OPT="${ARG#--}"; OPT="${OPT//-/_}"
    case "$ARG" in
      --patch | \
      --where-file | \
      --where-text | \
      --extract ) CFG[action]="$OPT";;
      --bufsz | \
      --orig | --dest ) CFG["$OPT"]="$1"; shift;;
      --inplace ) CFG[orig]="$1"; CFG[dest]="$1"; shift;;
      --restore )
        echo -n 'D: restore: '
        cp --no-target-directory --verbose  --no-preserve=mode \
          -- "${CFG[orig]}" "${CFG[dest]}" || return $?;;
      --offsets )
        grep -aboPe "$SGD_HEAD"'\S+\.\S+' -- "${CFG[orig]}" | sed -nre '
          s~:'"$SGD_HEAD"'~\t~p'; return $?;;
      --reupload )
        echo -n "D: $OPT '${CFG[dest]}' onto '$1': "
        sudo dd bs=1024 {skip,seek}=32 conv=notrunc \
          if="${CFG[dest]}" of="$1" || return $?
        shift;;
      -* ) echo "E: unsupported option: $ARG" >&2; return 3;;
      * ) acn_"${CFG[action]}" "$ARG" || return $?;;
    esac
  done
}


function acn_where_file () { acn_where_text "$SGD_HEAD$1"; }


function acn_where_text () {
  local WHAT="$1"
  [ -n "$WHAT" ] || return 6$(echo "E: no search string given" >&2)
  local OFFS="$(grep -aboFe "$WHAT" -- "${CFG[orig]}" | cut -d : -sf 1)"
  case "$OFFS" in
    *'\n'* )
      echo "E: found too many instances of '$WHAT': ${OFFS//$'\n'/ }" >&2
      return 4;;
    [0-9]* )
      echo "$OFFS"
      return 0;;
  esac
  echo "E: cannot find '$WHAT'" >&2
  return 3
}


function acn_extract () {
  local FN="$1"
  local OFFS="$(acn_where_file "$FN")"
  [ -n "$OFFS" ] || return 5
  local DEST="$FN".orig
  local NULB="${CFG[nullbytes]}"
  local BUF="$(dd bs=1 skip="$OFFS" if="${CFG[orig]}" status=none \
    count="${CFG[bufsz]}" | tr '\000' "$NULB"
    echo :)"
  BUF="${BUF%:}"
  local NUL_BYTE=$'\x00'
  local TRIMMED="${BUF%%"$NULB"[^"$NULB"]*}"
  if [ -n "$TRIMMED" ]; then
    BUF="$TRIMMED$NULB"
    TRIMMED=
  fi
  echo "D: extract '$FN' (${#BUF} bytes) as '$DEST'"
  echo -n "$BUF" | tr "$NULB" '\000' >"$DEST" || return $?
}


function acn_patch () {
  local PATCH="$1"
  [ "$PATCH" == - ] || exec <"$PATCH" || return 3$(
    echo "E: failed to read $PATCH" >&2)
  local INTRO=
  IFS= read -r INTRO
  local OFFS="$(acn_where_text "$INTRO")"
  [ -n "$OFFS" ] || return 5$(
    echo "E: cannot detect where to apply patch '$PATCH'" >&2)
  # use cat to ensure stdin is not seekable, to avoid re-reading line 1.
  echo -n "D: gonna write patch '$PATCH' into '${CFG[dest]}' at offset $OFFS"
  printf ' (0x%0X): ' "$OFFS"
  cat | dd bs=1 seek="$OFFS" of="${CFG[dest]}" \
    status=none conv=notrunc || return $?
  echo 'done.'
}










patcher_main "$@"; exit $?
