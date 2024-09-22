#! /usr/bin/env bash

for f in ./baselines/*; do
    [[ -d "${f}" ]] && mkisofs -o ${f}.iso -input-charset utf-8 -Jr ${f}/autounattend.xml
done
