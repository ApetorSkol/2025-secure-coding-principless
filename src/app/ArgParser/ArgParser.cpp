/**
 * Project: PV286 2024/2025 Project
 * @file ArgParser.cpp
 * @author Pospíšil Zbyněk (xpospis)
 * @brief Implementation of CLI argument parser
 * @date 2025-03-15
 *
 * @copyright Copyright (c) 2025
 *
 */

#include <string>
#include <iostream>
#include <limits>
#include <iomanip>
#include <unistd.h>
#include <cstring>

#include "ArgParser.h"
#include "crypto-encode/base58.h"
#include "crypto-encode/hex.h"
#include "crypto-hash/sha256.h"
#include "../Utility/StringUtilities.h"

extern "C"
{
#include <btc/bip32.h>
}


using namespace std;


/**
 * Prints help
 */
void ArgParser::printHelp() {
    cout << "derive-key {value} [--path {path}] [-]    - Depending on the type of the input {value} the utility outputs certain extended keys.\n\nkey-expression {expr} [-]     - parses the {expr} according to the BIP 380 Key Expressions specification. If there are no parsing errors, the key expression is echoed back on a single line with 0 exit code. Otherwise, the utility errors out with a non-zero exit code and descriptive message.\n\nscript-expression {expr} [-]  - sub-command implements parsing of some of the script expressions and optionally also checksum verification and calculation.\n\n--help   	- prints help and exits out" << endl;

    exit(0);
}


/**
  * Checks if argument exists in the arglist
  * @param arg argument to check
  * @return true if found, false if otherwise
  */
bool ArgParser::argExists(const string &arg) {
    return find(this->argList.begin(), this->argList.end(), arg) != this->argList.end();
}


/**
 * Detects if more than one args of the provided string exist
 * @param arg argument to check
 * @return true if multiples exist, false if otherwise
 */
bool ArgParser::multipleArgsExist(const string &arg) {
    auto iter = find(this->argList.begin(), this->argList.end(), arg);
    if (iter == this->argList.end())
        return false;

    return find(next(iter), this->argList.end(), arg) != this->argList.end();
}


/**
 * Checks if more than one key argument is entered
 * @return true if multiples are found, false if otherwise
 */
bool ArgParser::invalidKeyArgsAmount() {
    return multipleArgsExist("derive-key") ||
            multipleArgsExist("key-expression") ||
            multipleArgsExist("script-expression") ||
            multipleArgsExist("-") ||
            multipleArgsExist("--path");
}


/**
 * Checks that key arguments are 1st
 * @return true if key args are correct, false if otherwise
 */
bool ArgParser::invalidKeyArgsPosition() {
    return (argList.at(0) != "derive-key" && argList.at(0) != "key-expression" && argList.at(0) != "script-expression");
}


/**
 * Implements sha256 hashing
 * @param value value to be hashed
 * @return hashed string
 */
string ArgParser::sha256(const string &value) {
    using safeheron::hash::CSHA256;

    CSHA256 sha256;
    uint8_t outputBuffer[CSHA256::OUTPUT_SIZE];
    sha256.Write(reinterpret_cast<const unsigned char*>(value.c_str()), value.length());
    sha256.Finalize(outputBuffer);

    ostringstream hexStream;
    for (unsigned char ch : outputBuffer) {
        hexStream << hex << setw(2) << setfill('0') << static_cast<int>(ch);
    }

    return hexStream.str();
}


/**
 * Parses the provided key value.
 *
 * Valid seed {value} is a byte sequence of length between 128 and 512 bits represented as case-insensitive hexadecimal values. Single space character ' ' or a
 * tab value '\t' can be used to separate the individual hexadecimal values. Note that extended public and private keys cannot be split by any whitespace.
 * The allowed seed lengths can be further constrained by the underlying BIP 32 library that you are using --- if so, mention the valid lengths in the help and
 * the project's README file.
 *
 * @param value value to be checked
 */
void ArgParser::parseDeriveKeyValue(const string &value) {
    const regex valueRegex("^(([0-9a-fA-F]{2})([ \t]*)){16,64}$");

    smatch matches;
    if (!regex_match(value, matches, valueRegex) &&
        !regex_match(value, matches, regex(PURE_PRIVATE_KEYS_REGEX)))
        throw invalid_argument("[ERROR]: parseDeriveKeyValue: invalid key value");

}


