# Implementation of BIP 380 CLI

Your task is to implement a command line application `bip380` that will wrap
around an existing library implementing Hierarchical Deterministic Wallets,
i.e., [Bitcoin Improvement Proposal
32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) and further
implement parts of the [Bitcoin Improvement Proposal
380](https://github.com/bitcoin/bips/blob/master/bip-0380.mediawiki). You are
not expected to implement BIP 32 functionality, but oursource it to previously vetted
libraries, see the current list below. In case you'd find another library that
you want to use instead, ask first.

## Background on keys and Bitcoin scripts

Bitcoins are spendable by the ability to create so called scripts that are built on
top of private and public cryptographic keys. In the following specification
you are going to handle these keys and scripts. The required level of
understanding the underlying cryptography is very minimal. It's enough to
inuitively understand that a valid private and public keys come in pairs.
Private key needs to be kept secret and public key can be shared. Both keys
_appear_ random, in particular, master private keys are directly derived from
securely generated random bytes and the public keys are computed from the
private ones.

BIP 32 defines a way how to derive new keys (a chain or tree of keys) from
existing ones. These keys are reffered to as extended keys. While there are
rules to this extensions, extended key can be further extended. When one has an
access to a private key, it's possible to derive any child keys (both hardened
and non-hardened), however, from public keys only non-hardened keys can be
derived. That's because the private key is needed for the hardened derivation.
This derivation and key handling functionality is already implemented within
the libraries that your code will wrap around. Thus, part of your task is only
about using these libraries.

Finally, once you grasp handling of these extended keys you will implement some
parsing of, so called, _output script descriptors_, i.e., a simple language that
uses the aforementioned keys to build more complex structures for passing
around Bitcoins securely. Any code that handles the keys and scripts is critical,
because mistakes could lead to loss of Bitcoins, therefore there are checksums,
that try to catch at least some of the mistakes. Implementing such checksums will
be your final task.

Altogether, you can see the private and public keys as some special data that you
will parse, derive and check.

## Help message `--help`

The option `--help` displays a descriptive help message regarding
the sub-comands and flags. When `--help` is used it takes precendence over any
other command-line arguments, options or functionality, and the help message is
displayed and the exit code is `0`. The contents of the help are left unspecified,
but we expect a reasonable level of detail that describes the sub-commands,
arguments and options. A single help message for all sub-commands is enough.

Example usage:
```bash
$ ./bip380 --help
...help message...
$ ./bip380 derive-key --help
...help message...
$ ./bip380 --help derive-key
...help message...
$ echo "000102030405060708090a0b0c0d0e0f" | ./bip380 derive-key - --help
...help message...
```

### Sub-command `derive-key`

```
derive-key {value} [--path {path}] [-]
```

