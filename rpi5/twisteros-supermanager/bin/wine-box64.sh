#!/bin/bash
BOX64_PATH=$(which box64)
WINE_PATH=$(which wine64)
$BOX64_PATH $WINE_PATH "$@"
