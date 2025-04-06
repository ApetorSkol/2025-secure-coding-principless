/**
 * Project: PV286 2024/2025 Project
 * @file ScriptExpression.h
 * @author Slivka Matej (xslivka1)
 * @brief Implementation of Checksum script
 * @date 2025-03-25
 *
 * @copyright Copyright (c) 2025
 *
 */

#pragma once

#include <cstdint>
#include <string>
#include <vector>

using namespace std;

class ScriptExpression {
private:
	const string CHECKSUM_CHARSET = "qpzry9x8gf2tvdw0s3jn54khce6mua7l";
	const string INPUT_CHARSET = "0123456789()[],'/*abcdefgh@:$%{}IJKLMNOPQRSTUVWXYZ&+-.;<=>?!^_|~ijklmnopqrstuvwxyzABCDEFGH`#\"\\ ";
	const vector<uint64_t> GENERATOR = {0xF5DEE51989, 0xA9FDCA3312, 0x1BAB10E32D, 0x3706B1677A, 0x644D626FFD};

	bool ComputeChecksumFlag;
	bool VerifyChecksumFlag;
	vector<string> ArgValuesVector;
	string Script;

	uint64_t calculateDescsumPolymod(vector<long int> symbols);
	vector<long int> expandDecsum(string s);
	bool checkDecsum(string s);
	string createDecsum(string s, bool includeInput);

	void computeChecksum();
	void verifyChecksum();
public:
	ScriptExpression(vector<string> argValuesVector, bool computeChecksumFlag, bool verifyChecksumFlag);
	void parse();
};