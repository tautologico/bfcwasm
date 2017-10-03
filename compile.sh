#!/bin/sh

echo '(load "bfcwasm.ss") (compile-file "'$1'")' | chez -q
