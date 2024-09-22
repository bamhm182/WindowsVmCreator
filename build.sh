#! /usr/bin/env bash

for f in ./baselines/*.xml; do
    mkisofs -o ${f%.xml}.iso -input-charset utf-8 -Jr ${f}
done
