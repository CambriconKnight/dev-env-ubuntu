#!/bin/bash
set -e

#clean test
shopt -s extglob
rm -vf !(*.sh)
shopt -u extglob
