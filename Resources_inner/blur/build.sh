#!/bin/bash
set -e

xcrun --sdk iphoneos metal -c main.metal -o main.air
xcrun --sdk iphoneos metallib main.air -o main.metallib