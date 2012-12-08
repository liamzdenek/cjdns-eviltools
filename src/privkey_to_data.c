/*
 * You may redistribute this program and/or modify it under the terms of
 * the GNU General Public License as published by the Free Software Foundation,
 * either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#include "crypto_scalarmult_curve25519.h"
#include "crypto_hash_sha512.h"
#include "util/Assert.h"
#include "util/Endian.h"
#include "util/log/Log.h"
#include "util/Bits.h"
#include "util/Hex.c"
#include "util/Base32.h"
#include "crypto/AddressCalc.c"
#include "crypto/Random.h"
#include "build/nacl/randombytes/devurandom.c"
#include "dht/Address.h"
#include <stdint.h>
#include <assert.h>
#include <unistd.h>
#include <stdio.h>0.

//gcc -std=gnu99 -Icjdns -Icjdns/build/nacl_build/include gen.c cjdns/build/nacl_build/libnacl.a -o gen.o

static int genAddress(uint8_t addressOut[40],
                      uint8_t privateKeyHexOut[65],
                      uint8_t publicKeyBase32Out[53],
                      uint8_t privateKey[32])
{
    struct Address address;

    //randombytes(privateKey, 32);
    crypto_scalarmult_curve25519_base(address.key, privateKey);
    AddressCalc_addressForPublicKey(address.ip6.bytes, address.key);
    // Brute force for keys until one matches FC00:/8
    if(
        address.ip6.bytes[0] == 0xFC// &&
        //(address.ip6.bytes[15] & 0xF) == (address.ip6.bytes[15] & 0x0F << 4) &&
        //address.ip6.bytes[14] == address.ip6.bytes[15]
    )
    {
        Hex_encode(privateKeyHexOut, 65, privateKey, 32);
        Base32_encode(publicKeyBase32Out, 53, address.key, 32);
        Address_printIp(addressOut, &address);
        return 1;
    }
    return 0;
}

int main(int argc, char *argv[])
{
    uint8_t AddressOut[40];
    uint8_t privateKeyHexOut[65];
    uint8_t publicKeyBase32Out[53];
    uint8_t privateKey[32];
    
    if(argc == 2)
    {
        // run FOREVAR with a new starting point
        for(uint8_t i = 0; i < 32; i++)
        {
            privateKey[i] = (argv[1][i*2]-48 << 4) + argv[1][i*2+1]-48;
        }
    }
    else
    {
        printf("Error: Incorrect number of arguments\n");
    }
    
    Hex_encode(privateKeyHexOut, 65, privateKey, 32);
 
    if(genAddress(AddressOut, privateKeyHexOut, publicKeyBase32Out, privateKey))
    {
        printf("%s\n", publicKeyBase32Out);
        //return 0;
    }
}