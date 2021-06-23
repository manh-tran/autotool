#!/bin/bash
set -e

name="cpy"

xcrun --sdk iphoneos metal -c main.metal -o main.air
xcrun --sdk iphoneos metallib main.air -o main.metallib

mkdir -p ../../layout/var/mobile/Library/WiiAuto/Metals/$name
cp main.metallib ../../layout/var/mobile/Library/WiiAuto/Metals/$name/main.metallib