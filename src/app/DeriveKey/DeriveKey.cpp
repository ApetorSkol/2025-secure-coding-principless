/**
 * @project PV286 2024/2025 Project
 * @file DeriveKey.cpp
 * @brief Implementation of the DeriveKey logic.
 * @date 2025-03-20
 *
 * This file contains the implementation for deriving BIP32 keys
 * using seeds or extended keys.
 */

#include "DeriveKey.h"

#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <algorithm>
#include <cctype>
#include <stdexcept>
#include <limits>

extern "C"
{
#include <btc/bip32.h>
#include <btc/base58.h>
#include <btc/chainparams.h>
#include <btc/utils.h>
}


static btc_chainparams *chain = (btc_chainparams *)&btc_chainparams_main;

/**
 * @brief Removes all whitespace characters from a string.
 * @param input The input string.
 * @return A new string with all whitespace removed.
 */
static std::string removeWhitespace(const std::string &input)
{
    std::string result;
    for (char c : input)
    {
        if (!isspace(static_cast<unsigned char>(c)))
        {
            result += c;
        }
    }
    return result;
}

/**
 * @brief Checks if a string is a valid hexadecimal string.
 * @param s The input string.
 * @return True if the string is hex, false otherwise.
 */
static bool isHex(const std::string &s)
{
    return all_of(s.begin(), s.end(), [](char c)
                  { return isxdigit(static_cast<unsigned char>(c)); });
}

/**
 * @brief Checks if a string is an extended key (xpub or xprv).
 * @param s The input string.
 * @return True if it is xpub or xprv, false otherwise.
 */
static bool isXKey(const std::string &s)
{
    return s.rfind("xpub", 0) == 0 || s.rfind("xprv", 0) == 0;
}

/**
 * @brief Checks if a string is an extended private key (xprv).
 * @param s The input string.
 * @return True if it is xprv, false otherwise.
 */
static bool isXPrv(const std::string &s)
{
    return s.rfind("xprv", 0) == 0;
}

/**
 * @brief Derives a BIP32 path on a given HD node.
 * @param node Pointer to the HD node.
 * @param path Derivation path string (e.g., "0/1h/2'").
 * @param priv Whether to derive with private (true) or public (false) key.
 */
static void derivePath(btc_hdnode *node, const std::string &path, bool priv)
{
    if (!path.empty() && path.back() == '/')
    {
        throw std::invalid_argument("[ERROR]: derivePath: trailing slash not allowed");
    }

    std::istringstream ss(path);
    std::string segment;

    while (getline(ss, segment, '/'))
    {
        if (segment.empty())
        {
            throw std::invalid_argument("[ERROR]: derivePath: invalid derivation index (empty segment)");
        }

        bool hardened = false;
        if (segment.back() == 'h' || segment.back() == 'H' || segment.back() == '\'')
        {
            hardened = true;
            segment.pop_back();
        }

        if (!all_of(segment.begin(), segment.end(), ::isdigit))
        {
            throw std::invalid_argument("[ERROR]: derivePath: invalid derivation index (non-digit)");
        }

        unsigned long index;
        try
        {
            index = stoul(segment);
        }
        catch (...)
        {
            throw std::invalid_argument("[ERROR]: derivePath: stoul failed (non-numeric segment)");
        }

        if (index > std::numeric_limits<uint32_t>::max())
        {
            throw std::out_of_range("[ERROR]: derivePath: index exceeds 32-bit range");
        }

        if (index >= 0x80000000)
        {
            throw std::invalid_argument("[ERROR]: derivePath: derivation index out of range");
        }

        if (hardened)
        {
            index += 0x80000000;
        }

        bool result = priv ? btc_hdnode_private_ckd(node, index)
                           : btc_hdnode_public_ckd(node, index);

        if (!result)
        {
            if (!priv && index >= 0x80000000)
                throw std::invalid_argument("[ERROR]: derivePath: cannot derive hardened key from xpub");
            throw std::runtime_error("[ERROR]: derivePath: CKD operation failed");
        }
    }
}

/**
 * @brief Handles a hex seed input, performs derivation and prints xpub:xprv.
 * @param seedStr The hex seed string.
 * @param path The derivation path.
 */
static void handleSeed(const std::string &seedStr, const std::string &path)
{
    std::string clean = removeWhitespace(seedStr);

    if (!isHex(clean))
    {
        throw std::invalid_argument("[ERROR]: handleSeed: invalid characters in seed");
    }
    if (clean.length() % 2 != 0 || clean.length() < 32 || clean.length() > 128)
    {
        throw std::invalid_argument("[ERROR]: handleSeed: seed length out of range");
    }

    size_t byteLen = clean.length() / 2;
    std::vector<uint8_t> seed(byteLen);
    int outLen = 0;

    utils_hex_to_bin(clean.c_str(), seed.data(), clean.length(), &outLen);
    if (outLen != (int)byteLen)
    {
        throw std::invalid_argument("[ERROR]: handleSeed: hex decode mismatch");
    }

    btc_hdnode node;
    if (!btc_hdnode_from_seed(seed.data(), seed.size(), &node))
    {
        throw std::runtime_error("[ERROR]: handleSeed: failed to create node from seed");
    }

    if (!path.empty())
    {
        derivePath(&node, path, true);
    }

    char xpub[112], xprv[112];
    btc_hdnode_serialize_public(&node, chain, xpub, sizeof(xpub));
    btc_hdnode_serialize_private(&node, chain, xprv, sizeof(xprv));

    std::cout << xpub << ":" << xprv << std::endl;
}

/**
 * @brief Handles an extended key (xpub/xprv), performs derivation and prints output.
 * @param key The extended key.
 * @param path The derivation path.
 */
static void handleXKey(const std::string &key, const std::string &path)
{
    btc_hdnode node;
    if (!btc_hdnode_deserialize(key.c_str(), chain, &node))
    {
        throw std::invalid_argument("[ERROR]: handleXKey: invalid extended key");
    }

    bool hasPrv = isXPrv(key);
    if (!path.empty())
    {
        derivePath(&node, path, hasPrv);
    }

    char xpub[112];
    btc_hdnode_serialize_public(&node, chain, xpub, sizeof(xpub));
    std::cout << xpub;
    if (hasPrv)
    {
        char xprv[112];
        btc_hdnode_serialize_private(&node, chain, xprv, sizeof(xprv));
        std::cout << ":" << xprv;
    }
    std::cout << std::endl;
}

/**
 * @brief Main function for deriving keys from inputs.
 * @param values List of input strings (seeds or extended keys).
 * @param filepath Derivation path string.
 */
void deriveKey(const std::vector<std::string> &values, const std::string &filepath)
{
    for (const auto &val : values)
    {
        if (val.empty())
            continue;

        try
        {
            if (isXKey(val))
            {
                handleXKey(val, filepath);
            }
            else
            {
                handleSeed(val, filepath);
            }
        }
        catch (const std::exception &e)
        {
            std::cerr << e.what() << std::endl;
            exit(1);
        }
    }
}
