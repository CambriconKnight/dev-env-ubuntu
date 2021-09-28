#!/bin/bash
set -e

#clean test
shopt -s extglob
rm -rf *_result*
rm -rf *.cambricon*
rm -rf *_quant.pth
shopt -u extglob
