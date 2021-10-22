rg
==
`rg` is a simple POSIX shell script to perform recursive grep searches with
formatted and colorized output. It is a minimalist alternative to ripgrep.

The usage is like that of `grep` except that you do not specify paths to
search; it always searches the current directory. It will ignore files and
directories specified in the `.gitignore` file if it is run from a git
directory.
