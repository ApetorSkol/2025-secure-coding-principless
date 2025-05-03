#include <string>
#include <string_view>
#include <cstdint>
#include <vector>
#include <stdexcept>

#include "../app/ArgParser/ArgParser.h"

/**
 * Function prepares fuzzying of argParser
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

    values.push_back(std::string(sv));

    std::vector<char*> cstrs;
    for (auto& s : values) {
        cstrs.push_back(const_cast<char*>(s.c_str()));
    }
    char** argv = cstrs.data();

    try {
        ArgParser argParser;
        argParser.loadArguments(cstrs.size(), argv);
        argParser.parse();
    }
    catch (...) {}

    return 0;  // Values other than 0 and -1 are reserved for future use.
}