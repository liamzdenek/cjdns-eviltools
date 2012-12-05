#!/usr/bin/sh
if [ ! -d "cjdns" ]; then
    echo "Please 'ln -s /source/to/your/cjdns/ cjdns' then re-run this script\n";
    exit;
fi
gcc -std=gnu99 -Icjdns -Icjdns/build/nacl_build/include gen.c cjdns/build/nacl_build/libnacl.a -o gen
