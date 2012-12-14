static int genAddress(uint8_t addressOut[40],
                      uint8_t privateKeyHexOut[65],
                      uint8_t publicKeyBase32Out[53],
                      uint8_t privateKey[32])
{
    struct Address address;

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

void increment_privkey( uint8_t string[32] )
{
    for(uint8_t i = 0; i < 32; i++)
    {
        if(string[i] == 0xFF)
        {
            string[i] = 0x00;
        }
        else
        {
            string[i]++;
            break;
        }
    }
    return;
}