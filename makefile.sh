#!/usr/bin/sh
if [ ! -d "cjdns" ]; then
    echo "Please 'ln -s /source/to/your/cjdns/ cjdns' then re-run this script\n";
    exit;
fi
mkdir -p build;
echo 'Making procedural';
gcc -std=gnu99 -Iinclude -Icjdns -Icjdns/build/nacl_build/include src/procedural.c cjdns/build/nacl_build/libnacl.a -o bin/procedural;
echo 'Making random';
gcc -std=gnu99 -Iinclude -Icjdns -Icjdns/build/nacl_build/include src/random.c cjdns/build/nacl_build/libnacl.a -o bin/random;
echo 'Making privkey_to_pubkey';
gcc -std=gnu99 -Iinclude -Icjdns -Icjdns/build/nacl_build/include src/privkey_to_data.c cjdns/build/nacl_build/libnacl.a -o bin/privkey_to_data;