/**
  * Parses the provided filepath, returns false if invalid, true if all good.
  *
  * The {path} value is a sequence of /NUM and /NUMh, where NUM is from the range [0,...,2^31-1] as described in BIP 32.
  * The path does not need to start with /. In the hardened version /NUMh the h indentifier can also be substituted with H or ' and these can also be
  * mixed within a single path. Parsing and normalizing the {path} value correctly for the underlying library is your task, however correctness of the
  * {path} is left to the library.
  *
  * @param filepath filepath to be checked
  */
void ArgParser::parseFilepath(const string &filepath) {
    const regex filepathRegex("^(\\/?\\d+(H|h|')?)+$");
    const regex numberRegex("\\d+");

    smatch matches;
    if (!regex_match(filepath, matches, filepathRegex))
        throw invalid_argument("[ERROR]: parseFilepath: filepathRegex did not match");

    const sregex_token_iterator end;
    for (sregex_token_iterator iter(filepath.begin(), filepath.end(), numberRegex, 0); iter != end; iter++) {
        try {
            unsigned long numBuffer = stoul(iter->str());

            if ((numeric_limits<uint32_t>::max() / 2) < numBuffer)
                throw out_of_range("[ERROR]: parseFilepath: Number above range");
        }
        catch (const out_of_range &e) {
            throw  invalid_argument("[ERROR]: parseFilepath: stoul failed");
        }
    }
}


/**
 * Converts WIF key to PK via base58 decoding. NOTE, that the fist byte is not dropped, as it should be
 * @param WIFKey WIF key to be converted
 * @return decoded PK
 */
string ArgParser::WIFToPrivateKey(const string &WIFKey) {
    using namespace safeheron::encode::hex;
    using namespace safeheron::encode::base58;
    string convertedString;
    try {
        convertedString = EncodeToHex(DecodeFromBase58(WIFKey));
    }
    catch (exception &ex) {
        throw invalid_argument("[ERROR]: WIFToPrivateKey: DecodeFromBase58 failed");
    }

    if (convertedString.length() != 74)
        throw invalid_argument("[ERROR]: WIFToPrivateKey: Invalid convertedString output length");

    return convertedString;
}


/**
 * Checks the WIF key's checksum
 * @param WIFKey WIF key to be checked
 * @return true if OK, false if otherwise
 */
void ArgParser::checkWIFChecksum(const string &WIFKey) {
    using namespace safeheron::encode::hex;
    using namespace safeheron::encode::base58;
    string convertedString;
    try {
        convertedString = WIFToPrivateKey(WIFKey);
    }
    catch (exception &ex) {
        throw_with_nested(invalid_argument("[ERROR]: checkWIFChecksum: WIFToPrivateKey failed"));
    }

    string shortString = convertedString.substr(0, 66);
    string checksum = convertedString.substr(66, convertedString.length());
    string result = sha256(DecodeFromHex(sha256(DecodeFromHex(shortString))));

    if (checksum != result.substr(0, 8))
        throw invalid_argument("[ERROR]: checkWIFChecksum: checksum does not match WIF key");
}


/**
 * Parses the values provided in key-expression
 * @param value value to be checked
 */
void ArgParser::parseKeyExpressionValue(const string &value) {
    const regex simpleKeyExpressionValueRegex("^" + SIMPLE_KEY_EXPRESSION_VALUE_REGEX + "$");
    const regex WIFRegex("^" + WIF_REGEX + "$");
    const regex extendedPrivateKeys("^" + EXTENDED_PRIVATE_KEYS_REGEX + "$");

    smatch matches;
    if (regex_match(value, matches, simpleKeyExpressionValueRegex)) {
        return;
    }
    else if (regex_match(value, matches, WIFRegex)) {
        try {
          	string noSquareBrackets = value;
            if (value.find(']') != string::npos ) {
                noSquareBrackets = StringUtilities::split(value, "]")[1];
            }
            checkWIFChecksum(noSquareBrackets);
        }
        catch (exception &ex) {
            throw_with_nested(invalid_argument("[ERROR]: parseKeyExpressionValue: checkWIFChecksum failed"));
        }
    }
    else if (regex_match(value, matches, extendedPrivateKeys)) {
        btc_hdnode node;
        static btc_chainparams *chain = (btc_chainparams *)&btc_chainparams_main;

        if (!btc_hdnode_deserialize(value.c_str(), chain, &node))
        {
            throw invalid_argument("[ERROR]: parseKeyExpressionValue: invalid extended key");
        }

        return;
    }
    else {
        throw invalid_argument("[ERROR]: parseKeyExpressionValue: unrecognizable key expression");
    }
}


/**
 * Check whether string matches pkh expression
 * @param string str to be checked
 * @return true if matches, else returns false
 */
