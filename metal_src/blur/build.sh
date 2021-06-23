#!/bin/bash
set -e

name="blur"

xcrun --sdk iphoneos metal -c main.metal -o main.air
xcrun --sdk iphoneos metallib main.air -o main.metallib

cp main.metallib ../layout/var/mobile/Library/WiiAuto/Metals/$name/main.metallib