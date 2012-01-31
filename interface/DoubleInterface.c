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
#include "interface/Interface.h"
#include "wire/Message.h"


static uint8_t transferMessage(struct Message* msg, struct Interface* iface)
{
    struct Interface* other = (struct Interface*) iface->receiverContext;
    return other->sendMessage(msg, other);
}

/**
 * Create a new DoubleInterface which will relay traffic back and forth between two interfaces.
 *
 * @param a one interface.
 * @param b another interface.
 */
struct DoubleInterface* DoubleInterface_new(struct Allocator* allocator)
{
    struct DoubleInterface* out = allocator->malloc(sizeof(struct DoubleInterface), allocator);
    memcpy(out, (&(struct DoubleInterface) {
        .a.sendMessage = transferMessage,
        .a.senderContext = &out->b,
        .b.sendMessage = transferMessage,
        .b.senderContext = &out->a
    }));
    return out;
}
