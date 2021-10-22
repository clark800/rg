#!/bin/sh

esc="$(printf '\033')"
magenta="${esc}[35m"
cyan="${esc}[36m"
reset="${esc}[0m"
newline='
'

files() {
    # does not follow symlinks to avoid getting duplicate results and
    # since git ls-files does not support following symlinks
    if command -v git > /dev/null && git rev-parse 2> /dev/null; then
        git ls-files --cached --others --exclude-standard
    else
        find . -name ".?*" -prune -o -type f | sed 's|^\./||'
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
    sed "s/^[^:]*:[^:]*:/${magenta}&${reset}\\${newline}/"
}

highlight() {
    # highlights matching regions (may not work if grep flags like -i are used)
    # the first command skips location lines that are already colored
    # uses ascii substitute as sed delimiter since it's unlikely to be in regexp
    sed "/${esc}\\[0m$/b
         s$1${cyan}&${reset}g"
}

# only do formatting if stdout is a tty
if [ -t 1 ]; then
    for pattern in "$@"; do :; done  # get the last argument
    search "$@" | split | highlight "$pattern"
else
    search "$@"
fi