bool ArgParser::checkPkhExpression(string str, string checksumRegex){
    const regex PkhRegex("^ *" + PKH_REGEX + checksumRegex + "$");
    smatch matches;
    if (regex_match(str, matches, PkhRegex)){
        parseKeyExpressionValue(matches[1].str());
        return true;
    }
    return false;
}


/**
 * Check whether string matches pk expression
 * @param string str to be checked
 * @return true if matches, else returns false
 */
bool ArgParser::checkPkExpression(string str, string checksumRegex){
    const regex PkRegex("^ *" + PK_REGEX + checksumRegex + "$");
    smatch matches;
    if (regex_match(str, matches, PkRegex)){
        parseKeyExpressionValue(matches[1].str());
        return true;
    }
    return regex_match(str, PkRegex);
}


/**
 * Check whether string matches multi expression. This function also checks whether first k number is greater then number of provided keys.
 * @param string str to be checked
 * @return true if matches, else returns false
 */
bool ArgParser::checkMultiExpression(string str, string checksumRegex){
    const regex MultiRegex("^ *" + MULTI_REGEX + checksumRegex + "$");
    if (!regex_match(str, MultiRegex)) {
        return false;
    }

    str = StringUtilities::removeWhiteCharacters(str);
    str = StringUtilities::stripFirstSubstring(str, "multi(");
    str = StringUtilities::stripLastSubstring(str, ")");
    vector<string> tokens = StringUtilities::split(str, ",");
    unsigned long int size = tokens.size() - 1;
    unsigned long int k;
        try{
            k = stoi(tokens[0]);
        }
        catch (exception &ex) {
            throw invalid_argument("[ERROR]: checkMultiExpression: Stoi() invalid conversion of " + tokens[0]);
        }

    if (size < k ){
        return false;
    }

    // check valid keys
    for (unsigned int i = 1; i < tokens.size() ; i++) {
        string noHashTag = StringUtilities::split(tokens[i], "#")[0];
        parseKeyExpressionValue(noHashTag);
    }

    return true;
}


/**
 * Check whether string matches sh(multi()) or sh(pk()) or sh(pkh()) expression
 * @param string str to be checked
 * @return true if matches, else returns false
 */
bool ArgParser::checkShExpression(string str, string checksumRegex){
    const regex ShMultiRegex("^ *" + SH_MULTI_REGEX + checksumRegex + "$");
    const regex ShPkRegex("^ *" + SH_PK_REGEX + checksumRegex + "$");
    const regex ShPkhRegex("^ *" + SH_PKH_REGEX + checksumRegex + "$");

    smatch matches;
    if (regex_match(str, matches, ShPkRegex) ||
        regex_match(str, matches, ShPkhRegex)
        ) {
        parseKeyExpressionValue(matches[1].str());
        return true;
        }

    if (regex_match(str, ShMultiRegex)){
        str = StringUtilities::removeWhiteCharacters(str);
        str = StringUtilities::stripFirstSubstring(str, "sh(multi(");
        str = StringUtilities::stripLastSubstring(str, "))");
        vector<string> tokens = StringUtilities::split(str, ",");
        unsigned long int size = tokens.size() - 1;
        unsigned long int k;
        try{
            k = stoi(tokens[0]);
        }
        catch (exception &ex) {
            throw invalid_argument("[ERROR]: checkMultiExpression: Stoi() invalid conversion of " + tokens[0]);
        }

        if (size < k ){
            return false;
        }


        // check valid keys
        for (unsigned int i = 1; i < tokens.size() ; i++) {
            string noHashTag = StringUtilities::split(tokens[i], "#")[0];
            parseKeyExpressionValue(noHashTag);
        }

        return true;
    }

    return false;
}


/**
 * Check whether string matches raw expression
 * @param string str to be checked
 * @return true if matches, else returns false
 */
bool ArgParser::checkRawExpression(string str, string checksumRegex){
    const regex RawRegex("^ *" + RAW_REGEX + checksumRegex + "$");
    return regex_match(str, RawRegex);
}


/**
 * Parses the values provided in script-expression
 * @param value value to be checked
 */
