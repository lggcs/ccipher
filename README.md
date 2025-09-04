# ccipher
A pure POSIX implementation of classical ciphers. This vibe coding project was done for fun to see how much can be accomplished without bashisms.
All of these ciphers are consider broken so don't use them for anything serious.

## Usage
```
Usage: ./ccipher.sh -c cipher -m mode -t text [-s shift] [-a a] [-b b] [-k key] [-q keysquare]
cipher: adfgvx, affine, atbash, beaufort, caesar, hill, nihilist, playfair, railfence, rot13, trithemius,
or vigenere
mode: encrypt or decrypt
text: text to be encrypted or decrypted
shift: shift value for Caesar Cipher (default: 3)
a: multiplier value for Affine Cipher (default: 5)
b: additive value for Affine Cipher (default: 8)
key: key for Playfair, Vigenère, Railfence, ADFGVX, or Nihilist Ciphers
keysquare: keysquare for ADFGVX Cipher (If one is not provided it can generate one for you to use)
```

## Examples
Here are two examples showing how the script works for a simple  and more complex classical cipher.


ROT13 Encode
```
./ccipher.sh -c rot13 -m encrypt -t canyouhearmenow
pnalbhurnezrabj
```
ROT 13 Decode
```
./ccipher.sh -c rot13 -m decrypt -t pnalbhurnezrabj
canyouhearmenow
```



ADFGVX Encode
```
./ccipher.sh -c adfgvx -m encrypt -t CLASSICALCIPHERSAREFUN -k CLASSIC -q UCP3WHLIF5OXEDJ2KY19VQNAR8SBGT7ZM640
DFDFVAAFGDVAGVDDAVAXADFXADVXAAFVADAAFDGDAXGF
```
ADFGVX Decode
```
./ccipher.sh -c adfgvx -m decrypt -t DFDFVAAFGDVAGVDDAVAXADFXADVXAAFVADAAFDGDAXGF -k CLASSIC -q UCP3WHLIF5OXEDJ2KY19VQNAR8SBGT7ZM640
CLASSICALCIPHERSAREFUN

```
