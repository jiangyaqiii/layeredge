#!/bin/bash

if screen -list | grep -q layer; then
    echo "运行中"
else
    echo "停止"
fi
