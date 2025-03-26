/**
 * Project: PV286 2024/2025 Project
 * @file ScriptExpression.cpp
 * @author Slivka Matej (xslivka1)
 * @brief Implementation of Checksum script
 * @date 2025-03-25
 *
 * @copyright Copyright (c) 2025
 *
 */

#include "ScriptExpression.h"
#include <string>
#include <iostream>
#include <vector>
#include <cstdint>


/**
 * Function that computes the descriptor checksum.
 * It which was defined on website https://github.com/bitcoin/bips/blob/master/bip-0380.mediawiki#checksum
 * It was defined as python script below, which I remade into C++ code
 * @param symbols is vector of supposed checksum which is checked
 * @return descriptor checksum
 *def descsum_polymod(symbols):
 *	"""Internal function that computes the descriptor checksum."""
 *	chk = 1
 *	for value in symbols:
 *		top = chk >> 35
 *		chk = (chk & 0x7ffffffff) << 5 ^ value
 *		for i in range(5):
 *			chk ^= GENERATOR[i] if ((top >> i) & 1) else 0
 *	return chk
 */
uint64_t ScriptExpression::calculateDescsumPolymod(vector<long int> symbols){
	uint64_t chk = 1;
	for (uint64_t value : symbols) {
		uint64_t top = chk >> 35;
        chk = (chk & 0x7ffffffff) << 5 ^ value;
		for (int i = 0; i < 5; i++) {
            if ((top >> i) & 1) {
                chk ^= this->GENERATOR[i];
            }
            else{
              	chk ^= 0;
            }
		}
	}
	return chk;
}


/**
 * Function expands character to symbol.
 * It which was defined on website https://github.com/bitcoin/bips/blob/master/bip-0380.mediawiki#checksum
 * It was defined as python script below, which I remade into C++ code
 * @param string s is string which we are checking checksum from
 * @return true if Decusm is correct, in other case return false
 *def descsum_expand(s):
 *	"""Internal function that does the character to symbol expansion"""
 *	groups = []
 *	symbols = []
 *	for c in s:
 *		if not c in INPUT_CHARSET:
 * 			return None
 *		v = INPUT_CHARSET.find(c)
 *		symbols.append(v & 31)
 *		groups.append(v >> 5)
 *		if len(groups) == 3:
 *			symbols.append(groups[0] * 9 + groups[1] * 3 + groups[2])
 *			groups = []
 *	if len(groups) == 1:
 *		symbols.append(groups[0])
 *	elif len(groups) == 2:
 *		symbols.append(groups[0] * 3 + groups[1])
 *	return symbols
 */
vector<long int> ScriptExpression::expandDecsum(string s) {
	vector<long int> groups;
	vector<long int> symbols;

	for (char c : s) {
		size_t pos = this->INPUT_CHARSET.find(c);
		if (pos == string::npos) {
			cout << "Error ahppend expandDecsum" << endl;
			return {};  // Return empty vector indicating error
		}

		int v = static_cast<int>(pos);
		symbols.push_back(v & 31);
		groups.push_back(v >> 5);

		if (groups.size() == 3) {
			symbols.push_back(groups[0] * 9 + groups[1] * 3 + groups[2]);
			groups.clear();
		}
	}

	if (groups.size() == 1) {
		symbols.push_back(groups[0]);
	} else if (groups.size() == 2) {
		symbols.push_back(groups[0] * 3 + groups[1]);
	}

	return symbols;
}


/**
 * Function checks decsum which was defined on website https://github.com/bitcoin/bips/blob/master/bip-0380.mediawiki#checksum
 * It was defined as python script below, which I remade into C++ code
 * @param string s is string which we are checking checksum from
 * @return true if Decusm is correct, in other case return false
 *def descsum_check(s):
 *	"""Verify that the checksum is correct in a descriptor"""
 *	if s[-9] != '#':
 *		return False
 *	if not all(x in CHECKSUM_CHARSET for x in s[-8:]):
 *		return False
 *	symbols = descsum_expand(s[:-9]) + [CHECKSUM_CHARSET.find(x) for x in s[-8:]]
 *	return descsum_polymod(symbols) == 1
 */
bool ScriptExpression::checkDecsum(string s) {

	if (s.size() < 9 || s[s.size() - 9] != '#') {
		cout << "Error wrong checksum size" << endl;
		return false;
	}

	string checksumPart = s.substr(s.size() - 8);
	for (char c : checksumPart) {
		if (this->CHECKSUM_CHARSET.find(c) == string::npos) {
			cout << "Error wrong char in checksum" << endl;
			return false;
		}
	}

	vector<long int> symbols = this->expandDecsum(s.substr(0, s.size() - 9));
	if (symbols.empty()) {
		return false;
	}
	for (char c : checksumPart) {
		symbols.push_back(static_cast<long int>(this->CHECKSUM_CHARSET.find(c)));
	}
	return calculateDescsumPolymod(symbols) == 1;
}


/**
 * Function creates Decsum which was defined on website https://github.com/bitcoin/bips/blob/master/bip-0380.mediawiki#checksum
 * It was defined as python script below, which I remade into C++ code
 * @param string s is string which we are creating checksum from
 * @return string of as SCRIPT#CHECKSUM where SCRIPT is paramter + # + CHECKSUM which is computed checksum
 *
 *def descsum_create(s):
 *	"""Add a checksum to a descriptor without"""
 *	symbols = descsum_expand(s) + [0, 0, 0, 0, 0, 0, 0, 0]
 *	checksum = descsum_polymod(symbols) ^ 1
 *	return s + '#' + ''.join(CHECKSUM_CHARSET[(checksum >> (5 * (7 - i))) & 31] for i in range(8))
 */
string ScriptExpression::createDecsum(string s) {
	vector<long int> symbols = this->expandDecsum(s);
	symbols.insert(symbols.end(), 8, 0);
	uint64_t checksum = this->calculateDescsumPolymod(symbols) ^ 1;

	string checksumStr;
	for (int i = 0; i < 8; i++) {
		uint32_t index = (checksum >> (5 * (7 - i))) & 31;
		checksumStr += this->CHECKSUM_CHARSET[index];
	}

	return s + '#' + checksumStr;
}


/**
 * Public getter for the ComputeChecksum flag
 * @return true if argument is provided, false if otherwise
 */
void ScriptExpression::parse() {
// part which is used for debugging
//	cout << "Parsing began" << endl;
//	cout << this->calculateDescsumPolymod({'8','9','f','8','s','p','x','m'}) << endl;
//	for (auto i: (this->expandDecsum("887174483821"))){
//		cout << i << ' ';
//	}
//	cout << endl << this->checkDecsum("raw(deadbeef)#89f8spxm") << endl;
//    cout << endl << this->createDecsum("raw(deadbeef)") << endl;
// TODO FIX LOGIC	
	cout << this->createDecsum("raw(deadbeef)") << endl;
}


/**
 * Constructor for initialization of defined class with defined arguments
 * @param argValuesVector is vector of provided values
 * @param computeChecksumFlag is flag which tells if compute checksum flag was mentioned
 * @param verifyChecksumFlag is flag which tells if verify checksum flag was mentione
 */
ScriptExpression::ScriptExpression(vector<string> argValuesVector,bool computeChecksumFlag, bool verifyChecksumFlag) {
  	this->ArgValuesVector = argValuesVector;
    this->ComputeChecksumFlag = computeChecksumFlag;
    this->VerifyChecksumFlag = verifyChecksumFlag;
}