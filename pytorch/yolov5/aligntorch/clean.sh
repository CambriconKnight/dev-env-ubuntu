#!/bin/bash
set -e

#clean test
shopt -s extglob
rm -rf output weights
shopt -u extglob
