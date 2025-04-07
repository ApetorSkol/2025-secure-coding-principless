# Project for class PV286 - Secure Coding Principles and Practices
This Project was an assignment for class Project for class PV286 - Secure Coding Principles and Practices at Faculty of Informatics at Masaryk University in Brno. Full assignment is available in [ASSIGNMENT.md](https://gitlab.fi.muni.cz/pv286/projects/-/blob/main/2025-bip380/README.md).

Project aims to create CLI application based on [Bitcoin Improvement Proposal 32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) and further
implement parts of the [Bitcoin Improvement Proposal 380](https://github.com/bitcoin/bips/blob/master/bip-0380.mediawiki).

### Installation
Binary file of this project -`bip380`- is included in root of this reporsitory. If you wish to re-compile, you can use
```bash
make build
```
Command automatically creates binary `bip380`. To run project, run it with one of three sub-commands
```
derive-key {value} [--path {path}] [-]    - Depending on the type of the input {value} 
                                            the utility outputs certain extended keys.

key-expression {expr} [-]     - parses the {expr} according to the BIP 380 Key 
                                Expressions specification. If there are no parsing
                                errors, the key expression is echoed back on a single line 
                                with 0 exit code. Otherwise, the utility errors out with a 
                                non-zero exit code and descriptive message.

script-expression {expr} [-]  - sub-command implements parsing of some of the script expressions
                                and optionally also checksum verification and calculation.
```

Each sub-command is further described below.

## Derive key

The `derive-key` sub-command is implemented in [`DeriveKey.cpp`](src/app/DeriveKey/DeriveKey.cpp) and uses the [`libbtc`](https://github.com/libbtc/libbtc) library to handle BIP32 extended keys. The implementation supports:

- Input as either a hexadecimal seed (128–512 bits, i.e., 32–128 hex characters) or a Base58-encoded BIP32 extended key (`xpub` or `xprv`),
- Optional derivation using a BIP32/BIP380-compatible path (e.g., `0/1H/2'`),
- Standard input support via `-`, where each line represents a new seed or extended key,
- Whitespace removal (spaces, tabs) from seed input for flexible formatting,
- Thorough validation and error reporting for malformed inputs (e.g., non-hex characters in seed, invalid path syntax, unsupported derivation from xpub),
- Correct handling of edge cases such as hardened derivation from `xpub`, path segment overflow, or checksum failure in deserialized keys,
- Output in the format `{xpub}:{xprv}` or `{xpub}:` if the private key is not available.

Example usage:

```bash
$ ./bip380 derive-key 000102030405060708090a0b0c0d0e0f
xpub...:xprv... 
```

### Installation instructions for `libbtc`

Derive-key uses the C library [`libbtc`](https://github.com/libbtc/libbtc) to perform BIP32 derivation. You can install it manually or rely on the CI pipeline which builds it automatically.

#### Manual installation (Linux/macOS)

Make sure you have development tools installed, such as:

- `autoconf`
- `automake`
- `libtool`
- `libevent-dev`
- `build-essential` (on Debian-based systems)

You can install them using:

```bash
sudo apt update
sudo apt install autoconf automake libtool build-essential libevent-dev
```

After installation of libbtc, you may also need to run:
```bash
sudo ldconfig
```
to update the dynamic linker runtime bindings.

To install libraries, run:
```bash
git clone https://github.com/libbtc/libbtc.git
cd libbtc
./autogen.sh
./configure
make
sudo make install
```

## Key expression

The implementation of key-expression logic can be found in KeyExpression/KeyExpression.cpp. The code simply repeats the arguments, that are given to it. 
Parsing and validating of the arguments is handled by the class ArgParser, which implements hex-encoded public keys, WIF keys and extended public and private keys. 

All these examples are checked with regex patterns. Note, that checking the WIF keys utilizes 3rd party library crypto-encode (available from: https://github.com/Safeheron/crypto-encode-cpp) and crypto-hash (available from: https://github.com/Safeheron/crypto-hash-cpp).

Example usage:

```bash
$ ./bip380 key-expression 5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ
5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ
```


## Script expression
The script-expression sub-command implements parsing of script expressions and their checksums.
Correct format of argument is `SCRIPT#CHECKSUM` where `CHECKSUM` is 8 character long checksum of script. Script formats are as follows:
```
pk(KEY)
pkh(KEY)
multi(k, KEY_1, KEY_2, ..., KEY_n)
sh(pk(KEY))
sh(pkh(KEY))
sh(multi(k, KEY_1, KEY_2, ..., KEY_n))
raw(HEX)
```
Based on the flags provided, application computes and checks the expressions. More on that below. 
Within script expressions `pk`,`pkh`,`multi`,`sh` and `raw` are expressions which we are able to parse. 
Furthermore, `KEY` are WIF, public or private key and, optionally, information about the origin of that key. They are described in [BIP380](https://github.com/bitcoin/bips/blob/master/bip-0380.mediawiki#key-expressions). Lastly, `HEX` is valid hexadecimal number.

#### Functionality

Based on the provided flags, subcommand behaves differently. There are 2 flags which define behaviour of subcommand `--compute-checksum` and `--verify-checksum`. If

- `--compute-checksum` is presented, then the checksum part is optional. If presented it does not have to be correct. Script calculates correct checksum and outputs `SCRIPT#CHECKSUM` with correct `CHECKSUM`.
- `--verify-checksum` is presented, then the checksum part is mandatory. Script checks whether `SCRIPT` part coresponds to provided `CHECKSUM` part. Output is `OK` if it is correct. In other case it exits with exit-code 1 and prints to stderr `"Error: Provided checksum is not correct for provided expression."`.
- If none of those flags are provided, then script simply checks whether `SCRIPT#CHECKSUM` is in correct format. It does not check correctness of it. `#CHECKSUM` part is optional but if provided, it has to be correct length.
- Both flags can not be presented and it is considered as wrong input.

Lastly you can provide `[-]`. If a single dash `'-'` parameter is present, it indicates reading the `{expr}` from the standard input.

**Note1:** Application accepts any number of spaces ` ` characters everywhere within the `SCRIPT` part. Exception is space followed by `pk`,`pkh`,`multi`,`sh` and `raw`. 
**Note2:** Spaces differ the behaviour of application. `raw(deadbeef)` is not same as `raw( deadbeef )` 

For examples of application, you can check tests [folder](/src/tests/ScriptExpressionTest.cpp).



## Argument Parser

Parsing of the arguments happens in the class ArgParser. This class handles argument loading, parsing and, partially, subsequent validation. Communication with the class happens through public methods. Implemented functions are annotated with Doxygen-ready comments, thrown errors are handles as nested exceptions (and printed in `main.cpp`).

The parser itself is split into two main parts. The first (functions as `getDeriveKeyArgs`, `getKeyExpressionArgs` and `getScriptExpressionArgs`) retrieves the arguments and stores them into vector of string values. These functions handle correct number of required arguments, missing values, or loading from `stdin`.

The second part (mainly functions `parseDeriveKeyValue`, `parseKeyExpressionValue` and `parseScriptExpressionValue`) is used for checking the validity of said arguments. This incorporates multiple regexes, which check the basic format, function `stol` for checking the number limits in filepath and function `checkWIFChecksum`, which checks the validity of WIF keys. The validity of private keys, public keys and checking their checksum is however implemented in their corresponding classes.

For safety reasons, the maximum length of single argument cannot exceed 1000 characters.




# Authors
Authors of this project are

Matej Slivka - 555179@mail.muni.cz or matej.slivka33@gmail.com

Zbyněk Pospíšil - zp.pospisil@seznam.cz or 569014@mail.muni.cz

Jan Kuča - kuki.kuca@centrum.cz or 572254@mail.muni.cz

