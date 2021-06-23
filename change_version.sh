#!/bin/bash
set -e

version="0.0.1"

input="control"
while IFS= read -r line
do
    if [[ $line = Version* ]]; then
        IFS=':' # space is set as delimiter
        read -ra ADDR <<< $line
        for i in "${ADDR[@]}"; do            
            Var=`echo $i | sed -e 's/^[[:space:]]*//'`            
            if [[ $Var != Version* ]]; then
                version=$Var
            fi
        done
    fi
done < "$input"

sed -i -e "s|__wiiauto_version__ = \"[0-9].*\"|__wiiauto_version__ = \"$version\"|g" ./src/wiiauto/version.c

echo "Version: $version"