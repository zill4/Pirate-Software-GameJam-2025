#!/bin/bash
zig build -Doptimize=ReleaseFast \
    -Dlogging=false \
    -Dprofile=false \
    -Dvulkan-validation=false