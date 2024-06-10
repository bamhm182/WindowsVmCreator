#! /usr/bin/env bash

for f in ./baselines/*.xml; do
    mkisofs -o ${f%.xml}.iso -Jr ${f}
done
