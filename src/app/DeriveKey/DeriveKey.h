/**
 * @project PV286 2024/2025 Project
 * @file DeriveKey.h
 * @brief Header file for DeriveKey functionality.
 * @date 2025-03-20
 *
 * This file contains the function declaration for BIP32 key derivation.
 */

#ifndef DERIVE_KEY_H
#define DERIVE_KEY_H

#include <string>
#include <vector>

/**
 * @brief Derives BIP32 keys from seeds or extended keys.
 *
 * This function processes a list of inputs (hex seeds or extended keys), applies
 * optional BIP32 path derivation, and prints the resulting xpub:xprv or xpub only.
 *
 * @param values A list of input strings (hex seed or xprv/xpub).
 * @param filepath A string representing the derivation path (e.g., "0/1h/2'/3").
 */
void deriveKey(const std::vector<std::string> &values, const std::string &filepath);

#endif // DERIVE_KEY_H
