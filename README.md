# ccipher
A pure POSIX implementation of classical ciphers. This vibe coding project was done for fun to see how much can be accomplished without bashisms.
All of these ciphers are considered broken so don't use them for anything serious.

## Supported Ciphers
- **Substitution**: Caesar, ROT13, Atbash, Affine, Simple Substitution, Monoalphabetic Substitution
- **Polyalphabetic**: Vigenère, Autokey, Beaufort, Gronsfeld, Porta, Trithemius
- **Polybius Square**: Polybius, Nihilist, ADFGVX
- **Transposition**: Rail Fence, Columnar
- **Bigraphic**: Playfair, Four-Square, Bifid
- **Matrix**: Hill
- **Steganographic**: Bacon
- **Complex**: VIC (straddling checkerboard with double transposition)

## Usage
```
Usage: ./ccipher.sh -c cipher -m mode -t text [options]

Ciphers: adfgvx, affine, atbash, autokey, bacon, beaufort, bifid, caesar,
         columnar, foursquare, gronsfeld, hill, nihilist, playfair, polybius,
         porta, railfence, rot13, simple, substitution, trithemius, vigenere, vic

mode: encrypt or decrypt
text: text to be encrypted or decrypted

Options:
  -s shift    Caesar shift value (default: 3)
  -a a        Affine multiplier (default: 5)
  -b b        Affine additive (default: 8)
  -k key      Key for keyed ciphers (default: KEY)
  -2 key2     Second key for Four-Square cipher
  -q keysq    Keysquare for ADFGVX cipher

VIC cipher options:
  -d date     6-digit date (e.g., 070476 for July 4, 1776)
  -p personal Personal number (1-2 digits)
  -i indicator 5-digit message indicator
```

## Examples

### ROT13 (Simple Substitution)
```
./ccipher.sh -c rot13 -m encrypt -t canyouhearmenow
pnalbhurnezrabj

./ccipher.sh -c rot13 -m decrypt -t pnalbhurnezrabj
canyouhearmenow
```

### ADFGVX (Polybius Square with Transposition)
```
./ccipher.sh -c adfgvx -m encrypt -t CLASSICALCIPHERSAREFUN -k CLASSIC -q UCP3WHLIF5OXEDJ2KY19VQNAR8SBGT7ZM640
DFDFVAAFGDVAGVDDAVAXADFXADVXAAFVADAAFDGDAXGF

./ccipher.sh -c adfgvx -m decrypt -t DFDFVAAFGDVAGVDDAVAXADFXADVXAAFVADAAFDGDAXGF -k CLASSIC -q UCP3WHLIF5OXEDJ2KY19VQNAR8SBGT7ZM640
CLASSICALCIPHERSAREFUN
```

### VIC Cipher (Complex Soviet Cipher)
The VIC cipher is one of the most complex hand ciphers ever devised, used by Soviet spies during the Cold War. It combines:
- Straddling checkerboard for efficient encoding
- Double columnar transposition
- Key derivation from multiple sources

```
# Encrypt
./ccipher.sh -c vic -m encrypt -t "HELLO WORLD" \
    -k "THISISAVERYLONGKEYPHRASE" \
    -d 123456 -p 7 -i 76543

# Decrypt
./ccipher.sh -c vic -m decrypt -t "CIPHERTEXT" \
    -k "THISISAVERYLONGKEYPHRASE" \
    -d 123456 -p 7 -i 76543
```

VIC cipher parameters:
- `-k keyphrase`: At least 20 characters (used for key derivation)
- `-d date`: 6-digit date (e.g., 071177 for July 11, 1977)
- `-p personal`: 1-2 digit personal number
- `-i indicator`: 5-digit random message indicator

### Vigenère (Polyalphabetic)
```
./ccipher.sh -c vigenere -m encrypt -t ATTACKATDAWN -k LEMON
LXFOPVEFRNHR

./ccipher.sh -c vigenere -m decrypt -t LXFOPVEFRNHR -k LEMON
ATTACKATDAWN
```

### Playfair (Bigraphic)
```
# Note: Playfair adds 'X' for double letters and odd lengths
./ccipher.sh -c playfair -m encrypt -t HIDE -k SECRETKEY
LOFEHXDWSE

./ccipher.sh -c playfair -m decrypt -t LOFEHXDWSE -k SECRETKEY
HIDEX
```

## Notes
- VIC cipher supports letters, spaces, and digits
- VIC cipher requires minimum message length for proper transposition
- Hill cipher requires a key matrix with determinant coprime to 26
- ADFGVX requires a 36-character keysquare
- Playfair handles double letters by inserting 'X'