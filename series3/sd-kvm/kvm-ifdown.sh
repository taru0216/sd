#!/bin/sh

# Debug
if test "x$DOCKERTIPS3_DEBUG" != "x"; then
  set -x
fi

ifconfig $1 down
