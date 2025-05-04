/**
 * Project: PV286 2024/2025 Project
 * @file Utility.h
 * @author Slivka Matej (xslivka1)
 * @brief Utilities for working with string
 * @date 2025-04-03
 *
 * @copyright Copyright (c) 2025
 *
 */

#pragma once

#include <string>
#include <vector>


class StringUtilities {
public:
    static std::string findFirstSubstringWithoutHash(const std::string& input);
    static std::string stripFirstSubstring(std::string originalString, std::string substringToRemove);
    static std::string stripLastSubstring(std::string originalString, std::string substringToRemove);
    static std::vector<std::string> split(std::string str, std::string delimiter);
    static std::string removeWhiteCharacters(std::string str);
};
