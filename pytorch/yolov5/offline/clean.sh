#!/bin/bash
set -e

#clean test
shopt -s extglob
rm -rf output *.o yolov5_offline
rm -rf *.cambricon*
shopt -u extglob
