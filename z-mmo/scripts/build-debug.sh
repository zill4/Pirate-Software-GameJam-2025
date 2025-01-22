#!/bin/bash
zig build -Doptimize=Debug \
    -Dlogging=true \
    -Dprofile=true \
    -Dvulkan-validation=true