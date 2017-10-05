#!/bin/sh

export CHEZSCHEMELIBDIRS="nanopass:."

# Homebrew on macOS installs the chezscheme executable as 'chez',
# but the upstream build calls it 'scheme'
if command -v scheme > /dev/null 2 >&1; then
    CHEZ="scheme"
else
    CHEZ="chez"
fi

echo '(load "bfcwasm.ss") (compile-file "'$1'")' | $CHEZ -q > bfprog.wat