void ArgParser::parseScriptExpressionValue(string value) {
      // check for correct handling of script expression based on provided flags
    string checksumRegex = CHECKSUM_REGEX + "?"; // if no flags are provided then the checksumis just optional part but must have correct length
    if (this->getComputeChecksumFlag()){
        // if computeChecksum is provided ,then checksum is completely optional
        size_t position = value.find("#");
        // If it contain '#', then the rest after it can be anything
        if (position != string::npos) {
            checksumRegex = "(#.*?)";
        }
        // if it does not contain '#', then the CHECKSUM is not present and expression must match the whole string
        else {
            checksumRegex = "";
        }
    }
    if (this->getVerifyChecksumFlag()){
        checksumRegex = CHECKSUM_REGEX; // if verifyChecksum is provided ,then checksum is mandatory
    }

    if (!checkPkExpression(value, checksumRegex) && //pk(KEY)
        !checkPkhExpression(value, checksumRegex) && //pkh(KEY)
        !checkMultiExpression(value, checksumRegex) &&//multi(k, KEY_1, KEY_2, ..., KEY_n)
        !checkShExpression(value, checksumRegex) &&// sh(pk(KEY)) or sh(pkh(KEY)) or sh(multi(k, KEY_1, KEY_2, ..., KEY_n))
        !checkRawExpression(value, checksumRegex) //raw(HEX)
        ) {
            throw invalid_argument("[ERROR]: parseScriptExpressionValue: value(s) match no known regex");
        }
}


/**
 * Returns derive-key args from CLI.
 * @param tmpArgValueVector empty vector, which function fills with detected expressions
 * @param filepath empty filepath, which function fills with detected filepath (if present)
 */
void ArgParser::getDeriveKeyArgs(vector<string> *tmpArgValueVector, string *filepath) {
    if (tmpArgValueVector == nullptr || filepath == nullptr)
        throw runtime_error("[ERROR]: getDeriveKeyArgs: nullptr provided");

    string tmpArgValue;  // for CLI value

    for (auto iter = argList.begin(); iter != argList.end(); iter = next(iter)) {
        if (*iter == "derive-key") {
            continue;
        }
        else if ((*filepath).empty() && (*iter == "--path") && (next(iter) != argList.end())) {
            iter = next(iter);
            *filepath = *iter;
        }
        else if (tmpArgValue.empty() && *iter != "-") {
            tmpArgValue = *iter;
        }
        else if ((*tmpArgValueVector).empty() && *iter == "-") {
            string line;
            while (getline(cin, line))
                if (!line.empty())
                    (*tmpArgValueVector).push_back(line);
        }
        else {
            throw invalid_argument("[ERROR]: getDeriveKeyArgs: unsupported argument");
        }
    }
    // Primarily works with vector form
    if ((*tmpArgValueVector).empty())
        (*tmpArgValueVector).push_back(tmpArgValue);
}


/**
 * Returns "key-expression" args from CLI.
 * @param tmpArgValueVector empty vector, which function fills with detected expressions
 */
void ArgParser::getKeyExpressionArgs(vector<string> *tmpArgValueVector) {
    if (tmpArgValueVector == nullptr)
        throw runtime_error("[ERROR]: getKeyExpressionArgs: nullptr provided");

    string tmpArgValue;  // for CLI value

    for (const auto& arg : argList) {
        if (arg == "key-expression") {
            continue;
        }
        else if (tmpArgValue.empty() && arg != "-") {
            tmpArgValue = arg;
        }
        else if ((*tmpArgValueVector).empty() && arg == "-") {
            string line;
            while (getline(cin, line))
                (*tmpArgValueVector).push_back(line);
        }
        else {
            throw invalid_argument("[ERROR]: getKeyExpressionArgs: unsupported argument");
        }
    }
    // Primarily works with vector form
    if ((*tmpArgValueVector).empty())
        (*tmpArgValueVector).push_back(tmpArgValue);
}


/**
 * Returns "script-expression" args from CLI.
 * @param tmpArgValueVector empty vector, which function fills with detected expressions
 * @param verifyChecksumFlag false by default, set to true if such argument is found
 * @param computeChecksumFlag false by default, set to true if such argument is found
 */
void ArgParser::getScriptExpressionArgs(vector<string> *tmpArgValueVector, bool *verifyChecksumFlag, bool *computeChecksumFlag) {
    if (tmpArgValueVector == nullptr || verifyChecksumFlag == nullptr || computeChecksumFlag == nullptr)
        throw runtime_error("[ERROR]: getScriptExpressionArgs: nullptr provided");

    string tmpArgValue;  // for CLI value

    for (const auto& arg : argList) {
        if (arg == "script-expression") {
            continue;
        }
        else if (!*verifyChecksumFlag && (arg == "--verify-checksum")) {
            this->verifyChecksumFlag = true;
        }
        else if (!*computeChecksumFlag && (arg == "--compute-checksum")) {
            this->computeChecksumFlag = true;
        }
        else if (tmpArgValue.empty() && arg != "-") {
            tmpArgValue = arg;
        }
        else if ((*tmpArgValueVector).empty() && arg == "-") {
            string line;
            while (getline(cin, line))
                (*tmpArgValueVector).push_back(line);
        }
        else {
            throw invalid_argument("[ERROR]: getScriptExpressionArgs: unsupported argument");
        }
    }

    if (*verifyChecksumFlag && *computeChecksumFlag)
        throw invalid_argument("[ERROR]: getScriptExpressionArgs: use either verifyChecksumFlag or computeChecksumFlag");

    // Primarily works with vector form
    if ((*tmpArgValueVector).empty())
        (*tmpArgValueVector).push_back(tmpArgValue);
}


