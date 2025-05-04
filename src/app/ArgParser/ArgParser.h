/**
 * Project: PV286 2024/2025 Project
 * @file ArgParser.h
 * @author Pospíšil Zbyněk (xpospis)
 * @brief Implementation of CLI argument parser
 * @date 2025-03-15
 *
 * @copyright Copyright (c) 2025
 *
 */


#pragma once

#include <vector>
#include <regex>

const std::string KEY_ORIGIN_REGEX = "(\\[(\\d|[a-f]|[A-F]){8}(\\/\\dh?)*\\])?";

const std::string SIMPLE_KEY_EXPRESSION_VALUE_REGEX = KEY_ORIGIN_REGEX + R"(((02|03)(\d|[a-f]|[A-F]){64})|((04)(\d|[a-f]|[A-F]){128}))";
const std::string WIF_REGEX = KEY_ORIGIN_REGEX + "5([0-9]|[a-z]|[A-Z]){50}";
const std::string EXTENDED_PRIVATE_KEYS_REGEX = KEY_ORIGIN_REGEX + "(xprv|xpub)[1-9A-HJ-NP-Za-km-z]{20,111}(\\/\\d+(H|h|')?)*(\\/\\*)?h?";
const std::string PURE_PRIVATE_KEYS_REGEX = "(xprv|xpub)[1-9A-HJ-NP-Za-km-z]{20,111}";

const std::string CHECKSUM_REGEX = "(#[qpzry9x8gf2tvdw0s3jn54khce6mua7l]{8})";

const std::string PK_REGEX = "pk\\( *((" + SIMPLE_KEY_EXPRESSION_VALUE_REGEX + ")|(" + WIF_REGEX + ")|(" + EXTENDED_PRIVATE_KEYS_REGEX + ")) *\\) *";
const std::string PKH_REGEX = "pkh\\( *((" + SIMPLE_KEY_EXPRESSION_VALUE_REGEX + ")|(" + WIF_REGEX + ")|(" + EXTENDED_PRIVATE_KEYS_REGEX + ")) *\\) *";
const std::string MULTI_REGEX = "multi\\(( *\\d+ *( *, *( *(" + SIMPLE_KEY_EXPRESSION_VALUE_REGEX + ")|(" + WIF_REGEX + ")|(" + EXTENDED_PRIVATE_KEYS_REGEX + ") *) *)*\\) *)";
const std::string SH_PK_REGEX = "sh\\( *" + PK_REGEX + " *\\) *";
const std::string SH_PKH_REGEX = "sh\\( *" + PKH_REGEX + " *\\) *";
const std::string SH_MULTI_REGEX = "sh\\( *" + MULTI_REGEX + " *\\) *";
const std::string RAW_REGEX = "raw\\((\\d|[a-f]|[A-F]| )+\\) *";


class ArgParser {
private:
    std::vector<std::string> argList;  // Vector of input arguments

    std::vector<std::string> argValuesVector;  // Vector of parsed output argument values (or expressions)
    std::string argFilepath;  // Contains the filepath from argument, if provided
    bool verifyChecksumFlag = false;  // flag for script expressions
    bool computeChecksumFlag = false;  // flag for script expressions

    static void printHelp();
    bool multipleArgsExist(const std::string &arg);
    bool invalidKeyArgsAmount();
    bool invalidKeyArgsPosition();
    static std::string sha256(const std::string &value);
    static void parseDeriveKeyValue(const std::string &value);
    static void parseFilepath(const std::string &filepath);
    static std::string WIFToPrivateKey(const std::string &WIFKey);
    static void checkWIFChecksum(const std::string &WIFKey);
    static void parseKeyExpressionValue(const std::string &value);
    void parseScriptExpressionValue(std::string value);

    bool checkPkExpression(std::string str, std::string checksumRegex);
    bool checkPkhExpression(std::string str, std::string checksumRegex);
    bool checkMultiExpression(std::string str, std::string checksumRegex);
    bool checkShExpression(std::string str, std::string checksumRegex);
    bool checkRawExpression(std::string str, std::string checksumRegex);

    void getDeriveKeyArgs(std::vector<std::string> *tmpArgValueVector, std::string *filepath);
    void getKeyExpressionArgs(std::vector<std::string> *tmpArgValueVector);
    void getScriptExpressionArgs(std::vector<std::string> *tmpArgValueVector, bool *verifyChecksumFlag, bool *computeChecksumFlag);

    void parseDeriveKey();
    void parseKeyExpression();
    void parseScriptExpression();

public:
    ArgParser();
    void loadArguments(int argc, char **argv);
    void parse();
    bool argExists(const std::string &arg);

    std::vector<std::string> getArgValues();
    std::string getFilepath();
    bool getVerifyChecksumFlag() const;
    bool getComputeChecksumFlag() const;


};