The `derive-key` sub-command takes one required positional  argument `{value}`
(with one exception, see below), which can be either a seed, or Base58 encoded
extended public `{xpub}` or private key `{xpriv}` (as described in
[BIP 32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#serialization-format)).
Depending on the type of the input `{value}` the utility outputs certain extended keys.

 - On input seed, outputs the master private and public key.
 - On input extended private key, outputs the extended private key, i.e., _echos_
   itself, and the corresponding extended public key.
 - On input extended public key, outputs the extended public key, i.e., _echos_
   itself.

The output format is `{xpub}:{xpriv}` or `{xpub}:` if the extended private key
cannot be derived.

Valid seed `{value}` is a byte sequence of length between 128 and 512 bits
represented as case-insensitive hexadecimal values. The space character `' '`
or the tab character `	` (sometimes denoted as `'\t'`) can be used to separate
the individual hexadecimal values. Note that extended public and private keys
cannot be split by any whitespace. The allowed seed lengths can be further
constrained by the underlying BIP 32 library that you are using --- if so,
mention the valid lengths in the help and the project's README file.

If a single dash `'-'` parameter is present, it indicates reading the `{value}`
from the standard input. Reading from the standard input takes precendence over
`{value}` provided as a command-line argument (in that case the `{value}`
argument can be omitted or is ignored). When reading from standard input, each
line (separated by a single line feed `\n` on Linux or prepended with carriage return `\r\n`
on Windows, but the utility can support both) of the file is processed as a
single `{value}` with all the previous rules on `{value}` still applicable.
Empty lines, i.e., when `\n` is repeated, shall be skipped over.

Optionally, the `--path {path}` argument specifies the _derivation path_, as
referred to in BIP 380 (or _chain_, as referred to in BIP 32) to derive new
extended private and public keys from. The key derivation starts from:

 - the master extended private and public keys if a seed was provided,
 - the extended private or public key itself (if extended public key is
  provided, only non-hardened paths can be derived).

If multiple lines are processed from the standard input and the `{path}` is present
then it is used to derive new keys for every value.

The `{path}` value is a sequence of `/NUM` and `/NUMh`, where `NUM` is from the range
`[0,...,2^31-1]` as described in
[BIP 32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#extended-keys).
The path does not need to start with `/`. In the hardened version `/NUMh` the
`h` indentifier can also be substituted with `H` or `'` and these can also be
mixed within a single path. Parsing and normalizing the `{path}` value
correctly for the underlying library is your task, however correctness of the
`{path}` is left to the library. Trailing slash(es) `/` are not allowed.


Examples of valid paths:
```text
0
0/1
/0/1
/0H/1/2H/2/1000000000
/0H/1/2h/2/1000000000
/0H/1/2'/2/1000000000
/0/2147483647H/1
/0/2147483647H/1/2147483646H/2
```

Example of invalid paths:
```
/
1/
a
//
/2147483648
```

The `derive-key` sub-command returns exit code `0` if there were no errors
during the whole execution. Otherwise, non-zero exit code is returned. If
multiple lines are processed from the standard input, and during the
processing of the nth line there is an error, the utility still prints out the
expected outputs up to the (n-1)th input and then errors out with non-zero exit code.

Whenever the utility returns non-zero exit code a descriptive (single line is
enough) error message must be displayed. In case the error comes from the
used BIP 32 library, you can just pass the original error.

Example valid invocations:
```bash
$ ./bip380 derive-key 000102030405060708090a0b0c0d0e0f
xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8:xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi

$ ./bip380 derive-key "00 0102030405060708090a0b0c0d0e0f"
xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8:xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi

$ ./bip380 derive-key "00   01	02030405060708090a0b0c0d0e0f"
xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8:xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi

$ echo -e "00   01\t02030405060708090a0b0c0d0e0f" | ./bip380 derive-key -
xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8:xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi

$ ./bip380 derive-key "00 0102030405060708090A0B0c0d0E0F"
xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8:xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi

$ ./bip380 derive-key fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542
xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB:xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U

$ echo "000102030405060708090a0b0c0d0e0f" | ./bip380 derive-key -
xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8:xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi

$ ./bip380 derive-key - << EOF
000102030405060708090a0b0c0d0e0f
fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542
EOF
xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8:xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi
xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB:xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U

$ ./bip380 derive-key - << EOF
000102030405060708090a0b0c0d0e0f
fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542


xx
EOF
xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8:xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi
xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB:xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U
Error: non-hexadecimal seed value 'xx'

$ ./bip380 derive-key xpub6D4BDPcP2GT577Vvch3R8wDkScZWzQzMMUm3PWbmWvVJrZwQY4VUNgqFJPMM3No2dFDFGTsxxpG5uJh7n7epu4trkrX7x7DogT5Uv6fcLW5 --path 2/1000000000
xpub6H1LXWLaKsWFhvm6RVpEL9P4KfRZSW7abD2ttkWP3SSQvnyA8FSVqNTEcYFgJS2UaFcxupHiYkro49S8yGasTvXEYBVPamhGW6cFJodrTHy:

$ ./bip380 derive-key xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs --path 2H/2/1000000000
xpub6H1LXWLaKsWFhvm6RVpEL9P4KfRZSW7abD2ttkWP3SSQvnyA8FSVqNTEcYFgJS2UaFcxupHiYkro49S8yGasTvXEYBVPamhGW6cFJodrTHy:xprvA41z7zogVVwxVSgdKUHDy1SKmdb533PjDz7J6N6mV6uS3ze1ai8FHa8kmHScGpWmj4WggLyQjgPie1rFSruoUihUZREPSL39UNdE3BBDu76

$ ./bip380 derive-key --path 2H/2/1000000000 xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs
xpub6H1LXWLaKsWFhvm6RVpEL9P4KfRZSW7abD2ttkWP3SSQvnyA8FSVqNTEcYFgJS2UaFcxupHiYkro49S8yGasTvXEYBVPamhGW6cFJodrTHy:xprvA41z7zogVVwxVSgdKUHDy1SKmdb533PjDz7J6N6mV6uS3ze1ai8FHa8kmHScGpWmj4WggLyQjgPie1rFSruoUihUZREPSL39UNdE3BBDu76
```

Examples of invalid invocations (with an example error message):
```bash
$ ./bip380 derive-key xpub661MyMwAqRbcEYS8w7XLSVeEsBXy79zSzH1J8vCdxAZningWLdN3zgtU6LBpB85b3D2yc8sfvZU521AAwdZafEz7mnzBBsz4wKY5fTtTQBm
Error: pubkey version / prvkey mismatch
$ ./bip380 derive-key xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHL
Error: invalid checksum
$ ./bip380 derive-key 00\r0102030405060708090a0b0c0d0e0f
Error: invalid seed
$ ./bip380 derive-key "0	0 0 1 02030405060708090a0b0c0d0e0f"
Error: invalid seed
```

All of these examples come from the [BIP 32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vector-5) test vectors. You are encouraged to create your own.


### Sub-command `key-expression`

```
key-expression {expr} [-]
```

The `key-expression` parses the `{expr}` according to the
[BIP 380 Key
Expressions](https://github.com/bitcoin/bips/blob/master/bip-0380.mediawiki#key-expressions)
specification. If there are no parsing errors, the key expression is
_echoed_ back on a single line with `0` exit code. Otherwise, the utility
errors out with a non-zero exit code and outputs a descriptive error message
(single line is enough).

Valid examples:
```
$ ./bip380 key-expression 0260b2003c386519fc9eadf2b5cf124dd8eea4c4e68d5e154050a9346ea98ce600
0260b2003c386519fc9eadf2b5cf124dd8eea4c4e68d5e154050a9346ea98ce600
$ ./bip380 key-expression [deadbeef/0h/1h/2]xprvA1RpRA33e1JQ7ifknakTFpgNXPmW2YvmhqLQYMmrj4xJXXWYpDPS3xz7iAxn8L39njGVyuoseXzU6rcxFLJ8HFsTjSyQbLYnMpCqE2VbFWc/3h/4h/5h/*h
[deadbeef/0h/1h/2]xprvA1RpRA33e1JQ7ifknakTFpgNXPmW2YvmhqLQYMmrj4xJXXWYpDPS3xz7iAxn8L39njGVyuoseXzU6rcxFLJ8HFsTjSyQbLYnMpCqE2VbFWc/3h/4h/5h/*h
```

For other examples see the `Valid expressions:` and `Invalid expressions:` lists from
the BIP 380's [test
vectors](https://github.com/bitcoin/bips/blob/master/bip-0380.mediawiki#test-vectors).

If a single dash `'-'` parameter is present, it indicates reading the `{expr}`
from the standard input. Similar rules as described for the previous
`derive-key` sub-command apply, such as, the standard input takes precendence and is
processed line by line, etc.

The key expression consists of the optional key origin information and then the
actual key. Regarding the key types (as described in [BIP
380](https://github.com/bitcoin/bips/blob/master/bip-0380.mediawiki#key-expressions)):

 - The utility will accept _any_ hex encoded public keys that conform to the
   single-byte prefix (`02, 03` or `04`) and length (`66` or `130`) constraints
   (no further checking is required).
 - Wallet Import Format (WIF) encoded private keys parsing and checking, see
   [this wiki page](https://en.bitcoin.it/wiki/Wallet_import_format), will be
   implemented by the `bip380` utility itself. Use existing standard or 3rd
   party libraries for SHA-256 hash function and Base58 encoding
   implementations. Only expected WIF encoded private keys, are private keys
   originating as random 32 bytes and encoded using the `Private key to WIF`
   routine (from the previous links). Also, the first byte in the 4th step in
   `WIF to private key` routine is expected to be `0x80`. The comments about
   Electrum, SegWit or (un)compressed public keys can be ignored and such cases
   are deemed errorneous.
 - Finally, extended public and private keys must be checked using the same BIP
   32 library that you were using in `derive-key` already.

While BIP 380 further describes deriving child keys before providing output
scripts, this is not part of this specification as the application won't create
any final output scripts. Similarly, no [normalization](https://github.com/bitcoin/bips/blob/master/bip-0380.mediawiki#normalization-of-key-expressions-with-hardened-derivation) is needed.

### Sub-command `script-expression`

```
script-expression {expr} [-]
```

The `script-expression` sub-command implements parsing of some of the script
expressions and optionally also checksum verification and calculation. Here, we
divert from the BIP 380 --- the format and verification of the script
expressions is the same, but no final scripts are produced. The expected
format of `{expr}` is described in [BIP
380](https://github.com/bitcoin/bips/blob/master/bip-0380.mediawiki#specification)
specification and it is `SCRIPT#CHECKSUM`, where the `SCRIPT` can have one of
the following formats (not everything from BIP 380 and the following bips is
supported):

```text
pk(KEY)
pkh(KEY)
multi(k, KEY_1, KEY_2, ..., KEY_n)
sh(pk(KEY))
sh(pkh(KEY))
sh(multi(k, KEY_1, KEY_2, ..., KEY_n))
raw(HEX)
```

where:

 - `KEY` and `KEY_X` are the key expressions as described in the
   `key-expression` sub-command.
 - `HEX` is any valid case-sensitive hexadecimal string
 - Whitespace character `' '` can appear any number of times except
   within key expressions and the following literals `pk, pkh, multi, sh` and
   `raw`
 - The `multi(k, KEY_1, KEY_2,...., KEY_n)` script expression apart from
   handling multiple key expressions can also fail if the integer `k` is less
   than `0` or greater than `n`.

The checksum is optional, more on that below. The octothorpe character `#` is a
literal and the `CHECKSUM` is described in [BIP
380](https://github.com/bitcoin/bips/blob/master/bip-0380.mediawiki#checksum).

Note, we deviate from the intended usage of script expressions to create a
final scripts and instead the `script-expression` sub-command does the
following.

If the option `--verify-checksum` is used, then the checksum is expected and is
verified by recalculating the checksum over `SCRIPT` (everything up to, not
including the octothorpe `#`). The output is `OK` if the checksum verifies and
an error message is printed (single line is enough) otherwise.

If the option `--compute-checksum` is used, then the `#CHECKSUM`, if provided,
is ignored (no matter its correctness) and new `CHECKSUM` is computed. The
output is then the original script and the checksum in the form
`SCRIPT#CHECKSUM`.

Mixing `--verify-checksum` and `--compute-checksum` options leads to an error.
If neither `--verify-checksum` nor `--compute-checksum` are specified, the
utility does only parsing of `SCRIPT#CHECKSUM`. The `#CHECKSUM` part is
optional, but if provided, must be of the correct length. The utility simply
_echos_ the `{expr}` in case of no parsing errors, otherwise prints descriptive
error message (single line is enough) and returns non-zero exit code.


Examples:

```bash
$ ./bip380 script-expression --verify-checksum "raw(deadbeef)#89f8spxm"
OK
$ ./bip380 script-expression --verify-checksum "raw( deadbeef )#985dv2zl"
OK
$ ./bip380 script-expression --verify-checksum "raw(DEADBEEF)#49w2hhz7"
OK
$ ./bip380 script-expression --verify-checksum "raw(DEAD BEEF)#qqn7ll2h"
OK
$ ./bip380 script-expression --verify-checksum "raw(DEA D BEEF)#egs9fwsr"
OK
$ ./bip380 script-expression --verify-checksum "raw(deadbeef)"
Error: no checksum
$ ./bip380 script-expression --compute-checksum "raw(deadbeef)#xxx"
raw(deadbeef)#89f8spxm
$ ./bip380 script-expression --compute-checksum pkh(xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8)
pkh(xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8)#vm4xc4ed
$ ./bip380 script-expression --compute-checksum "pkh(   xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8)"
pkh(   xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8)#ujpe9npc
$ ./bip380 script-expression --compute-checksum "multi(2, xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8, xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB)#5jlj4shz"
multi(2, xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8, xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB)#5jlj4shz
$ ./bip380 script-expression --verify-checksum --compute-checksum "raw(deadbeef)"
Error: use only '--verify-checksum' or '--compute-checksum', not both
```

If a single dash `'-'` parameter is present, it indicates reading the `{expr}`
from the standard input. Similar rules as described for the previous
`derive-key` sub-command apply, such as, the standard input takes precendence
and is processed line by line, etc.


## Programming language-specifics

Use only standard libraries and vetted 3rd party libraries. However, if the
standard library provides extra functionality for parsing command line
arguments, e.g., implementing optional flags and such, then this is excluded.
If unclear, feel free to ask. That is, implement your own command line argument
parsing --- it does not have to a be general one, but simply suit the needs of
this specification. For unit and other testing you can use other libraries and
even other languages, both is highly recommended.

#### BIP 32 libraries

The currently vetted list of BIP 32 available libraries:

 - Java: [bitcoinj](https://github.com/NovaCrypto/BIP32?tab=GPL-3.0-1-ov-file#readme) project ([source code](https://github.com/bitcoinj/bitcoinj))
 - C/C++: [libbitcoin](https://libbitcoin.info/) project ([source code](https://github.com/libbitcoin/libbitcoin-system))
 - C/C++ [Bitcoin Core](https://github.com/bitcoin/bitcoin) itself
 - C [libbtc](https://github.com/libbtc/libbtc)
 - C#: [NBitcoin](https://programmingblockchain.gitbook.io/programmingblockchain) project ([source code](https://github.com/MetacoSA/NBitcoin))
 - Rust:  [bip32](https://docs.rs/bip32/latest/bip32/) project ([source code](https://github.com/iqlusioninc/crates/tree/main/bip32))
   - Due to the Rust's strict implementation, output the extended private keys
     directly is difficult, because the Zeroizing trait is used. Rust teams
     don't have to work around this and can print the `{xpriv}` surrounded with
     `Zeroizing(...)`.
 - Go: [source code](https://github.com/tyler-smith/go-bip32)

You can find example usages of the above libraries in `/bip32s` directory in
this repository. Note these are just my attempts at getting familiar with the
libraries, in particular, these aren't fully-fledged examples that would follow
the best practices of the language or the library. However, I've decided to share
them to help you start the implementation.

Since `java.util.regex` implements regular expressions, we allow the usage of
regex libraries (but note this in your `README.md` and in the corresponding
weekly report). However, using regex almost always easy to get wrong for any
non-trivial cases.

#### Base58 and SHA-256 libraries

Since Base58 encoding is likely to be present within the aforementioned
libraries or their dependencies, I am not providing a list here. SHA-256 is a
standard cryptographic library and so you will find plenty of libraries (if not
even in the standard one). Please, make it clear in the README, what options
you have chosen for both.

## Miscellaneous

The `--help` option can appear anywhere. If `--help` is not present then
exactly one of the three sub-commands must be present, and must be the first
one. If optional argument takes a value the value must appear exactly after.
Following the previous rules, the positional arguments can appear anywhere.
Also, the `--help` can repeat any (reasonable) number of times.

Copy-pasting code from other sources is disallowed, with the only exception
being the 3rd party libraries, e.g. including C sources directly in your code.
However, it's preferred to always use the standard build procedure and include
the 3rd party library as a transparent dependency. In case you aren't sure
about usage of a 3rd party library, ask.

The examples appearing in this specifications are expected to be implemented in
your CI pipelines. Ideally, as end-to-end tests on the command line.

The code examples uses `./bip380` to call the utility, however, this calling
convetion does not have to be followed literally. E.g., for Java calling `java
-jar bip380.jar` is fine as well.

Shy away from using operating system or platform dependent functionality. The
preferred platform is Linux, if possible. The build instructions shall
be very clear, up to date and easily reproducible.