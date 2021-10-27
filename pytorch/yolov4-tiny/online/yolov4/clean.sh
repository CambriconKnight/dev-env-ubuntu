#!/bin/bash
set -e

#clean test
shopt -s extglob
rm -rf model/*.weights*
rm -rf model/*.cfg*
rm -rf ../../pytorch_models/int8/checkpoints/*.pth*
rm -rf ../../pytorch_models/int16/checkpoints/*.pth*
rm -rf ../../pytorch_models/origin/checkpoints/*.pth*
shopt -u extglob

