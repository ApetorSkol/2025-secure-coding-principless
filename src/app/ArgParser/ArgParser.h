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

using namespace std;

const string KEY_ORIGIN_REGEX = "(\\[(\\d|[a-f]|[A-F]){8}(\\/\\dh?)*\\])?";

const string SIMPLE_KEY_EXPRESSION_VALUE_REGEX = KEY_ORIGIN_REGEX + R"(((02|03)(\d|[a-f]|[A-F]){64})|((04)(\d|[a-f]|[A-F]){128}))";
const string WIF_REGEX = KEY_ORIGIN_REGEX + "5([0-9]|[a-z]|[A-Z]){50}";
const string EXTENDED_PRIVATE_KEYS_REGEX = KEY_ORIGIN_REGEX + "(xprv|xpub)[1-9A-HJ-NP-Za-km-z]{20,111}(\\/\\d+(H|h|')?)*(\\/\\*)?";   // todo 20-111 uncertain, path elements to check int limits??
const string PURE_PRIVATE_KEYS_REGEX = "(xprv|xpub)[1-9A-HJ-NP-Za-km-z]{20,111}";

const string CHECKSUM_REGEX = "(#[qpzry9x8gf2tvdw0s3jn54khce6mua7l]{8})?";

const string PK_REGEX = "(pk(\\s|\\t)*\\(.+\\))";
const string PKH_REGEX = "(pkh(\\s|\\t)*\\(.+\\))";
const string MULTI_REGEX = "(multi(\\s|\\t)*\\((\\s|\\t)*\\d+(\\s|\\t)*,.+\\))";
const string SH_PK_REGEX = "(sh(\\s|\\t)*\\((\\s|\\t)*" + PK_REGEX + "(\\s|\\t)*\\))";
const string SH_PKH_REGEX = "(sh(\\s|\\t)*\\((\\s|\\t)*" + PKH_REGEX + "(\\s|\\t)*\\))";
const string SH_MULTI_REGEX = "(sh(\\s|\\t)*\\((\\s|\\t)*" + MULTI_REGEX + "(\\s|\\t)*\\))";
const string RAW_REGEX = "(raw(\\s|\\t)*\\((\\d|[a-f]|[A-F]|\\s|\\t)+\\))";



class ArgParser {
private:
    vector<string> argList;  // Vector of input arguments

    vector<string> argValuesVector;  // Vector of parsed output argument values (or expressions)
    string argFilepath;  // Contains the filepath from argument, if provided
    bool verifyChecksumFlag = false;  // flag for script expressions
    bool computeChecksumFlag = false;  // flag for script expressions

    static void printHelp();
    bool multipleArgsExist(const string &arg);
    bool invalidKeyArgsAmount();
    bool invalidKeyArgsPosition();
    static string sha256(const string &value);
    static void parseDeriveKeyValue(const string &value);
    static void parseFilepath(const string &filepath);
    static string WIFToPrivateKey(const string &WIFKey);
    static void checkWIFChecksum(const string &WIFKey);
    static void parseKeyExpressionValue(const string &value);
    static void parseScriptExpressionValue(const string &value);

    void getDeriveKeyArgs(vector<string> *tmpArgValueVector, string *filepath);
    void getKeyExpressionArgs(vector<string> *tmpArgValueVector);
    void getScriptExpressionArgs(vector<string> *tmpArgValueVector, bool *verifyChecksumFlag, bool *computeChecksumFlag);

    void parseDeriveKey();
    void parseKeyExpression();
    void parseScriptExpression();

public:
    ArgParser();
    void loadArguments(int argc, char **argv);
    void parse();
    bool argExists(const string &arg);

    vector<string> getArgValues();
    string getFilepath();
    bool getVerifyChecksumFlag() const;
    bool getComputeChecksumFlag() const;


};


