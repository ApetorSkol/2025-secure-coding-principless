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


class ScriptExpression {
private:
	const std::string CHECKSUM_CHARSET = "qpzry9x8gf2tvdw0s3jn54khce6mua7l";
	const std::string INPUT_CHARSET = "0123456789()[],'/*abcdefgh@:$%{}IJKLMNOPQRSTUVWXYZ&+-.;<=>?!^_|~ijklmnopqrstuvwxyzABCDEFGH`#\"\\ ";
	const std::vector<uint64_t> GENERATOR = {0xF5DEE51989, 0xA9FDCA3312, 0x1BAB10E32D, 0x3706B1677A, 0x644D626FFD};

	bool ComputeChecksumFlag;
	bool VerifyChecksumFlag;
	std::vector<std::string> ArgValuesVector;
	std::string Script;

	uint64_t calculateDescsumPolymod(std::vector<long int> symbols);
	std::vector<long int> expandDecsum(std::string s);
	bool checkDecsum(std::string s);
	std::string createDecsum(std::string s, bool includeInput);

	void computeChecksum();
	void verifyChecksum();
public:
	ScriptExpression(std::vector<std::string> argValuesVector, bool computeChecksumFlag, bool verifyChecksumFlag);
	void parse();
};