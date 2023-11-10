#!/bin/sh

ALL=""
ESC="$(printf '\033')"
MAGENTA="${ESC}[35m"
CYAN="${ESC}[36m"
RESET="${ESC}[0m"
NEWLINE='
'

files() {
    # does not follow symlinks to avoid getting duplicate results and
    # since git ls-files does not support following symlinks
    if [ "$ALL" ]; then
        find . -type f | sed 's|^\./||'
    elif command -v git > /dev/null && git rev-parse 2> /dev/null; then
        git ls-files --cached --others --exclude-standard
    else
        find . -name ".?*" -prune -o -type f -print | sed 's|^\./||'
    fi
}

quote() {
    paste -d'"' /dev/null - /dev/null
}

search() {
    # quote prevents xargs from splitting paths containing spaces
    # this approach is used because the -0 and -d xargs flags are not posix
    # paths containing double quotes are not supported
    # the /dev/null argument to grep ensures that grep prints file paths even
    # if just one file is given in an invocation
    files | quote | xargs grep -n "$@" /dev/null
}

split() {
    # splits locations onto separate lines and colors them
    sed "s/^[^:]*:[^:]*:/${MAGENTA}&${RESET}\\${NEWLINE}/"
}

highlight() {
    # highlights matching regions (may not work if grep flags like -i are used)
    # the first command skips location lines that are already colored
    # uses ascii substitute as sed delimiter since it's unlikely to be in regexp
    sed "/${ESC}\\[0m$/b
         s$1${CYAN}&${RESET}g"
}

main() {
    # does not parse all options because options are passed to grep
    case "$1" in
        --all) ALL=1; shift;;
    esac

    # only do formatting if stdout is a tty
    if [ -t 1 ]; then
        for pattern in "$@"; do :; done  # get the last argument
        search "$@" | split | highlight "$pattern"
    else
        search "$@"
    fi
}

main "$@"