/**
 * Function parses derive-key command arguments
 */
void ArgParser::parseDeriveKey() {
    vector<string> tmpArgValueVector;
    string filepath;
    getDeriveKeyArgs(&tmpArgValueVector, &filepath);

    if (!filepath.empty()) {
        try {
            parseFilepath(filepath);
        }
        catch (exception &ex) {
            throw_with_nested(invalid_argument("[ERROR]: parseDeriveKey: invalid filepath"));
        }
    }

    try {
        for (const auto &value : tmpArgValueVector)
            parseDeriveKeyValue(value);
    }
    catch (exception &ex) {
        throw_with_nested(invalid_argument("[ERROR]: parseDeriveKey: invalid value(s)"));
    }

    this->argFilepath = filepath;
    this->argValuesVector = tmpArgValueVector;
}



/**
 * Function parses key-expression key command arguments
 */
void ArgParser::parseKeyExpression() {
    vector<string> tmpArgValueVector;
    getKeyExpressionArgs(&tmpArgValueVector);

    try {
        for (const auto &value : tmpArgValueVector)
            parseKeyExpressionValue(value);
    }
    catch (exception &ex) {
        throw_with_nested(invalid_argument("[ERROR]: parseKeyExpression: parseKeyExpressionValue failed"));
    }

    this->argValuesVector = tmpArgValueVector;
}


/**
 * Function parses script-expression command arguments
 */
void ArgParser::parseScriptExpression() {
    vector<string> tmpArgValueVector;
    this->verifyChecksumFlag = false;
    this->computeChecksumFlag = false;
    getScriptExpressionArgs(&tmpArgValueVector, &verifyChecksumFlag, &computeChecksumFlag);

    try {
        for (const auto &value : tmpArgValueVector)
            parseScriptExpressionValue(value);
    }
    catch (exception &ex) {
        throw_with_nested(invalid_argument("[ERROR]: parseScriptExpression: parseScriptExpressionValue failed"));
    }

    this->argValuesVector = tmpArgValueVector;
}


/**
 * The main function for parsing all CLI arguments
 */
void ArgParser::parse() {

    if (argExists("--help"))
        printHelp();

    if (argList.size() < 2)
        throw invalid_argument("Invalid number of arguments (>2 needed)");

    if (invalidKeyArgsAmount())
        throw invalid_argument("Invalid number of key arguments");

    if (invalidKeyArgsPosition())
        throw invalid_argument("First argument must be key-argument");

    if (argExists("derive-key"))
        parseDeriveKey();
    else if (argExists("key-expression"))
        parseKeyExpression();
    else if (argExists("script-expression"))
        parseScriptExpression();
}


/**
 * Public getter for parsed and validated argument values
 * @return vector of argument values to perform operations on
 */
vector<string> ArgParser::getArgValues() {
    return this->argValuesVector;
}


/**
 * Public getter for parsed and validated filepath (if present)
 * @return filepath if provided
 */
string ArgParser::getFilepath() {
    return this->argFilepath;
}


/**
 * Public getter for the VerifyChecksum flag
 * @return true if argument is provided, false if otherwise
 */
bool ArgParser::getVerifyChecksumFlag() const {
    return this->verifyChecksumFlag;
}


/**
 * Public getter for the ComputeChecksum flag
 * @return true if argument is provided, false if otherwise
 */
bool ArgParser::getComputeChecksumFlag() const {
    return this->computeChecksumFlag;
}


void ArgParser::loadArguments(int argc, char **argv) {
    for (int x = 1; x < argc; x++) {
        if (strlen(argv[x]) > 1000)
            throw invalid_argument("[ERROR]: ArgParser: argument too large (bigger than 1000 characters)");

        this->argList.emplace_back(argv[x]);
    }
}


ArgParser::ArgParser() = default;
