/**
 * Project: PV286 2024/2025 Project
 * @file Utility.cpp
 * @author Slivka Matej (xslivka1)
 * @brief Utilities for working with string
 * @date 2025-04-03
 *
 * @copyright Copyright (c) 2025
 *
 */

#include "StringUtilities.h"
#include <iostream>
#include <algorithm>


/**
 * Function for finding first substring within string.
 * @param const string input is a string which is supposed to be checked
 * @return first substring without hash
 */
std::string StringUtilities::findFirstSubstringWithoutHash(const std::string& input) {
    // Find the first occurrence of '#'
    size_t hashPos = input.find('#');

    // If there's no '#', the entire string is a substring without '#'
    if (hashPos == std::string::npos) {
        return input;
    }

    // If the '#' is not at the beginning, return the substring before it
    if (hashPos > 0) {
        return input.substr(0, hashPos);
    } else {
        std::cerr << "Error: Invalid format of expression." << std::endl;
        exit(1);
    }
}


/**
 * Function for dividing string to tokens based on delimeter
 * @param string str to be divided
 * @param string delimiter is a delimiter which divides string
 * @return vector of string
 */
std::vector<std::string> StringUtilities::split(std::string str, std::string delimiter) {
    std::vector<std::string> tokens;

    size_t start = 0;
    size_t end = str.find(delimiter);

    while (end != std::string::npos) {
        tokens.push_back(str.substr(start, end - start));
        start = end + delimiter.length();
        end = str.find(delimiter, start);
    }

    // Don't forget the last part after the last delimiter
    tokens.push_back(str.substr(start));

    return tokens;
}


/**
 * Removes white characters from string
 * @param string str to be stripped of white characters
 * @return stripped string
 */
std::string StringUtilities::removeWhiteCharacters(std::string str) {
    // Remove all whitespace characters
    str.erase(remove_if(str.begin(), str.end(), [](unsigned char c) { return isspace(c); }), str.end());
    return str;
}


/**
 * Removes first substring that occured in string
 * @param string originalString string to be stripped of substring at the beginning
 * @param string substringToRemove string to be removed from originalString
 * @return stripped string
 */
std::string StringUtilities::stripFirstSubstring(std::string originalString, std::string substringToRemove) {
    // Find the first occurrence of the substring
    size_t position = originalString.find(substringToRemove);

    // If substring is found, erase it
    if (position != std::string::npos) {
        originalString.erase(position, substringToRemove.length());
        return originalString;
    }
    else {
        throw std::invalid_argument("[ERROR]: stripFirstSubstring: substringToRemove is not substring of originalString");
    }
}


/**
 * Removes last substring that occured in string
 * @param string originalString string to be stripped of substring at the end
 * @param string substringToRemove string to be removed from originalString
 * @return stripped string
 */
std::string StringUtilities::stripLastSubstring(std::string originalString, std::string substringToRemove) {
    // Find the last occurrence of substr
    size_t pos = originalString.rfind(substringToRemove);

    // If substr is found, remove it
    if (pos != std::string::npos) {
        std::string result = originalString;
        result.erase(pos, substringToRemove.length());
        return result;
    }

    // Return original string if substr not found
    return substringToRemove;
}