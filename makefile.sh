#!/usr/bin/sh
if [ ! -d "cjdns" ]; then
    echo "Please 'ln -s /source/to/your/cjdns/ cjdns' then re-run this script\n";
    exit;
fi
mkdir build;
echo 'Making gen';
gcc -std=gnu99 -Icjdns -Icjdns/build/nacl_build/include src/gen.c cjdns/build/nacl_build/libnacl.a -o bin/gen;
echo 'Making privkey_to_pubkey';
gcc -std=gnu99 -Icjdns -Icjdns/build/nacl_build/include src/privkey_to_data.c cjdns/build/nacl_build/libnacl.a -o bin/privkey_to_data;

