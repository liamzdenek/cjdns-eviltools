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
#include <stdio.h>

#include "eviltools.c"

int main(int argc, char *argv[])
{
    uint8_t AddressOut[40];
    uint8_t privateKeyHexOut[65];
    uint8_t publicKeyBase32Out[53];
    uint8_t privateKey[32];
    uint32_t count = 0;
    
    if(argc == 2)
    {
        count = atoi(argv[1]);
    }
    else
    {
        printf("You must provide a number of keys to generate\n");
        exit(0);
    }
    
    while(1)
    {
        randombytes(privateKey, 32);
        if
        (
            (
                (uint8_t)(privateKey[0] & 248) == privateKey[0] ||
                (uint8_t)((privateKey[31] & 127) | 64) == privateKey[31]
            ) &&
            genAddress(AddressOut, privateKeyHexOut, publicKeyBase32Out, privateKey)
        )
        {
            Hex_encode(privateKeyHexOut, 65, privateKey, 32);
            printf("%s,%s\n", AddressOut, privateKeyHexOut);
            count--;
            if(count <= 0)
            {
                exit(0);
            }
        }
    }
}