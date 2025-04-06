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

using namespace std;


class StringUtilities {
public:
    static string findFirstSubstringWithoutHash(const string& input);
    static string stripFirstSubstring(string originalString, string substringToRemove);
    static string stripLastSubstring(string originalString, string substringToRemove);
    static vector<string> split(string str, string delimiter);
    static string removeWhiteCharacters(string str);
};
