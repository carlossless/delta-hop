#!/bin/bash

export SCRIPT_DIR=$(dirname "$0")

mongod --dbpath $SCRIPT_DIR/db/