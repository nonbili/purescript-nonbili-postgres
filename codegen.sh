#!/bin/bash

# From https://unix.stackexchange.com/a/61146
sed -n '/^```purescript/,/^```/ p' \
    < README.md \
    | sed 's/^```.*//' > test/Main.purs
