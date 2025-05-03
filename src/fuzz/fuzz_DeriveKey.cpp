#include <string>
#include <string_view>
#include <cstdint>
#include <vector>
#include <stdexcept>

#include <iostream>

#include "../app/DeriveKey/DeriveKey.h"

/**
 * Function prepares fuzzying of DeriveKey
*/
extern "C" int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size)
{
    auto s = std::string(reinterpret_cast<const char *>(Data), Size);
    auto sv = std::string_view(s);

    std::vector<std::string> values;

    for (size_t pos = sv.find_first_of('\n'); pos != std::string_view::npos; pos = sv.find_first_of('\n'))
    {
        values.push_back(std::string(sv.begin(), sv.begin() + pos));
        sv.remove_prefix(pos + 1);
    }

    auto filepath = std::string(sv.begin(), sv.end());

    try { deriveKey(values, filepath); }
    catch (...) {}

    return 0;  // Values other than 0 and -1 are reserved for future use.
}