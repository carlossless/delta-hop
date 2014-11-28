#!/bin/bash

export SCRIPT_DIR=$(dirname "%0")

mocha $(find "$SCRIPT_DIR/tests" -name '*.js')
