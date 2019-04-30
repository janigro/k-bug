#!/bin/bash

swift build --build-path .build-linux -Xswiftc -DNOJSON -Xcc -I/usr/include/mysql && ./.build-linux/debug/k-bug
