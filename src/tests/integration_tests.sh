#!/bin/bash

# Macros
BINARY="../../bip380"
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Function for valid testing
run_test() {
    description=$1
    command=$2
    expected=$3

    output=$(eval "$command" 2>&1)
    if [[ "$output" == "$expected" ]]; then
        echo -e "${GREEN}✔ $description${NC}"
    else
        echo -e "${RED}✘ $description${NC}"
        echo "  Expected: $expected"
        echo "  Got     : $output"
        FAILED_TESTS=1
    fi
}

# Function for fail testing
run_fail_test() {
    test_name="$1"
    test_command="$2"

    # Execute the command and capture its return status
    output=$(eval "$test_command" 2>&1)
    local return_status=$?

    if [[ $return_status -ne 0 ]]; then
        # Command failed as expected
        echo -e "${GREEN}✔ Expected failure: ${test_name}${NC}";
    else
        # Command succeeded but was expected to fail
        FAILED_TESTS=1
        echo -e "${RED}✘ Expected failure but got result instead.\n Result: ${output}${NC}"
    fi
}

#------------------------------- COMMON TESTS -------------------------------
# Help outputs
echo -e "\n${GREEN}✔ [COMMON] Running tests for printing help ...${NC}"
run_test "Help: --help" "$BINARY --help | grep -q -i 'help' && echo OK" "OK"
run_test "Help: derive-key --help" "$BINARY derive-key --help | grep -q -i 'help' && echo OK" "OK"
run_test "Help: --help derive-key" "$BINARY --help derive-key | grep -q -i 'help' && echo OK" "OK"
run_test "Help: key-expression --help" "$BINARY key-expression --help | grep -q -i 'help' && echo OK" "OK"
run_test "Help: --help key-expression" "$BINARY --help key-expression | grep -q -i 'help' && echo OK" "OK"
run_test "Help: script-expression --help" "$BINARY script-expression --help | grep -q -i 'help' && echo OK" "OK"
run_test "Help: --help script-expression" "$BINARY --help script-expression | grep -q -i 'help' && echo OK" "OK"

#------------------------------- DERIVE-KEY TESTS -------------------------------

# Reference output
EXPECTED1="xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8:xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi"
EXPECTED2="xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB:xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U"
EXPECTED3="xpub6H1LXWLaKsWFhvm6RVpEL9P4KfRZSW7abD2ttkWP3SSQvnyA8FSVqNTEcYFgJS2UaFcxupHiYkro49S8yGasTvXEYBVPamhGW6cFJodrTHy"
EXPECTED4="xprvA41z7zogVVwxVSgdKUHDy1SKmdb533PjDz7J6N6mV6uS3ze1ai8FHa8kmHScGpWmj4WggLyQjgPie1rFSruoUihUZREPSL39UNdE3BBDu76"
EXPECTED_DERIVED="xpub6AvUGrnEpfvJBbfx7sQ89Q8hEMPM65UteqEX4yUbUiES2jHfjexmfJoxCGSwFMZiPBaKQT1RiKWrKfuDV4vpgVs4Xn8PpPTR2i79rwHd4Zr:xprv9ww7sMFLzJMzy7bV1qs7nGBxgKYrgcm3HcJvGb4yvNhT9vxXC7eX7WVULzCfxucFEn2TsVvJw25hH9d4mchywguGQCZvRgsiRaTY1HCqN8G"

# --- Valid tests ---
echo -e "\n${GREEN}✔ [DERIVE-KEY] Running valid tests ...${NC}"
run_test "Hex input without 0x" "$BINARY derive-key 000102030405060708090a0b0c0d0e0f" "$EXPECTED1"
run_test "Hex input with spaces" "$BINARY derive-key '00 0102030405060708090a0b0c0d0e0f'" "$EXPECTED1"
run_test "Hex input with tabs/multiple spaces" "$BINARY derive-key \$'00   01\t02030405060708090a0b0c0d0e0f'" "$EXPECTED1"
run_test "Piped hex input" "echo -e '00   01\t02030405060708090a0b0c0d0e0f' | $BINARY derive-key -" "$EXPECTED1"
run_test "Hex input with uppercase" "$BINARY derive-key '00 0102030405060708090A0B0c0d0E0F'" "$EXPECTED1"
run_test "Longer hex seed" "$BINARY derive-key fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542" "$EXPECTED2"
run_test "Piped seed with dash" "echo '000102030405060708090a0b0c0d0e0f' | $BINARY derive-key -" "$EXPECTED1"

# --- Multiple outputs ---
multi_output=$($BINARY derive-key - <<EOF
000102030405060708090a0b0c0d0e0f
fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542
EOF
)

expected_multi="$EXPECTED1
$EXPECTED2"
[[ "$multi_output" == "$expected_multi" ]] && echo -e "${GREEN}✔ [DERIVE-KEY] Multiple lines from stdin${NC}" || {
    echo -e "${RED}✘ Multiple lines from stdin${NC}"
    echo "Expected:"
    echo "$expected_multi"
    echo "Got:"
    echo "$multi_output"
}

# Derive with path
echo -e "\n${GREEN}✔ [DERIVE-KEY] Running tests with derive path ...${NC}"
run_test "Derive from xpub with path" "$BINARY derive-key xpub6D4BDPcP2GT577Vvch3R8wDkScZWzQzMMUm3PWbmWvVJrZwQY4VUNgqFJPMM3No2dFDFGTsxxpG5uJh7n7epu4trkrX7x7DogT5Uv6fcLW5 --path 2/1000000000" "$EXPECTED3"
run_test "Derive from xprv with path" "$BINARY derive-key xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs --path 2H/2/1000000000" "$EXPECTED3:$EXPECTED4"

# --- Fail tests ---
echo -e "\n${GREEN}✔ [DERIVE-KEY] Running tests that are expected to fail ...${NC}"
run_fail_test "pub/prv mismatch" "$BINARY derive-key xpub661MyMwAqRdbcEYS8w7XLSVeEsBXy79zSzH1J8vCdxAZningWLdN3zgtU6LBpB85b3D2yc8sfvZU521AAwdZafEz7mnzBBsz4wKY5fTtTQBm"
run_fail_test "invalid checksum" "$BINARY derive-key xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHL"
run_fail_test "invalid seed" "$BINARY derive-key $'00\r0102030405060708090a0b0c0d0e0f'"
run_fail_test "invalid seed" "$BINARY derive-key $'0\t0 0 1 02030405060708090a0b0c0d0e0f'"

# --- Extra ---
echo -e "\n${GREEN}✔ [DERIVE-KEY] Running extra tests ...${NC}"
run_test "Piped hex input with path (variant 1)" "echo '000102030405060708090a0b0c0d0e0f' | $BINARY derive-key - --path 0/1" "$EXPECTED_DERIVED"
run_test "Piped hex input with path (variant 2)" "$BINARY derive-key --path 0/1 - <<< '000102030405060708090a0b0c0d0e0f'" "$EXPECTED_DERIVED"

multi_with_empty_lines_output=$($BINARY derive-key - <<EOF
000102030405060708090a0b0c0d0e0f

fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542

EOF
)

[[ "$multi_with_empty_lines_output" == "$expected_multi" ]] && echo -e "${GREEN}✔ Multiple stdin lines (with empty lines)${NC}" || {
    echo -e "${RED}✘ Multiple stdin lines (with empty lines)${NC}"
    echo "Expected:"
    echo "$expected_multi"
    echo "Got:"
    echo "$multi_with_empty_lines_output"
}

# Position of path and -
echo -e "\n${GREEN}✔ [DERIVE-KEY] Running tests for checking path and dash (-) ...${NC}"
run_test "Path before dash" "$BINARY derive-key --path 0/1 - <<< '000102030405060708090a0b0c0d0e0f'" "$EXPECTED_DERIVED"
run_test "Path after dash" "$BINARY derive-key - --path 0/1 <<< '000102030405060708090a0b0c0d0e0f'" "$EXPECTED_DERIVED"

#------------------------------- SCRIPT-EXPRESSION TESTS -------------------------------

PUB_KEY1="xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"
PUB_KEY2="xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB"
PUB_KEY3="xpub6H1LXWLaKsWFhvm6RVpEL9P4KfRZSW7abD2ttkWP3SSQvnyA8FSVqNTEcYFgJS2UaFcxupHiYkro49S8yGasTvXEYBVPamhGW6cFJodrTHy"
PRV_KEY1="xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi"
PRV_KEY2="xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U"
PRV_KEY3="xprvA41z7zogVVwxVSgdKUHDy1SKmdb533PjDz7J6N6mV6uS3ze1ai8FHa8kmHScGpWmj4WggLyQjgPie1rFSruoUihUZREPSL39UNdE3BBDu76"
WIF="[deadbeef/0h/1h/2]5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ"

# -------- Valid tests --------
# --- RAW ---
echo -e "\n\n${GREEN}✔ [SCRIPT-EXPRESSION] Running valid tests for RAW with no flags ...${NC}"
run_test "Basic raw" "$BINARY script-expression 'raw(deadbeef)#89f8spxm'" "raw(deadbeef)#89f8spxm"
run_test "Basic raw, no checksum" "$BINARY script-expression 'raw(deadbeef)'" "raw(deadbeef)"
run_test "Basic raw, wrong checksum" "$BINARY script-expression 'raw(deadbeef)#89f8spxx'" "raw(deadbeef)#89f8spxx"
run_test "Raw with space padding" "$BINARY script-expression 'raw( deadbeef )#985dv2zl'" "raw( deadbeef )#985dv2zl"
run_test "Raw with space padding, wrong checksum" "$BINARY script-expression 'raw( deadbeef )#99999999'" "raw( deadbeef )#99999999"
run_test "Raw CAPS-LOCK" "$BINARY script-expression 'raw(DEADBEEF)#49w2hhz7'" "raw(DEADBEEF)#49w2hhz7"
run_test "Raw CAPS-LOCK and space" "$BINARY script-expression 'raw(DEAD BEEF)#qqn7ll2h'" "raw(DEAD BEEF)#qqn7ll2h"
run_test "Raw CAPS-LOCK and multiple spaces" "$BINARY script-expression 'raw(DEA D BEEF)#egs9fwsr'" "raw(DEA D BEEF)#egs9fwsr"
run_test "Raw duplicated hex" "$BINARY script-expression 'raw(deadbeefdeadbeef)'" "raw(deadbeefdeadbeef)"


echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running valid tests for RAW --verify-checksum ...${NC}"
run_test "Basic raw" "$BINARY script-expression --verify-checksum 'raw(deadbeef)#89f8spxm'" "OK"
run_test "Raw with space padding" "$BINARY script-expression --verify-checksum 'raw( deadbeef )#985dv2zl'" "OK"
run_test "Raw CAPS-LOCK" "$BINARY script-expression --verify-checksum 'raw(DEADBEEF)#49w2hhz7'" "OK"
run_test "Raw CAPS-LOCK and space" "$BINARY script-expression --verify-checksum 'raw(DEAD BEEF)#qqn7ll2h'" "OK"
run_test "Raw CAPS-LOCK and multiple spaces" "$BINARY script-expression --verify-checksum 'raw(DEA D BEEF)#egs9fwsr'" "OK"

echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running valid tests for RAW --compute-checksum ...${NC}"

run_test "Basic raw" "$BINARY script-expression --compute-checksum 'raw(deadbeef)#89f8spxm'" "raw(deadbeef)#89f8spxm"
run_test "Raw with space padding" "$BINARY script-expression --compute-checksum 'raw( deadbeef )#985dv2zl'" "raw( deadbeef )#985dv2zl"
run_test "Raw CAPS-LOCK" "$BINARY script-expression --compute-checksum 'raw(DEADBEEF)#49w2hhz7'" "raw(DEADBEEF)#49w2hhz7"
run_test "Raw CAPS-LOCK and space" "$BINARY script-expression --compute-checksum 'raw(DEAD BEEF)#qqn7ll2h'" "raw(DEAD BEEF)#qqn7ll2h"
run_test "Raw CAPS-LOCK and multiple spaces" "$BINARY script-expression --compute-checksum 'raw(DEA D BEEF)#egs9fwsr'" "raw(DEA D BEEF)#egs9fwsr"
run_test "Raw Duplicated hex" "$BINARY script-expression --compute-checksum 'raw(deadbeefdeadbeef)'" "raw(deadbeefdeadbeef)#kymq966v"

run_test "Raw, short checksum1" "$BINARY script-expression --compute-checksum 'raw(deadbeef)#89f8spx'" "raw(deadbeef)#89f8spxm"
run_test "Raw, short checksum2" "$BINARY script-expression --compute-checksum 'raw(deadbeef)#89f8sp'" "raw(deadbeef)#89f8spxm"
run_test "Raw, short checksum3" "$BINARY script-expression --compute-checksum 'raw(deadbeef)#89f8s'" "raw(deadbeef)#89f8spxm"
run_test "Raw, short checksum4" "$BINARY script-expression --compute-checksum 'raw(deadbeef)#89f8'" "raw(deadbeef)#89f8spxm"
run_test "Raw, short checksum5" "$BINARY script-expression --compute-checksum 'raw(deadbeef)#89f'" "raw(deadbeef)#89f8spxm"
run_test "Raw, short checksum6" "$BINARY script-expression --compute-checksum 'raw(deadbeef)#89'" "raw(deadbeef)#89f8spxm"
run_test "Raw, short checksum7" "$BINARY script-expression --compute-checksum 'raw(deadbeef)#8'" "raw(deadbeef)#89f8spxm"
run_test "Raw, short checksum8" "$BINARY script-expression --compute-checksum 'raw(deadbeef)#'" "raw(deadbeef)#89f8spxm"
run_test "Raw, no checksum" "$BINARY script-expression --compute-checksum 'raw(deadbeef)'" "raw(deadbeef)#89f8spxm"
run_test "Raw, large checksum" "$BINARY script-expression --compute-checksum 'raw(deadbeef)#89f8spxm1'" "raw(deadbeef)#89f8spxm"
run_test "Raw, large checksum2" "$BINARY script-expression --compute-checksum 'raw(deadbeef)#89f8spxm12'" "raw(deadbeef)#89f8spxm"
run_test "Raw, extra large checksum" "$BINARY script-expression --compute-checksum 'raw(deadbeef)#89f8spxmdadsadasdasdasdgdgvvqwufybiunoaskcmajnkxzbhvwiuheoakmsdkjbhaeiwhuijkfdvjbviauoi<knfdjbshifaaiDJADBDSIVBSOZL<CSA '" "raw(deadbeef)#89f8spxm"
run_test "Raw, checksum is another script" "$BINARY script-expression --compute-checksum 'raw(deadbeef)#sh(multi(0, xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8))'" "raw(deadbeef)#89f8spxm"
run_test "Raw, checksum has multiple hashes" "$BINARY script-expression --compute-checksum 'raw(deadbeef)##sh(multi(0, xpub661MyMwAqRbc#gS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8#)#)#))'" "raw(deadbeef)#89f8spxm"

# --- PK ---
echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running valid tests for PK with no flags ...${NC}"
run_test "pk private key1" "$BINARY script-expression 'pk($PRV_KEY1)#axav5m0j'" "pk($PRV_KEY1)#axav5m0j"
run_test "pk private key2" "$BINARY script-expression 'pk($PRV_KEY2)#cga9zxuz'" "pk($PRV_KEY2)#cga9zxuz"
run_test "pk private key3" "$BINARY script-expression 'pk($PRV_KEY3)#lqn0r8mc'" "pk($PRV_KEY3)#lqn0r8mc"
run_test "pk public key1" "$BINARY script-expression 'pk($PUB_KEY1)#dse8d4mx'" "pk($PUB_KEY1)#dse8d4mx"
run_test "pk public key2" "$BINARY script-expression 'pk($PUB_KEY2)#ew5qtxuy'" "pk($PUB_KEY2)#ew5qtxuy"
run_test "pk public key3" "$BINARY script-expression 'pk($PUB_KEY3)#l7e8w7wc'" "pk($PUB_KEY3)#l7e8w7wc"
run_test "pk wif" "$BINARY script-expression 'pk($WIF)#alm7cpqh'" "pk($WIF)#alm7cpqh"

run_test "pk private key1, no checksum" "$BINARY script-expression 'pk($PRV_KEY1)'" "pk($PRV_KEY1)"
run_test "pk private key2, no checksum" "$BINARY script-expression 'pk($PRV_KEY2)'" "pk($PRV_KEY2)"
run_test "pk private key3, no checksum" "$BINARY script-expression 'pk($PRV_KEY3)'" "pk($PRV_KEY3)"
run_test "pk public key1, no checksum" "$BINARY script-expression 'pk($PUB_KEY1)'" "pk($PUB_KEY1)"
run_test "pk public key2, no checksum" "$BINARY script-expression 'pk($PUB_KEY2)'" "pk($PUB_KEY2)"
run_test "pk public key3, no checksum" "$BINARY script-expression 'pk($PUB_KEY3)'" "pk($PUB_KEY3)"
run_test "pk wif, no checksum" "$BINARY script-expression 'pk($WIF)'" "pk($WIF)"

run_test "pk private key1, wrong checksum" "$BINARY script-expression 'pk($PRV_KEY1)#axav5maj'" "pk($PRV_KEY1)#axav5maj"
run_test "pk private key2, wrong checksum" "$BINARY script-expression 'pk($PRV_KEY2)#cga9zxux'" "pk($PRV_KEY2)#cga9zxux"
run_test "pk private key3, wrong checksum" "$BINARY script-expression 'pk($PRV_KEY3)#lqn0r8mx'" "pk($PRV_KEY3)#lqn0r8mx"
run_test "pk public key1, wrong checksum" "$BINARY script-expression 'pk($PUB_KEY1)#dse8d4mc'" "pk($PUB_KEY1)#dse8d4mc"
run_test "pk public key2, wrong checksum" "$BINARY script-expression 'pk($PUB_KEY2)#ew5qtxux'" "pk($PUB_KEY2)#ew5qtxux"
run_test "pk public key3, wrong checksum" "$BINARY script-expression 'pk($PUB_KEY3)#l7e8w7ww'" "pk($PUB_KEY3)#l7e8w7ww"
run_test "pk wif, wrong checksum" "$BINARY script-expression 'pk($WIF)#alm7cpqc'" "pk($WIF)#alm7cpqc"

run_test "pk private key1, with space padding" "$BINARY script-expression 'pk( $PRV_KEY1 )#e3pmfztz'" "pk( $PRV_KEY1 )#e3pmfztz"
run_test "pk private key2, with space padding" "$BINARY script-expression 'pk( $PRV_KEY2 )#85n8tjw6'" "pk( $PRV_KEY2 )#85n8tjw6"
run_test "pk private key3, with space padding" "$BINARY script-expression 'pk( $PRV_KEY3 )#g5dgutdf'" "pk( $PRV_KEY3 )#g5dgutdf"
run_test "pk public key1, with space padding" "$BINARY script-expression 'pk( $PUB_KEY1 )#nhrdq9w4'" "pk( $PUB_KEY1 )#nhrdq9w4"
run_test "pk public key2, with space padding" "$BINARY script-expression 'pk( $PUB_KEY2 )#cn8qmyud'" "pk( $PUB_KEY2 )#cn8qmyud"
run_test "pk public key3, with space padding" "$BINARY script-expression 'pk( $PUB_KEY3 )#qecu2240'" "pk( $PUB_KEY3 )#qecu2240"
run_test "pk wif, with space padding" "$BINARY script-expression 'pk( $WIF )#5lchaun8'" "pk( $WIF )#5lchaun8"

run_test "pk private key1, with space padding" "$BINARY script-expression 'pk( $PRV_KEY1 )#99999999'" "pk( $PRV_KEY1 )#99999999"
run_test "pk private key2, with space padding" "$BINARY script-expression 'pk( $PRV_KEY2 )#99999999'" "pk( $PRV_KEY2 )#99999999"
run_test "pk private key3, with space padding" "$BINARY script-expression 'pk( $PRV_KEY3 )#99999999'" "pk( $PRV_KEY3 )#99999999"
run_test "pk public key1, with space padding" "$BINARY script-expression 'pk( $PUB_KEY1 )#99999999'" "pk( $PUB_KEY1 )#99999999"
run_test "pk public key2, with space padding" "$BINARY script-expression 'pk( $PUB_KEY2 )#99999999'" "pk( $PUB_KEY2 )#99999999"
run_test "pk public key3, with space padding" "$BINARY script-expression 'pk( $PUB_KEY3 )#99999999'" "pk( $PUB_KEY3 )#99999999"
run_test "pk wif, with space padding" "$BINARY script-expression 'pk( $WIF )#99999999'" "pk( $WIF )#99999999"

echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running valid tests for PK --verify-checksum ...${NC}"
run_test "pk --verify-checksum private key1" "$BINARY script-expression --verify-checksum 'pk($PRV_KEY1)#dse8d4mx'" "OK"
run_test "pk --verify-checksum private key2" "$BINARY script-expression --verify-checksum 'pk($PRV_KEY2)#ew5qtxuy'" "OK"
run_test "pk --verify-checksum private key3" "$BINARY script-expression --verify-checksum 'pk($PRV_KEY3)#l7e8w7wc'" "OK"
run_test "pk --verify-checksum public key1" "$BINARY script-expression --verify-checksum 'pk($PUB_KEY1)#axav5m0j'" "OK"
run_test "pk --verify-checksum public key2" "$BINARY script-expression --verify-checksum 'pk($PUB_KEY2)#cga9zxuz'" "OK"
run_test "pk --verify-checksum public key3" "$BINARY script-expression --verify-checksum 'pk($PUB_KEY3)#lqn0r8mc'" "OK"
run_test "pk --verify-checksum wif" "$BINARY script-expression --verify-checksum 'pk($WIF)#alm7cpqh'" "OK"

echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running valid tests for PK --compute-checksum ...${NC}"
run_test "pk --compute-checksum private key1" "$BINARY script-expression --compute-checksum 'pk($PRV_KEY1)#dse8d4mx'" "pk($PRV_KEY1)#dse8d4mx"
run_test "pk --compute-checksum private key2" "$BINARY script-expression --compute-checksum 'pk($PRV_KEY2)#ew5qtxuy'" "pk($PRV_KEY2)#ew5qtxuy"
run_test "pk --compute-checksum private key3" "$BINARY script-expression --compute-checksum 'pk($PRV_KEY3)#l7e8w7wc'" "pk($PRV_KEY3)#l7e8w7wc"
run_test "pk --compute-checksum public key1" "$BINARY script-expression --compute-checksum 'pk($PUB_KEY1)#axav5m0j'" "pk($PUB_KEY1)#axav5m0j"
run_test "pk --compute-checksum public key2" "$BINARY script-expression --compute-checksum 'pk($PUB_KEY2)#cga9zxuz'" "pk($PUB_KEY2)#cga9zxuz"
run_test "pk --compute-checksum public key3" "$BINARY script-expression --compute-checksum 'pk($PUB_KEY3)#lqn0r8mc'" "pk($PUB_KEY3)#lqn0r8mc"
run_test "pk --compute-checksum wif" "$BINARY script-expression --compute-checksum 'pk($WIF)#alm7cpqh'" "pk($WIF)#alm7cpqh"

run_test "pk --compute-checksum private key1, with space padding" "$BINARY script-expression 'pk( $PRV_KEY1 )#e3pmfztz'" "pk( $PRV_KEY1 )#e3pmfztz"
run_test "pk --compute-checksum private key2, with space padding" "$BINARY script-expression 'pk( $PRV_KEY2 )#85n8tjw6'" "pk( $PRV_KEY2 )#85n8tjw6"
run_test "pk --compute-checksum private key3, with space padding" "$BINARY script-expression 'pk( $PRV_KEY3 )#g5dgutdf'" "pk( $PRV_KEY3 )#g5dgutdf"
run_test "pk --compute-checksum public key1, with space padding" "$BINARY script-expression 'pk( $PUB_KEY1 )#nhrdq9w4'" "pk( $PUB_KEY1 )#nhrdq9w4"
run_test "pk --compute-checksum public key2, with space padding" "$BINARY script-expression 'pk( $PUB_KEY2 )#cn8qmyud'" "pk( $PUB_KEY2 )#cn8qmyud"
run_test "pk --compute-checksum public key3, with space padding" "$BINARY script-expression 'pk( $PUB_KEY3 )#qecu2240'" "pk( $PUB_KEY3 )#qecu2240"
run_test "pk --compute-checksum wif, with space padding" "$BINARY script-expression 'pk( $WIF )#5lchaun8'" "pk( $WIF )#5lchaun8"

run_test "pk --compute-checksum private key1, short checksum1" "$BINARY script-expression --compute-checksum 'pk($PRV_KEY1)#dse8d4m'" "pk($PRV_KEY1)#dse8d4mx"
run_test "pk --compute-checksum private key1, short checksum2" "$BINARY script-expression --compute-checksum 'pk($PRV_KEY1)#dse8d4'" "pk($PRV_KEY1)#dse8d4mx"
run_test "pk --compute-checksum private key1, short checksum3" "$BINARY script-expression --compute-checksum 'pk($PRV_KEY1)#dse8d'" "pk($PRV_KEY1)#dse8d4mx"
run_test "pk --compute-checksum private key1, short checksum4" "$BINARY script-expression --compute-checksum 'pk($PRV_KEY1)#dse8'" "pk($PRV_KEY1)#dse8d4mx"
run_test "pk --compute-checksum private key1, short checksum5" "$BINARY script-expression --compute-checksum 'pk($PRV_KEY1)#dse'" "pk($PRV_KEY1)#dse8d4mx"
run_test "pk --compute-checksum private key1, short checksum6" "$BINARY script-expression --compute-checksum 'pk($PRV_KEY1)#ds'" "pk($PRV_KEY1)#dse8d4mx"
run_test "pk --compute-checksum private key1, short checksum7" "$BINARY script-expression --compute-checksum 'pk($PRV_KEY1)#d'" "pk($PRV_KEY1)#dse8d4mx"
run_test "pk --compute-checksum private key1, short checksum8" "$BINARY script-expression --compute-checksum 'pk($PRV_KEY1)#'" "pk($PRV_KEY1)#dse8d4mx"
run_test "pk --compute-checksum private key1, short checksum9" "$BINARY script-expression --compute-checksum 'pk($PRV_KEY1)'" "pk($PRV_KEY1)#dse8d4mx"

run_test "pk --compute-checksum public key1, short checksum1" "$BINARY script-expression --compute-checksum 'pk($PUB_KEY1)#axav5m0'" "pk($PUB_KEY1)#axav5m0j"
run_test "pk --compute-checksum public key1, short checksum2" "$BINARY script-expression --compute-checksum 'pk($PUB_KEY1)#axav5m'" "pk($PUB_KEY1)#axav5m0j"
run_test "pk --compute-checksum public key1, short checksum3" "$BINARY script-expression --compute-checksum 'pk($PUB_KEY1)#axav5'" "pk($PUB_KEY1)#axav5m0j"
run_test "pk --compute-checksum public key1, short checksum4" "$BINARY script-expression --compute-checksum 'pk($PUB_KEY1)#axav'" "pk($PUB_KEY1)#axav5m0j"
run_test "pk --compute-checksum public key1, short checksum5" "$BINARY script-expression --compute-checksum 'pk($PUB_KEY1)#axa'" "pk($PUB_KEY1)#axav5m0j"
run_test "pk --compute-checksum public key1, short checksum6" "$BINARY script-expression --compute-checksum 'pk($PUB_KEY1)#ax'" "pk($PUB_KEY1)#axav5m0j"
run_test "pk --compute-checksum public key1, short checksum7" "$BINARY script-expression --compute-checksum 'pk($PUB_KEY1)#a'" "pk($PUB_KEY1)#axav5m0j"
run_test "pk --compute-checksum public key1, short checksum8" "$BINARY script-expression --compute-checksum 'pk($PUB_KEY1)#'" "pk($PUB_KEY1)#axav5m0j"
run_test "pk --compute-checksum public key1, short checksum9" "$BINARY script-expression --compute-checksum 'pk($PUB_KEY1)'" "pk($PUB_KEY1)#axav5m0j"

run_test "pk --compute-checksum wif, short checksum1" "$BINARY script-expression --compute-checksum 'pk($WIF)#alm7cpq'" "pk($WIF)#alm7cpqh"
run_test "pk --compute-checksum wif, short checksum2" "$BINARY script-expression --compute-checksum 'pk($WIF)#alm7cp'" "pk($WIF)#alm7cpqh"
run_test "pk --compute-checksum wif, short checksum3" "$BINARY script-expression --compute-checksum 'pk($WIF)#alm7c'" "pk($WIF)#alm7cpqh"
run_test "pk --compute-checksum wif, short checksum4" "$BINARY script-expression --compute-checksum 'pk($WIF)#alm7'" "pk($WIF)#alm7cpqh"
run_test "pk --compute-checksum wif, short checksum5" "$BINARY script-expression --compute-checksum 'pk($WIF)#alm'" "pk($WIF)#alm7cpqh"
run_test "pk --compute-checksum wif, short checksum6" "$BINARY script-expression --compute-checksum 'pk($WIF)#al'" "pk($WIF)#alm7cpqh"
run_test "pk --compute-checksum wif, short checksum7" "$BINARY script-expression --compute-checksum 'pk($WIF)#a'" "pk($WIF)#alm7cpqh"
run_test "pk --compute-checksum wif, short checksum8" "$BINARY script-expression --compute-checksum 'pk($WIF)#'" "pk($WIF)#alm7cpqh"
run_test "pk --compute-checksum wif, short checksum9" "$BINARY script-expression --compute-checksum 'pk($WIF)'" "pk($WIF)#alm7cpqh"

run_test "pk --compute-checksum private key1, large checksum" "$BINARY script-expression --compute-checksum 'pk($PRV_KEY1)#dse8d4m1'" "pk($PRV_KEY1)#dse8d4mx"
run_test "pk --compute-checksum public key1, large checksum" "$BINARY script-expression --compute-checksum 'pk($PUB_KEY1)#axav5m01'" "pk($PUB_KEY1)#axav5m0j"
run_test "pk --compute-checksum wif, large checksum" "$BINARY script-expression --compute-checksum 'pk($WIF)#alm7cpq1'" "pk($WIF)#alm7cpqh"

run_test "pk --compute-checksum private key1, large checksum2" "$BINARY script-expression --compute-checksum 'pk($PRV_KEY1)#dse8ds4m1'" "pk($PRV_KEY1)#dse8d4mx"
run_test "pk --compute-checksum public key1, large checksum2" "$BINARY script-expression --compute-checksum 'pk($PUB_KEY1)#axdav5m01'" "pk($PUB_KEY1)#axav5m0j"
run_test "pk --compute-checksum wif, large checksum2" "$BINARY script-expression --compute-checksum 'pk($WIF)#alm7capq1'" "pk($WIF)#alm7cpqh"

run_test "pk --compute-checksum private key1, extra large checksum" "$BINARY script-expression --compute-checksum 'pk($PRV_KEY1)#dse8dsafbidsnjofdibvsundodiifdbuhnoinidfufdsaf4m1'" "pk($PRV_KEY1)#dse8d4mx"
run_test "pk --compute-checksum public key1, extra large checksum" "$BINARY script-expression --compute-checksum 'pk($PUB_KEY1)#axdav5mgwefvurbhinuoimqiewnoubrnomwrguifokpgronuinmf01'" "pk($PUB_KEY1)#axav5m0j"

run_test "pk --compute-checksum private key1, checksum is another script" "$BINARY script-expression --compute-checksum 'pk($PRV_KEY1)#sh(multi(0, xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8))'" "pk($PRV_KEY1)#dse8d4mx"
run_test "pk --compute-checksum public key1, checksum is another script" "$BINARY script-expression --compute-checksum 'pk($PUB_KEY1)#sh(multi(0, xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8))'" "pk($PUB_KEY1)#axav5m0j"
run_test "pk --compute-checksum wif, checksum is another script" "$BINARY script-expression --compute-checksum 'pk($WIF)#sh(multi(0, xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8))'" "pk($WIF)#alm7cpqh"

run_test "pk --compute-checksum private key1, checksum has multiple hashes" "$BINARY script-expression --compute-checksum 'pk($PRV_KEY1)###sh(multi(0, xpub661MyMwAqRbc#gS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8#)#)#))'" "pk($PRV_KEY1)#dse8d4mx"
run_test "pk --compute-checksum public key1, checksum has multiple hashes" "$BINARY script-expression --compute-checksum 'pk($PUB_KEY1)###sh(multi(0, xpub661MyMwAqRbc#gS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8#)#)#))'" "pk($PUB_KEY1)#axav5m0j"
run_test "pk --compute-checksum wif, checksum has multiple hashes" "$BINARY script-expression --compute-checksum 'pk($WIF)###sh(multi(0, xpub661MyMwAqRbc#gS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8#)#)#))'" "pk($WIF)#alm7cpqh"

# --- PKH ---
echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running valid tests for pkhH with no flags ...${NC}"
run_test "pkh private key1" "$BINARY script-expression 'pkh($PRV_KEY1)#axav5m0j'" "pkh($PRV_KEY1)#axav5m0j"
run_test "pkh private key2" "$BINARY script-expression 'pkh($PRV_KEY2)#cga9zxuz'" "pkh($PRV_KEY2)#cga9zxuz"
run_test "pkh private key3" "$BINARY script-expression 'pkh($PRV_KEY3)#lqn0r8mc'" "pkh($PRV_KEY3)#lqn0r8mc"
run_test "pkh public key1" "$BINARY script-expression 'pkh($PUB_KEY1)#dse8d4mx'" "pkh($PUB_KEY1)#dse8d4mx"
run_test "pkh public key2" "$BINARY script-expression 'pkh($PUB_KEY2)#ew5qtxuy'" "pkh($PUB_KEY2)#ew5qtxuy"
run_test "pkh public key3" "$BINARY script-expression 'pkh($PUB_KEY3)#l7e8w7wc'" "pkh($PUB_KEY3)#l7e8w7wc"
run_test "pkh wif" "$BINARY script-expression 'pkh($WIF)#alm7cpqh'" "pkh($WIF)#alm7cpqh"

run_test "pkh private key1, no checksum" "$BINARY script-expression 'pkh($PRV_KEY1)'" "pkh($PRV_KEY1)"
run_test "pkh private key2, no checksum" "$BINARY script-expression 'pkh($PRV_KEY2)'" "pkh($PRV_KEY2)"
run_test "pkh private key3, no checksum" "$BINARY script-expression 'pkh($PRV_KEY3)'" "pkh($PRV_KEY3)"
run_test "pkh public key1, no checksum" "$BINARY script-expression 'pkh($PUB_KEY1)'" "pkh($PUB_KEY1)"
run_test "pkh public key2, no checksum" "$BINARY script-expression 'pkh($PUB_KEY2)'" "pkh($PUB_KEY2)"
run_test "pkh public key3, no checksum" "$BINARY script-expression 'pkh($PUB_KEY3)'" "pkh($PUB_KEY3)"
run_test "pkh wif, no checksum" "$BINARY script-expression 'pkh($WIF)'" "pkh($WIF)"

run_test "pkh private key1, wrong checksum" "$BINARY script-expression 'pkh($PRV_KEY1)#axav5maj'" "pkh($PRV_KEY1)#axav5maj"
run_test "pkh private key2, wrong checksum" "$BINARY script-expression 'pkh($PRV_KEY2)#cga9zxux'" "pkh($PRV_KEY2)#cga9zxux"
run_test "pkh private key3, wrong checksum" "$BINARY script-expression 'pkh($PRV_KEY3)#lqn0r8mx'" "pkh($PRV_KEY3)#lqn0r8mx"
run_test "pkh public key1, wrong checksum" "$BINARY script-expression 'pkh($PUB_KEY1)#dse8d4mc'" "pkh($PUB_KEY1)#dse8d4mc"
run_test "pkh public key2, wrong checksum" "$BINARY script-expression 'pkh($PUB_KEY2)#ew5qtxux'" "pkh($PUB_KEY2)#ew5qtxux"
run_test "pkh public key3, wrong checksum" "$BINARY script-expression 'pkh($PUB_KEY3)#l7e8w7ww'" "pkh($PUB_KEY3)#l7e8w7ww"
run_test "pkh wif, wrong checksum" "$BINARY script-expression 'pkh($WIF)#alm7cpqc'" "pkh($WIF)#alm7cpqc"

run_test "pkh private key1, with space padding" "$BINARY script-expression 'pkh( $PRV_KEY1 )#e3pmfztz'" "pkh( $PRV_KEY1 )#e3pmfztz"
run_test "pkh private key2, with space padding" "$BINARY script-expression 'pkh( $PRV_KEY2 )#85n8tjw6'" "pkh( $PRV_KEY2 )#85n8tjw6"
run_test "pkh private key3, with space padding" "$BINARY script-expression 'pkh( $PRV_KEY3 )#g5dgutdf'" "pkh( $PRV_KEY3 )#g5dgutdf"
run_test "pkh public key1, with space padding" "$BINARY script-expression 'pkh( $PUB_KEY1 )#nhrdq9w4'" "pkh( $PUB_KEY1 )#nhrdq9w4"
run_test "pkh public key2, with space padding" "$BINARY script-expression 'pkh( $PUB_KEY2 )#cn8qmyud'" "pkh( $PUB_KEY2 )#cn8qmyud"
run_test "pkh public key3, with space padding" "$BINARY script-expression 'pkh( $PUB_KEY3 )#qecu2240'" "pkh( $PUB_KEY3 )#qecu2240"
run_test "pkh wif, with space padding" "$BINARY script-expression 'pkh( $WIF )#5lchaun8'" "pkh( $WIF )#5lchaun8"

run_test "pkh private key1, with space padding" "$BINARY script-expression 'pkh( $PRV_KEY1 )#99999999'" "pkh( $PRV_KEY1 )#99999999"
run_test "pkh private key2, with space padding" "$BINARY script-expression 'pkh( $PRV_KEY2 )#99999999'" "pkh( $PRV_KEY2 )#99999999"
run_test "pkh private key3, with space padding" "$BINARY script-expression 'pkh( $PRV_KEY3 )#99999999'" "pkh( $PRV_KEY3 )#99999999"
run_test "pkh public key1, with space padding" "$BINARY script-expression 'pkh( $PUB_KEY1 )#99999999'" "pkh( $PUB_KEY1 )#99999999"
run_test "pkh public key2, with space padding" "$BINARY script-expression 'pkh( $PUB_KEY2 )#99999999'" "pkh( $PUB_KEY2 )#99999999"
run_test "pkh public key3, with space padding" "$BINARY script-expression 'pkh( $PUB_KEY3 )#99999999'" "pkh( $PUB_KEY3 )#99999999"
run_test "pkh wif, with space padding" "$BINARY script-expression 'pkh( $WIF )#99999999'" "pkh( $WIF )#99999999"

echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running valid tests for PKH --verify-checksum ...${NC}"
run_test "pkh --verify-checksum private key1" "$BINARY script-expression --verify-checksum 'pkh($PRV_KEY1)#ga2lpt74'" "OK"
run_test "pkh --verify-checksum private key2" "$BINARY script-expression --verify-checksum 'pkh($PRV_KEY2)#uns2haux'" "OK"
run_test "pkh --verify-checksum private key3" "$BINARY script-expression --verify-checksum 'pkh($PRV_KEY3)#gpn2whf2'" "OK"
run_test "pkh --verify-checksum public key1" "$BINARY script-expression --verify-checksum 'pkh($PUB_KEY1)#vm4xc4ed'" "OK"
run_test "pkh --verify-checksum public key2" "$BINARY script-expression --verify-checksum 'pkh($PUB_KEY2)#6slhps7j'" "OK"
run_test "pkh --verify-checksum public key3" "$BINARY script-expression --verify-checksum 'pkh($PUB_KEY3)#n859t0cx'" "OK"
run_test "pkh --verify-checksum wif" "$BINARY script-expression --verify-checksum 'pkh($WIF)#k6nt90mn'" "OK"

echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running valid tests for PKH --compute-checksum ...${NC}"
run_test "pkh --compute-checksum private key1" "$BINARY script-expression --compute-checksum 'pkh($PRV_KEY1)#ga2lpt74'" "pkh($PRV_KEY1)#ga2lpt74"
run_test "pkh --compute-checksum private key2" "$BINARY script-expression --compute-checksum 'pkh($PRV_KEY2)#uns2haux'" "pkh($PRV_KEY2)#uns2haux"
run_test "pkh --compute-checksum private key3" "$BINARY script-expression --compute-checksum 'pkh($PRV_KEY3)#gpn2whf2'" "pkh($PRV_KEY3)#gpn2whf2"
run_test "pkh --compute-checksum public key1" "$BINARY script-expression --compute-checksum 'pkh($PUB_KEY1)#vm4xc4ed'" "pkh($PUB_KEY1)#vm4xc4ed"
run_test "pkh --compute-checksum public key2" "$BINARY script-expression --compute-checksum 'pkh($PUB_KEY2)#6slhps7j'" "pkh($PUB_KEY2)#6slhps7j"
run_test "pkh --compute-checksum public key3" "$BINARY script-expression --compute-checksum 'pkh($PUB_KEY3)#n859t0cx'" "pkh($PUB_KEY3)#n859t0cx"
run_test "pkh --compute-checksum wif" "$BINARY script-expression --compute-checksum 'pkh($WIF)#k6nt90mn'" "pkh($WIF)#k6nt90mn"

run_test "pkh --compute-checksum private key1, with space padding" "$BINARY script-expression 'pkh( $PRV_KEY1 )#e3pmfztz'" "pkh( $PRV_KEY1 )#e3pmfztz"
run_test "pkh --compute-checksum private key2, with space padding" "$BINARY script-expression 'pkh( $PRV_KEY2 )#85n8tjw6'" "pkh( $PRV_KEY2 )#85n8tjw6"
run_test "pkh --compute-checksum private key3, with space padding" "$BINARY script-expression 'pkh( $PRV_KEY3 )#g5dgutdf'" "pkh( $PRV_KEY3 )#g5dgutdf"
run_test "pkh --compute-checksum public key1, with space padding" "$BINARY script-expression 'pkh( $PUB_KEY1 )#nhrdq9w4'" "pkh( $PUB_KEY1 )#nhrdq9w4"
run_test "pkh --compute-checksum public key2, with space padding" "$BINARY script-expression 'pkh( $PUB_KEY2 )#cn8qmyud'" "pkh( $PUB_KEY2 )#cn8qmyud"
run_test "pkh --compute-checksum public key3, with space padding" "$BINARY script-expression 'pkh( $PUB_KEY3 )#qecu2240'" "pkh( $PUB_KEY3 )#qecu2240"
run_test "pkh --compute-checksum wif, with space padding" "$BINARY script-expression 'pkh( $WIF )#5lchaun8'" "pkh( $WIF )#5lchaun8"

run_test "pkh --compute-checksum private key1, short checksum1" "$BINARY script-expression --compute-checksum 'pkh($PRV_KEY1)#dse8d4m'" "pkh($PRV_KEY1)#ga2lpt74"
run_test "pkh --compute-checksum private key1, short checksum2" "$BINARY script-expression --compute-checksum 'pkh($PRV_KEY1)#dse8d4'" "pkh($PRV_KEY1)#ga2lpt74"
run_test "pkh --compute-checksum private key1, short checksum3" "$BINARY script-expression --compute-checksum 'pkh($PRV_KEY1)#dse8d'" "pkh($PRV_KEY1)#ga2lpt74"
run_test "pkh --compute-checksum private key1, short checksum4" "$BINARY script-expression --compute-checksum 'pkh($PRV_KEY1)#dse8'" "pkh($PRV_KEY1)#ga2lpt74"
run_test "pkh --compute-checksum private key1, short checksum5" "$BINARY script-expression --compute-checksum 'pkh($PRV_KEY1)#dse'" "pkh($PRV_KEY1)#ga2lpt74"
run_test "pkh --compute-checksum private key1, short checksum6" "$BINARY script-expression --compute-checksum 'pkh($PRV_KEY1)#ds'" "pkh($PRV_KEY1)#ga2lpt74"
run_test "pkh --compute-checksum private key1, short checksum7" "$BINARY script-expression --compute-checksum 'pkh($PRV_KEY1)#d'" "pkh($PRV_KEY1)#ga2lpt74"
run_test "pkh --compute-checksum private key1, short checksum8" "$BINARY script-expression --compute-checksum 'pkh($PRV_KEY1)#'" "pkh($PRV_KEY1)#ga2lpt74"
run_test "pkh --compute-checksum private key1, short checksum9" "$BINARY script-expression --compute-checksum 'pkh($PRV_KEY1)'" "pkh($PRV_KEY1)#ga2lpt74"

run_test "pkh --compute-checksum public key1, short checksum1" "$BINARY script-expression --compute-checksum 'pkh($PUB_KEY1)#axav5m0'" "pkh($PUB_KEY1)#vm4xc4ed"
run_test "pkh --compute-checksum public key1, short checksum2" "$BINARY script-expression --compute-checksum 'pkh($PUB_KEY1)#axav5m'" "pkh($PUB_KEY1)#vm4xc4ed"
run_test "pkh --compute-checksum public key1, short checksum3" "$BINARY script-expression --compute-checksum 'pkh($PUB_KEY1)#axav5'" "pkh($PUB_KEY1)#vm4xc4ed"
run_test "pkh --compute-checksum public key1, short checksum4" "$BINARY script-expression --compute-checksum 'pkh($PUB_KEY1)#axav'" "pkh($PUB_KEY1)#vm4xc4ed"
run_test "pkh --compute-checksum public key1, short checksum5" "$BINARY script-expression --compute-checksum 'pkh($PUB_KEY1)#axa'" "pkh($PUB_KEY1)#vm4xc4ed"
run_test "pkh --compute-checksum public key1, short checksum6" "$BINARY script-expression --compute-checksum 'pkh($PUB_KEY1)#ax'" "pkh($PUB_KEY1)#vm4xc4ed"
run_test "pkh --compute-checksum public key1, short checksum7" "$BINARY script-expression --compute-checksum 'pkh($PUB_KEY1)#a'" "pkh($PUB_KEY1)#vm4xc4ed"
run_test "pkh --compute-checksum public key1, short checksum8" "$BINARY script-expression --compute-checksum 'pkh($PUB_KEY1)#'" "pkh($PUB_KEY1)#vm4xc4ed"
run_test "pkh --compute-checksum public key1, short checksum9" "$BINARY script-expression --compute-checksum 'pkh($PUB_KEY1)'" "pkh($PUB_KEY1)#vm4xc4ed"

run_test "pkh --compute-checksum wif, short checksum1" "$BINARY script-expression --compute-checksum 'pkh($WIF)#alm7cpq'" "pkh($WIF)#k6nt90mn"
run_test "pkh --compute-checksum wif, short checksum2" "$BINARY script-expression --compute-checksum 'pkh($WIF)#alm7cp'" "pkh($WIF)#k6nt90mn"
run_test "pkh --compute-checksum wif, short checksum3" "$BINARY script-expression --compute-checksum 'pkh($WIF)#alm7c'" "pkh($WIF)#k6nt90mn"
run_test "pkh --compute-checksum wif, short checksum4" "$BINARY script-expression --compute-checksum 'pkh($WIF)#alm7'" "pkh($WIF)#k6nt90mn"
run_test "pkh --compute-checksum wif, short checksum5" "$BINARY script-expression --compute-checksum 'pkh($WIF)#alm'" "pkh($WIF)#k6nt90mn"
run_test "pkh --compute-checksum wif, short checksum6" "$BINARY script-expression --compute-checksum 'pkh($WIF)#al'" "pkh($WIF)#k6nt90mn"
run_test "pkh --compute-checksum wif, short checksum7" "$BINARY script-expression --compute-checksum 'pkh($WIF)#a'" "pkh($WIF)#k6nt90mn"
run_test "pkh --compute-checksum wif, short checksum8" "$BINARY script-expression --compute-checksum 'pkh($WIF)#'" "pkh($WIF)#k6nt90mn"
run_test "pkh --compute-checksum wif, short checksum9" "$BINARY script-expression --compute-checksum 'pkh($WIF)'" "pkh($WIF)#k6nt90mn"

run_test "pkh --compute-checksum private key1, large checksum" "$BINARY script-expression --compute-checksum 'pkh($PRV_KEY1)#dse8d4m1s'" "pkh($PRV_KEY1)#ga2lpt74"
run_test "pkh --compute-checksum public key1, large checksum" "$BINARY script-expression --compute-checksum 'pkh($PUB_KEY1)#axav5m01'" "pkh($PUB_KEY1)#vm4xc4ed"
run_test "pkh --compute-checksum wif, large checksum" "$BINARY script-expression --compute-checksum 'pkh($WIF)#alm7cpq1'" "pkh($WIF)#k6nt90mn"

run_test "pkh --compute-checksum private key1, large checksum2" "$BINARY script-expression --compute-checksum 'pkh($PRV_KEY1)#dse8ds4m1'" "pkh($PRV_KEY1)#ga2lpt74"
run_test "pkh --compute-checksum public key1, large checksum2" "$BINARY script-expression --compute-checksum 'pkh($PUB_KEY1)#axdav5m01'" "pkh($PUB_KEY1)#vm4xc4ed"
run_test "pkh --compute-checksum wif, large checksum2" "$BINARY script-expression --compute-checksum 'pkh($WIF)#alm7capq1'" "pkh($WIF)#k6nt90mn"

run_test "pkh --compute-checksum private key1, extra large checksum" "$BINARY script-expression --compute-checksum 'pkh($PRV_KEY1)#dse8dsafbidsnjofdibvsundodiifdbuhnoinidfufdsaf4m1'" "pkh($PRV_KEY1)#ga2lpt74"
run_test "pkh --compute-checksum public key1, extra large checksum" "$BINARY script-expression --compute-checksum 'pkh($PUB_KEY1)#axdav5mgwefvurbhinuoimqiewnoubrnomwrguifokpgronuinmf01'" "pkh($PUB_KEY1)#vm4xc4ed"

run_test "pkh --compute-checksum private key1, checksum is another script" "$BINARY script-expression --compute-checksum 'pkh($PRV_KEY1)#sh(multi(0, xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8))'" "pkh($PRV_KEY1)#ga2lpt74"
run_test "pkh --compute-checksum public key1, checksum is another script" "$BINARY script-expression --compute-checksum 'pkh($PUB_KEY1)#sh(multi(0, xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8))'" "pkh($PUB_KEY1)#vm4xc4ed"
run_test "pkh --compute-checksum wif, checksum is another script" "$BINARY script-expression --compute-checksum 'pkh($WIF)#sh(multi(0, xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8))'" "pkh($WIF)#k6nt90mn"

run_test "pkh --compute-checksum private key1, checksum has multiple hashes" "$BINARY script-expression --compute-checksum 'pkh($PRV_KEY1)###sh(multi(0, xpub661MyMwAqRbc#gS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8#)#)#))'" "pkh($PRV_KEY1)#ga2lpt74"
run_test "pkh --compute-checksum public key1, checksum has multiple hashes" "$BINARY script-expression --compute-checksum 'pkh($PUB_KEY1)###sh(multi(0, xpub661MyMwAqRbc#gS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8#)#)#))'" "pkh($PUB_KEY1)#vm4xc4ed"
run_test "pkh --compute-checksum wif, checksum has multiple hashes" "$BINARY script-expression --compute-checksum 'pkh($WIF)###sh(multi(0, xpub661MyMwAqRbc#gS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8#)#)#))'" "pkh($WIF)#k6nt90mn"

# --- MULTI ---
echo -e "\n\n${GREEN}✔ [SCRIPT-EXPRESSION] Running valid tests for MULTI with no flags ...${NC}"
run_test "Basic multi" "$BINARY script-expression 'multi(1, $PUB_KEY1)'" "multi(1, $PUB_KEY1)"
run_test "Basic multi with multiple public keys" "$BINARY script-expression 'multi(3, $PUB_KEY1, $PUB_KEY2, $PUB_KEY3)'" "multi(3, $PUB_KEY1, $PUB_KEY2, $PUB_KEY3)"
run_test "Basic multi with multiple private keys" "$BINARY script-expression 'multi(3, $PRV_KEY1, $PRV_KEY2, $PRV_KEY3)'" "multi(3, $PRV_KEY1, $PRV_KEY2, $PRV_KEY3)"

run_test "Basic multi with multiple public keys - small k" "$BINARY script-expression 'multi(2, $PUB_KEY1, $PUB_KEY2, $PUB_KEY3)'" "multi(2, $PUB_KEY1, $PUB_KEY2, $PUB_KEY3)"
run_test "Basic multi with multiple private keys large k" "$BINARY script-expression 'multi(1, $PRV_KEY1, $PRV_KEY2, $PRV_KEY3)'" "multi(1, $PRV_KEY1, $PRV_KEY2, $PRV_KEY3)"

run_test "multi largest input" "$BINARY script-expression 'multi(20, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1)#qwscasdr'" "multi(20, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1, $PUB_KEY1)#qwscasdr"


run_test "multi private key1, no checksum" "$BINARY script-expression 'multi(1, $PRV_KEY1)'" "multi(1, $PRV_KEY1)"
run_test "multi private key2, no checksum" "$BINARY script-expression 'multi(1, $PRV_KEY2)'" "multi(1, $PRV_KEY2)"
run_test "multi private key3, no checksum" "$BINARY script-expression 'multi(1, $PRV_KEY3)'" "multi(1, $PRV_KEY3)"
run_test "multi public key1, no checksum" "$BINARY script-expression 'multi(1, $PUB_KEY1)'" "multi(1, $PUB_KEY1)"
run_test "multi public key2, no checksum" "$BINARY script-expression 'multi(1, $PUB_KEY2)'" "multi(1, $PUB_KEY2)"
run_test "multi public key3, no checksum" "$BINARY script-expression 'multi(1, $PUB_KEY3)'" "multi(1, $PUB_KEY3)"

run_test "multi private key1, wrong checksum" "$BINARY script-expression 'multi(1, $PRV_KEY1)#axav5maj'" "multi(1, $PRV_KEY1)#axav5maj"
run_test "multi private key2, wrong checksum" "$BINARY script-expression 'multi(1, $PRV_KEY2)#cga9zxux'" "multi(1, $PRV_KEY2)#cga9zxux"
run_test "multi private key3, wrong checksum" "$BINARY script-expression 'multi(1, $PRV_KEY3)#lqn0r8mx'" "multi(1, $PRV_KEY3)#lqn0r8mx"
run_test "multi public key1, wrong checksum" "$BINARY script-expression 'multi(1, $PUB_KEY1)#dse8d4mc'" "multi(1, $PUB_KEY1)#dse8d4mc"
run_test "multi public key2, wrong checksum" "$BINARY script-expression 'multi(1, $PUB_KEY2)#ew5qtxux'" "multi(1, $PUB_KEY2)#ew5qtxux"
run_test "multi public key3, wrong checksum" "$BINARY script-expression 'multi(1, $PUB_KEY3)#l7e8w7ww'" "multi(1, $PUB_KEY3)#l7e8w7ww"

run_test "multi private key1, with space padding" "$BINARY script-expression 'multi(1,  $PRV_KEY1 )#e3pmfztz'" "multi(1,  $PRV_KEY1 )#e3pmfztz"
run_test "multi private key2, with space padding" "$BINARY script-expression 'multi(1,  $PRV_KEY2 )#85n8tjw6'" "multi(1,  $PRV_KEY2 )#85n8tjw6"
run_test "multi private key3, with space padding" "$BINARY script-expression 'multi(1,  $PRV_KEY3 )#g5dgutdf'" "multi(1,  $PRV_KEY3 )#g5dgutdf"
run_test "multi public key1, with space padding" "$BINARY script-expression 'multi(1,  $PUB_KEY1 )#nhrdq9w4'" "multi(1,  $PUB_KEY1 )#nhrdq9w4"
run_test "multi public key2, with space padding" "$BINARY script-expression 'multi(1,  $PUB_KEY2 )#cn8qmyud'" "multi(1,  $PUB_KEY2 )#cn8qmyud"
run_test "multi public key3, with space padding" "$BINARY script-expression 'multi(1,  $PUB_KEY3 )#qecu2240'" "multi(1,  $PUB_KEY3 )#qecu2240"

run_test "multi private key1, with space padding" "$BINARY script-expression 'multi(1,  $PRV_KEY1 )#99999999'" "multi(1,  $PRV_KEY1 )#99999999"
run_test "multi private key2, with space padding" "$BINARY script-expression 'multi(1,  $PRV_KEY2 )#99999999'" "multi(1,  $PRV_KEY2 )#99999999"
run_test "multi private key3, with space padding" "$BINARY script-expression 'multi(1,  $PRV_KEY3 )#99999999'" "multi(1,  $PRV_KEY3 )#99999999"
run_test "multi public key1, with space padding" "$BINARY script-expression 'multi(1,  $PUB_KEY1 )#99999999'" "multi(1,  $PUB_KEY1 )#99999999"
run_test "multi public key2, with space padding" "$BINARY script-expression 'multi(1,  $PUB_KEY2 )#99999999'" "multi(1,  $PUB_KEY2 )#99999999"
run_test "multi public key3, with space padding" "$BINARY script-expression 'multi(1,  $PUB_KEY3 )#99999999'" "multi(1,  $PUB_KEY3 )#99999999"

echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running valid tests for multi --verify-checksum ...${NC}"
run_test "multi --verify-checksum private key1" "$BINARY script-expression --verify-checksum 'multi(1, $PRV_KEY1)#s3snd3vc'" "OK"
run_test "multi --verify-checksum private key2" "$BINARY script-expression --verify-checksum 'multi(1, $PRV_KEY2)#y0a5tzt6'" "OK"
run_test "multi --verify-checksum private key3" "$BINARY script-expression --verify-checksum 'multi(1, $PRV_KEY3)#zlsnw6ex'" "OK"
run_test "multi --verify-checksum public key1" "$BINARY script-expression --verify-checksum 'multi(1, $PUB_KEY1)#q85c5lcv'" "OK"
run_test "multi --verify-checksum public key2" "$BINARY script-expression --verify-checksum 'multi(1, $PUB_KEY2)#9f53zztu'" "OK"
run_test "multi --verify-checksum public key3" "$BINARY script-expression --verify-checksum 'multi(1, $PUB_KEY3)#zp6mrrvx'" "OK"

echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running valid tests for multi --compute-checksum ...${NC}"
run_test "multi --compute-checksum private key1" "$BINARY script-expression --compute-checksum 'multi(1, $PRV_KEY1)#ga2lpt74'" "multi(1, $PRV_KEY1)#s3snd3vc"
run_test "multi --compute-checksum private key2" "$BINARY script-expression --compute-checksum 'multi(1, $PRV_KEY2)#y0a5tzt6'" "multi(1, $PRV_KEY2)#y0a5tzt6"
run_test "multi --compute-checksum private key3" "$BINARY script-expression --compute-checksum 'multi(1, $PRV_KEY3)#zlsnw6ex'" "multi(1, $PRV_KEY3)#zlsnw6ex"
run_test "multi --compute-checksum public key1" "$BINARY script-expression --compute-checksum 'multi(1, $PUB_KEY1)#q85c5lcv'" "multi(1, $PUB_KEY1)#q85c5lcv"
run_test "multi --compute-checksum public key2" "$BINARY script-expression --compute-checksum 'multi(1, $PUB_KEY2)#9f53zztu'" "multi(1, $PUB_KEY2)#9f53zztu"
run_test "multi --compute-checksum public key3" "$BINARY script-expression --compute-checksum 'multi(1, $PUB_KEY3)#zp6mrrvx'" "multi(1, $PUB_KEY3)#zp6mrrvx"

run_test "multi --compute-checksum private key1, with space padding" "$BINARY script-expression 'multi(1,  $PRV_KEY1 )#s3snd3vc'" "multi(1,  $PRV_KEY1 )#s3snd3vc"
run_test "multi --compute-checksum private key2, with space padding" "$BINARY script-expression 'multi(1,  $PRV_KEY2 )#85n8tjw6'" "multi(1,  $PRV_KEY2 )#85n8tjw6"
run_test "multi --compute-checksum private key3, with space padding" "$BINARY script-expression 'multi(1,  $PRV_KEY3 )#g5dgutdf'" "multi(1,  $PRV_KEY3 )#g5dgutdf"
run_test "multi --compute-checksum public key1, with space padding" "$BINARY script-expression 'multi(1,  $PUB_KEY1 )#q85c5lcv'" "multi(1,  $PUB_KEY1 )#q85c5lcv"
run_test "multi --compute-checksum public key2, with space padding" "$BINARY script-expression 'multi(1,  $PUB_KEY2 )#9f53zztu'" "multi(1,  $PUB_KEY2 )#9f53zztu"
run_test "multi --compute-checksum public key3, with space padding" "$BINARY script-expression 'multi(1,  $PUB_KEY3 )#zp6mrrvx'" "multi(1,  $PUB_KEY3 )#zp6mrrvx"

run_test "multi --compute-checksum private key1, short checksum1" "$BINARY script-expression --compute-checksum 'multi(1, $PRV_KEY1)#dse8d4m'" "multi(1, $PRV_KEY1)#s3snd3vc"
run_test "multi --compute-checksum private key1, short checksum2" "$BINARY script-expression --compute-checksum 'multi(1, $PRV_KEY1)#dse8d4'" "multi(1, $PRV_KEY1)#s3snd3vc"
run_test "multi --compute-checksum private key1, short checksum3" "$BINARY script-expression --compute-checksum 'multi(1, $PRV_KEY1)#dse8d'" "multi(1, $PRV_KEY1)#s3snd3vc"
run_test "multi --compute-checksum private key1, short checksum4" "$BINARY script-expression --compute-checksum 'multi(1, $PRV_KEY1)#dse8'" "multi(1, $PRV_KEY1)#s3snd3vc"
run_test "multi --compute-checksum private key1, short checksum5" "$BINARY script-expression --compute-checksum 'multi(1, $PRV_KEY1)#dse'" "multi(1, $PRV_KEY1)#s3snd3vc"
run_test "multi --compute-checksum private key1, short checksum6" "$BINARY script-expression --compute-checksum 'multi(1, $PRV_KEY1)#ds'" "multi(1, $PRV_KEY1)#s3snd3vc"
run_test "multi --compute-checksum private key1, short checksum7" "$BINARY script-expression --compute-checksum 'multi(1, $PRV_KEY1)#d'" "multi(1, $PRV_KEY1)#s3snd3vc"
run_test "multi --compute-checksum private key1, short checksum8" "$BINARY script-expression --compute-checksum 'multi(1, $PRV_KEY1)#'" "multi(1, $PRV_KEY1)#s3snd3vc"
run_test "multi --compute-checksum private key1, short checksum9" "$BINARY script-expression --compute-checksum 'multi(1, $PRV_KEY1)'" "multi(1, $PRV_KEY1)#s3snd3vc"

run_test "multi --compute-checksum public key1, short checksum1" "$BINARY script-expression --compute-checksum 'multi(1, $PUB_KEY1)#axav5m0'" "multi(1, $PUB_KEY1)#q85c5lcv"
run_test "multi --compute-checksum public key1, short checksum2" "$BINARY script-expression --compute-checksum 'multi(1, $PUB_KEY1)#axav5m'" "multi(1, $PUB_KEY1)#q85c5lcv"
run_test "multi --compute-checksum public key1, short checksum3" "$BINARY script-expression --compute-checksum 'multi(1, $PUB_KEY1)#axav5'" "multi(1, $PUB_KEY1)#q85c5lcv"
run_test "multi --compute-checksum public key1, short checksum4" "$BINARY script-expression --compute-checksum 'multi(1, $PUB_KEY1)#axav'" "multi(1, $PUB_KEY1)#q85c5lcv"
run_test "multi --compute-checksum public key1, short checksum5" "$BINARY script-expression --compute-checksum 'multi(1, $PUB_KEY1)#axa'" "multi(1, $PUB_KEY1)#q85c5lcv"
run_test "multi --compute-checksum public key1, short checksum6" "$BINARY script-expression --compute-checksum 'multi(1, $PUB_KEY1)#ax'" "multi(1, $PUB_KEY1)#q85c5lcv"
run_test "multi --compute-checksum public key1, short checksum7" "$BINARY script-expression --compute-checksum 'multi(1, $PUB_KEY1)#a'" "multi(1, $PUB_KEY1)#q85c5lcv"
run_test "multi --compute-checksum public key1, short checksum8" "$BINARY script-expression --compute-checksum 'multi(1, $PUB_KEY1)#'" "multi(1, $PUB_KEY1)#q85c5lcv"
run_test "multi --compute-checksum public key1, short checksum9" "$BINARY script-expression --compute-checksum 'multi(1, $PUB_KEY1)'" "multi(1, $PUB_KEY1)#q85c5lcv"

run_test "multi --compute-checksum private key1, large checksum" "$BINARY script-expression --compute-checksum 'multi(1, $PRV_KEY1)#s3snd3vc'" "multi(1, $PRV_KEY1)#s3snd3vc"
run_test "multi --compute-checksum public key1, large checksum" "$BINARY script-expression --compute-checksum 'multi(1, $PUB_KEY1)#axav5m01'" "multi(1, $PUB_KEY1)#q85c5lcv"

run_test "multi --compute-checksum private key1, large checksum2" "$BINARY script-expression --compute-checksum 'multi(1, $PRV_KEY1)#dse8ds4m1'" "multi(1, $PRV_KEY1)#s3snd3vc"
run_test "multi --compute-checksum public key1, large checksum2" "$BINARY script-expression --compute-checksum 'multi(1, $PUB_KEY1)#axdav5m01'" "multi(1, $PUB_KEY1)#q85c5lcv"

run_test "multi --compute-checksum private key1, extra large checksum" "$BINARY script-expression --compute-checksum 'multi(1, $PRV_KEY1)#dse8dsafbidsnjofdibvsundodiifdbuhnoinidfufdsaf4m1'" "multi(1, $PRV_KEY1)#s3snd3vc"
run_test "multi --compute-checksum public key1, extra large checksum" "$BINARY script-expression --compute-checksum 'multi(1, $PUB_KEY1)#axdav5mgwefvurbhinuoimqiewnoubrnomwrguifokpgronuinmf01'" "multi(1, $PUB_KEY1)#q85c5lcv"


# --- SH PK ---
echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running valid tests for SH PK with no flags ...${NC}"
run_test "sh pk private key1" "$BINARY script-expression 'sh(pk($PRV_KEY1))#axav5m0j'" "sh(pk($PRV_KEY1))#axav5m0j"
run_test "sh pk private key2" "$BINARY script-expression 'sh(pk($PRV_KEY2))#cga9zxuz'" "sh(pk($PRV_KEY2))#cga9zxuz"
run_test "sh pk private key3" "$BINARY script-expression 'sh(pk($PRV_KEY3))#lqn0r8mc'" "sh(pk($PRV_KEY3))#lqn0r8mc"
run_test "sh pk public key1" "$BINARY script-expression 'sh(pk($PUB_KEY1))#dse8d4mx'" "sh(pk($PUB_KEY1))#dse8d4mx"
run_test "sh pk public key2" "$BINARY script-expression 'sh(pk($PUB_KEY2))#ew5qtxuy'" "sh(pk($PUB_KEY2))#ew5qtxuy"
run_test "sh pk public key3" "$BINARY script-expression 'sh(pk($PUB_KEY3))#l7e8w7wc'" "sh(pk($PUB_KEY3))#l7e8w7wc"
run_test "sh pk wif" "$BINARY script-expression 'sh(pk($WIF))#alm7cpqh'" "sh(pk($WIF))#alm7cpqh"

run_test "sh pk private key1, no checksum" "$BINARY script-expression 'sh(pk($PRV_KEY1))'" "sh(pk($PRV_KEY1))"
run_test "sh pk private key2, no checksum" "$BINARY script-expression 'sh(pk($PRV_KEY2))'" "sh(pk($PRV_KEY2))"
run_test "sh pk private key3, no checksum" "$BINARY script-expression 'sh(pk($PRV_KEY3))'" "sh(pk($PRV_KEY3))"
run_test "sh pk public key1, no checksum" "$BINARY script-expression 'sh(pk($PUB_KEY1))'" "sh(pk($PUB_KEY1))"
run_test "sh pk public key2, no checksum" "$BINARY script-expression 'sh(pk($PUB_KEY2))'" "sh(pk($PUB_KEY2))"
run_test "sh pk public key3, no checksum" "$BINARY script-expression 'sh(pk($PUB_KEY3))'" "sh(pk($PUB_KEY3))"
run_test "sh pk wif, no checksum" "$BINARY script-expression 'sh(pk($WIF))'" "sh(pk($WIF))"

run_test "sh pk private key1, wrong checksum" "$BINARY script-expression 'sh(pk($PRV_KEY1))#axav5maj'" "sh(pk($PRV_KEY1))#axav5maj"
run_test "sh pk private key2, wrong checksum" "$BINARY script-expression 'sh(pk($PRV_KEY2))#cga9zxux'" "sh(pk($PRV_KEY2))#cga9zxux"
run_test "sh pk private key3, wrong checksum" "$BINARY script-expression 'sh(pk($PRV_KEY3))#lqn0r8mx'" "sh(pk($PRV_KEY3))#lqn0r8mx"
run_test "sh pk public key1, wrong checksum" "$BINARY script-expression 'sh(pk($PUB_KEY1))#dse8d4mc'" "sh(pk($PUB_KEY1))#dse8d4mc"
run_test "sh pk public key2, wrong checksum" "$BINARY script-expression 'sh(pk($PUB_KEY2))#ew5qtxux'" "sh(pk($PUB_KEY2))#ew5qtxux"
run_test "sh pk public key3, wrong checksum" "$BINARY script-expression 'sh(pk($PUB_KEY3))#l7e8w7ww'" "sh(pk($PUB_KEY3))#l7e8w7ww"
run_test "sh pk wif, wrong checksum" "$BINARY script-expression 'sh(pk($WIF))#alm7cpqc'" "sh(pk($WIF))#alm7cpqc"

run_test "sh pk private key1, with space padding" "$BINARY script-expression 'sh(pk( $PRV_KEY1 ))#e3pmfztz'" "sh(pk( $PRV_KEY1 ))#e3pmfztz"
run_test "sh pk private key2, with space padding" "$BINARY script-expression 'sh(pk( $PRV_KEY2 ))#85n8tjw6'" "sh(pk( $PRV_KEY2 ))#85n8tjw6"
run_test "sh pk private key3, with space padding" "$BINARY script-expression 'sh(pk( $PRV_KEY3 ))#g5dgutdf'" "sh(pk( $PRV_KEY3 ))#g5dgutdf"
run_test "sh pk public key1, with space padding" "$BINARY script-expression 'sh(pk( $PUB_KEY1 ))#nhrdq9w4'" "sh(pk( $PUB_KEY1 ))#nhrdq9w4"
run_test "sh pk public key2, with space padding" "$BINARY script-expression 'sh(pk( $PUB_KEY2 ))#cn8qmyud'" "sh(pk( $PUB_KEY2 ))#cn8qmyud"
run_test "sh pk public key3, with space padding" "$BINARY script-expression 'sh(pk( $PUB_KEY3 ))#qecu2240'" "sh(pk( $PUB_KEY3 ))#qecu2240"
run_test "sh pk wif, with space padding" "$BINARY script-expression 'sh(pk( $WIF ))#5lchaun8'" "sh(pk( $WIF ))#5lchaun8"

run_test "sh pk private key1, with space padding" "$BINARY script-expression 'sh(pk( $PRV_KEY1 ))#99999999'" "sh(pk( $PRV_KEY1 ))#99999999"
run_test "sh pk private key2, with space padding" "$BINARY script-expression 'sh(pk( $PRV_KEY2 ))#99999999'" "sh(pk( $PRV_KEY2 ))#99999999"
run_test "sh pk private key3, with space padding" "$BINARY script-expression 'sh(pk( $PRV_KEY3 ))#99999999'" "sh(pk( $PRV_KEY3 ))#99999999"
run_test "sh pk public key1, with space padding" "$BINARY script-expression 'sh(pk( $PUB_KEY1 ))#99999999'" "sh(pk( $PUB_KEY1 ))#99999999"
run_test "sh pk public key2, with space padding" "$BINARY script-expression 'sh(pk( $PUB_KEY2 ))#99999999'" "sh(pk( $PUB_KEY2 ))#99999999"
run_test "sh pk public key3, with space padding" "$BINARY script-expression 'sh(pk( $PUB_KEY3 ))#99999999'" "sh(pk( $PUB_KEY3 ))#99999999"
run_test "sh pk wif, with space padding" "$BINARY script-expression 'sh(pk( $WIF ))#99999999'" "sh(pk( $WIF ))#99999999"

echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running valid tests for PK --verify-checksum ...${NC}"
run_test "sh pk --verify-checksum private key1" "$BINARY script-expression --verify-checksum 'sh(pk($PRV_KEY1))#62px7n5g'" "OK"
run_test "sh pk --verify-checksum private key2" "$BINARY script-expression --verify-checksum 'sh(pk($PRV_KEY2))#tc48ghsc'" "OK"
run_test "sh pk --verify-checksum private key3" "$BINARY script-expression --verify-checksum 'sh(pk($PRV_KEY3))#due093d8'" "OK"
run_test "sh pk --verify-checksum public key1" "$BINARY script-expression --verify-checksum 'sh(pk($PUB_KEY1))#qlvf5ul4'" "OK"
run_test "sh pk --verify-checksum public key2" "$BINARY script-expression --verify-checksum 'sh(pk($PUB_KEY2))#nxlqz363'" "OK"
run_test "sh pk --verify-checksum public key3" "$BINARY script-expression --verify-checksum 'sh(pk($PUB_KEY3))#nk3zuyd8'" "OK"
run_test "sh pk --verify-checksum wif" "$BINARY script-expression --verify-checksum 'sh(pk($WIF))#90g9xgnn'" "OK"

echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running valid tests for PK --compute-checksum ...${NC}"
run_test "sh pk --compute-checksum private key1" "$BINARY script-expression --compute-checksum 'sh(pk($PRV_KEY1))#dse8d4mx'" "sh(pk($PRV_KEY1))#62px7n5g"
run_test "sh pk --compute-checksum private key2" "$BINARY script-expression --compute-checksum 'sh(pk($PRV_KEY2))#ew5qtxuy'" "sh(pk($PRV_KEY2))#tc48ghsc"
run_test "sh pk --compute-checksum private key3" "$BINARY script-expression --compute-checksum 'sh(pk($PRV_KEY3))#l7e8w7wc'" "sh(pk($PRV_KEY3))#due093d8"
run_test "sh pk --compute-checksum public key1" "$BINARY script-expression --compute-checksum 'sh(pk($PUB_KEY1))#axav5m0j'" "sh(pk($PUB_KEY1))#qlvf5ul4"
run_test "sh pk --compute-checksum public key2" "$BINARY script-expression --compute-checksum 'sh(pk($PUB_KEY2))#cga9zxuz'" "sh(pk($PUB_KEY2))#nxlqz363"
run_test "sh pk --compute-checksum public key3" "$BINARY script-expression --compute-checksum 'sh(pk($PUB_KEY3))#lqn0r8mc'" "sh(pk($PUB_KEY3))#nk3zuyd8"
run_test "sh pk --compute-checksum wif" "$BINARY script-expression --compute-checksum 'sh(pk($WIF))#alm7cpqh'" "sh(pk($WIF))#90g9xgnn"

run_test "sh pk --compute-checksum private key1, with space padding" "$BINARY script-expression 'sh(pk( $PRV_KEY1 ))#e3pmfztz'" "sh(pk( $PRV_KEY1 ))#e3pmfztz"
run_test "sh pk --compute-checksum private key2, with space padding" "$BINARY script-expression 'sh(pk( $PRV_KEY2 ))#85n8tjw6'" "sh(pk( $PRV_KEY2 ))#85n8tjw6"
run_test "sh pk --compute-checksum private key3, with space padding" "$BINARY script-expression 'sh(pk( $PRV_KEY3 ))#g5dgutdf'" "sh(pk( $PRV_KEY3 ))#g5dgutdf"
run_test "sh pk --compute-checksum public key1, with space padding" "$BINARY script-expression 'sh(pk( $PUB_KEY1 ))#nhrdq9w4'" "sh(pk( $PUB_KEY1 ))#nhrdq9w4"
run_test "sh pk --compute-checksum public key2, with space padding" "$BINARY script-expression 'sh(pk( $PUB_KEY2 ))#cn8qmyud'" "sh(pk( $PUB_KEY2 ))#cn8qmyud"
run_test "sh pk --compute-checksum public key3, with space padding" "$BINARY script-expression 'sh(pk( $PUB_KEY3 ))#qecu2240'" "sh(pk( $PUB_KEY3 ))#qecu2240"
run_test "sh pk --compute-checksum wif, with space padding" "$BINARY script-expression 'sh(pk( $WIF ))#5lchaun8'" "sh(pk( $WIF ))#5lchaun8"

run_test "sh pk --compute-checksum private key1, short checksum1" "$BINARY script-expression --compute-checksum 'sh(pk($PRV_KEY1))#dse8d4m'" "sh(pk($PRV_KEY1))#62px7n5g"
run_test "sh pk --compute-checksum private key1, short checksum2" "$BINARY script-expression --compute-checksum 'sh(pk($PRV_KEY1))#dse8d4'" "sh(pk($PRV_KEY1))#62px7n5g"
run_test "sh pk --compute-checksum private key1, short checksum3" "$BINARY script-expression --compute-checksum 'sh(pk($PRV_KEY1))#dse8d'" "sh(pk($PRV_KEY1))#62px7n5g"
run_test "sh pk --compute-checksum private key1, short checksum4" "$BINARY script-expression --compute-checksum 'sh(pk($PRV_KEY1))#dse8'" "sh(pk($PRV_KEY1))#62px7n5g"
run_test "sh pk --compute-checksum private key1, short checksum5" "$BINARY script-expression --compute-checksum 'sh(pk($PRV_KEY1))#dse'" "sh(pk($PRV_KEY1))#62px7n5g"
run_test "sh pk --compute-checksum private key1, short checksum6" "$BINARY script-expression --compute-checksum 'sh(pk($PRV_KEY1))#ds'" "sh(pk($PRV_KEY1))#62px7n5g"
run_test "sh pk --compute-checksum private key1, short checksum7" "$BINARY script-expression --compute-checksum 'sh(pk($PRV_KEY1))#d'" "sh(pk($PRV_KEY1))#62px7n5g"
run_test "sh pk --compute-checksum private key1, short checksum8" "$BINARY script-expression --compute-checksum 'sh(pk($PRV_KEY1))#'" "sh(pk($PRV_KEY1))#62px7n5g"
run_test "sh pk --compute-checksum private key1, short checksum9" "$BINARY script-expression --compute-checksum 'sh(pk($PRV_KEY1))'" "sh(pk($PRV_KEY1))#62px7n5g"

run_test "sh pk --compute-checksum public key1, short checksum1" "$BINARY script-expression --compute-checksum 'sh(pk($PUB_KEY1))#axav5m0'" "sh(pk($PUB_KEY1))#qlvf5ul4"
run_test "sh pk --compute-checksum public key1, short checksum2" "$BINARY script-expression --compute-checksum 'sh(pk($PUB_KEY1))#axav5m'" "sh(pk($PUB_KEY1))#qlvf5ul4"
run_test "sh pk --compute-checksum public key1, short checksum3" "$BINARY script-expression --compute-checksum 'sh(pk($PUB_KEY1))#axav5'" "sh(pk($PUB_KEY1))#qlvf5ul4"
run_test "sh pk --compute-checksum public key1, short checksum4" "$BINARY script-expression --compute-checksum 'sh(pk($PUB_KEY1))#axav'" "sh(pk($PUB_KEY1))#qlvf5ul4"
run_test "sh pk --compute-checksum public key1, short checksum5" "$BINARY script-expression --compute-checksum 'sh(pk($PUB_KEY1))#axa'" "sh(pk($PUB_KEY1))#qlvf5ul4"
run_test "sh pk --compute-checksum public key1, short checksum6" "$BINARY script-expression --compute-checksum 'sh(pk($PUB_KEY1))#ax'" "sh(pk($PUB_KEY1))#qlvf5ul4"
run_test "sh pk --compute-checksum public key1, short checksum7" "$BINARY script-expression --compute-checksum 'sh(pk($PUB_KEY1))#a'" "sh(pk($PUB_KEY1))#qlvf5ul4"
run_test "sh pk --compute-checksum public key1, short checksum8" "$BINARY script-expression --compute-checksum 'sh(pk($PUB_KEY1))#'" "sh(pk($PUB_KEY1))#qlvf5ul4"
run_test "sh pk --compute-checksum public key1, short checksum9" "$BINARY script-expression --compute-checksum 'sh(pk($PUB_KEY1))'" "sh(pk($PUB_KEY1))#qlvf5ul4"

run_test "sh pk --compute-checksum wif, short checksum1" "$BINARY script-expression --compute-checksum 'sh(pk($WIF))#alm7cpq'" "sh(pk($WIF))#90g9xgnn"
run_test "sh pk --compute-checksum wif, short checksum2" "$BINARY script-expression --compute-checksum 'sh(pk($WIF))#alm7cp'" "sh(pk($WIF))#90g9xgnn"
run_test "sh pk --compute-checksum wif, short checksum3" "$BINARY script-expression --compute-checksum 'sh(pk($WIF))#alm7c'" "sh(pk($WIF))#90g9xgnn"
run_test "sh pk --compute-checksum wif, short checksum4" "$BINARY script-expression --compute-checksum 'sh(pk($WIF))#alm7'" "sh(pk($WIF))#90g9xgnn"
run_test "sh pk --compute-checksum wif, short checksum5" "$BINARY script-expression --compute-checksum 'sh(pk($WIF))#alm'" "sh(pk($WIF))#90g9xgnn"
run_test "sh pk --compute-checksum wif, short checksum6" "$BINARY script-expression --compute-checksum 'sh(pk($WIF))#al'" "sh(pk($WIF))#90g9xgnn"
run_test "sh pk --compute-checksum wif, short checksum7" "$BINARY script-expression --compute-checksum 'sh(pk($WIF))#a'" "sh(pk($WIF))#90g9xgnn"
run_test "sh pk --compute-checksum wif, short checksum8" "$BINARY script-expression --compute-checksum 'sh(pk($WIF))#'" "sh(pk($WIF))#90g9xgnn"
run_test "sh pk --compute-checksum wif, short checksum9" "$BINARY script-expression --compute-checksum 'sh(pk($WIF))'" "sh(pk($WIF))#90g9xgnn"

run_test "sh pk --compute-checksum private key1, large checksum" "$BINARY script-expression --compute-checksum 'sh(pk($PRV_KEY1))#62px7n5g'" "sh(pk($PRV_KEY1))#62px7n5g"
run_test "sh pk --compute-checksum public key1, large checksum" "$BINARY script-expression --compute-checksum 'sh(pk($PUB_KEY1))#qlvf5ul4'" "sh(pk($PUB_KEY1))#qlvf5ul4"
run_test "sh pk --compute-checksum wif, large checksum" "$BINARY script-expression --compute-checksum 'sh(pk($WIF))#90g9xgnn'" "sh(pk($WIF))#90g9xgnn"

run_test "sh pk --compute-checksum private key1, large checksum2" "$BINARY script-expression --compute-checksum 'sh(pk($PRV_KEY1))#62px7n5g'" "sh(pk($PRV_KEY1))#62px7n5g"
run_test "sh pk --compute-checksum public key1, large checksum2" "$BINARY script-expression --compute-checksum 'sh(pk($PUB_KEY1))#qlvf5ul4'" "sh(pk($PUB_KEY1))#qlvf5ul4"
run_test "sh pk --compute-checksum wif, large checksum2" "$BINARY script-expression --compute-checksum 'sh(pk($WIF))#90g9xgnn'" "sh(pk($WIF))#90g9xgnn"

run_test "sh pk --compute-checksum private key1, extra large checksum" "$BINARY script-expression --compute-checksum 'sh(pk($PRV_KEY1))#dse8dsafbidsnjofdibvsundodiifdbuhnoinidfufdsaf4m1'" "sh(pk($PRV_KEY1))#62px7n5g"
run_test "sh pk --compute-checksum public key1, extra large checksum" "$BINARY script-expression --compute-checksum 'sh(pk($PUB_KEY1))#axdav5mgwefvurbhinuoimqiewnoubrnomwrguifokpgronuinmf01'" "sh(pk($PUB_KEY1))#qlvf5ul4"

run_test "sh pk --compute-checksum private key1, checksum is another script" "$BINARY script-expression --compute-checksum 'sh(pk($PRV_KEY1))#sh(multi(0, xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8))))'" "sh(pk($PRV_KEY1))#62px7n5g"
run_test "sh pk --compute-checksum public key1, checksum is another script" "$BINARY script-expression --compute-checksum 'sh(pk($PUB_KEY1))#sh(multi(0, xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8))))'" "sh(pk($PUB_KEY1))#qlvf5ul4"
run_test "sh pk --compute-checksum wif, checksum is another script" "$BINARY script-expression --compute-checksum 'sh(pk($WIF))#sh(multi(0, xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8))))'" "sh(pk($WIF))#90g9xgnn"

run_test "sh pk --compute-checksum private key1, checksum has multiple hashes" "$BINARY script-expression --compute-checksum 'sh(pk($PRV_KEY1))###sh(multi(0, xpub661MyMwAqRbc#gS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8#))#))#))))'" "sh(pk($PRV_KEY1))#62px7n5g"
run_test "sh pk --compute-checksum public key1, checksum has multiple hashes" "$BINARY script-expression --compute-checksum 'sh(pk($PUB_KEY1))###sh(multi(0, xpub661MyMwAqRbc#gS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8#))#))#))))'" "sh(pk($PUB_KEY1))#qlvf5ul4"
run_test "sh pk --compute-checksum wif, checksum has multiple hashes" "$BINARY script-expression --compute-checksum 'sh(pk($WIF))###sh(multi(0, xpub661MyMwAqRbc#gS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8#))#))#))))'" "sh(pk($WIF))#90g9xgnn"


# --- SH PKH ---
echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running valid tests for SH PKH with no flags ...${NC}"
run_test "sh pkh private key1" "$BINARY script-expression 'sh(pkh($PRV_KEY1))#axav5m0j'" "sh(pkh($PRV_KEY1))#axav5m0j"
run_test "sh pkh private key2" "$BINARY script-expression 'sh(pkh($PRV_KEY2))#cga9zxuz'" "sh(pkh($PRV_KEY2))#cga9zxuz"
run_test "sh pkh private key3" "$BINARY script-expression 'sh(pkh($PRV_KEY3))#lqn0r8mc'" "sh(pkh($PRV_KEY3))#lqn0r8mc"
run_test "sh pkh public key1" "$BINARY script-expression 'sh(pkh($PUB_KEY1))#dse8d4mx'" "sh(pkh($PUB_KEY1))#dse8d4mx"
run_test "sh pkh public key2" "$BINARY script-expression 'sh(pkh($PUB_KEY2))#ew5qtxuy'" "sh(pkh($PUB_KEY2))#ew5qtxuy"
run_test "sh pkh public key3" "$BINARY script-expression 'sh(pkh($PUB_KEY3))#l7e8w7wc'" "sh(pkh($PUB_KEY3))#l7e8w7wc"
run_test "sh pkh wif" "$BINARY script-expression 'sh(pkh($WIF))#alm7cpqh'" "sh(pkh($WIF))#alm7cpqh"

run_test "sh pkh private key1, no checksum" "$BINARY script-expression 'sh(pkh($PRV_KEY1))'" "sh(pkh($PRV_KEY1))"
run_test "sh pkh private key2, no checksum" "$BINARY script-expression 'sh(pkh($PRV_KEY2))'" "sh(pkh($PRV_KEY2))"
run_test "sh pkh private key3, no checksum" "$BINARY script-expression 'sh(pkh($PRV_KEY3))'" "sh(pkh($PRV_KEY3))"
run_test "sh pkh public key1, no checksum" "$BINARY script-expression 'sh(pkh($PUB_KEY1))'" "sh(pkh($PUB_KEY1))"
run_test "sh pkh public key2, no checksum" "$BINARY script-expression 'sh(pkh($PUB_KEY2))'" "sh(pkh($PUB_KEY2))"
run_test "sh pkh public key3, no checksum" "$BINARY script-expression 'sh(pkh($PUB_KEY3))'" "sh(pkh($PUB_KEY3))"
run_test "sh pkh wif, no checksum" "$BINARY script-expression 'sh(pkh($WIF))'" "sh(pkh($WIF))"

run_test "sh pkh private key1, wrong checksum" "$BINARY script-expression 'sh(pkh($PRV_KEY1))#axav5maj'" "sh(pkh($PRV_KEY1))#axav5maj"
run_test "sh pkh private key2, wrong checksum" "$BINARY script-expression 'sh(pkh($PRV_KEY2))#cga9zxux'" "sh(pkh($PRV_KEY2))#cga9zxux"
run_test "sh pkh private key3, wrong checksum" "$BINARY script-expression 'sh(pkh($PRV_KEY3))#lqn0r8mx'" "sh(pkh($PRV_KEY3))#lqn0r8mx"
run_test "sh pkh public key1, wrong checksum" "$BINARY script-expression 'sh(pkh($PUB_KEY1))#dse8d4mc'" "sh(pkh($PUB_KEY1))#dse8d4mc"
run_test "sh pkh public key2, wrong checksum" "$BINARY script-expression 'sh(pkh($PUB_KEY2))#ew5qtxux'" "sh(pkh($PUB_KEY2))#ew5qtxux"
run_test "sh pkh public key3, wrong checksum" "$BINARY script-expression 'sh(pkh($PUB_KEY3))#l7e8w7ww'" "sh(pkh($PUB_KEY3))#l7e8w7ww"
run_test "sh pkh wif, wrong checksum" "$BINARY script-expression 'sh(pkh($WIF))#alm7cpqc'" "sh(pkh($WIF))#alm7cpqc"

run_test "sh pkh private key1, with space padding" "$BINARY script-expression 'sh(pkh( $PRV_KEY1 ))#e3pmfztz'" "sh(pkh( $PRV_KEY1 ))#e3pmfztz"
run_test "sh pkh private key2, with space padding" "$BINARY script-expression 'sh(pkh( $PRV_KEY2 ))#85n8tjw6'" "sh(pkh( $PRV_KEY2 ))#85n8tjw6"
run_test "sh pkh private key3, with space padding" "$BINARY script-expression 'sh(pkh( $PRV_KEY3 ))#g5dgutdf'" "sh(pkh( $PRV_KEY3 ))#g5dgutdf"
run_test "sh pkh public key1, with space padding" "$BINARY script-expression 'sh(pkh( $PUB_KEY1 ))#nhrdq9w4'" "sh(pkh( $PUB_KEY1 ))#nhrdq9w4"
run_test "sh pkh public key2, with space padding" "$BINARY script-expression 'sh(pkh( $PUB_KEY2 ))#cn8qmyud'" "sh(pkh( $PUB_KEY2 ))#cn8qmyud"
run_test "sh pkh public key3, with space padding" "$BINARY script-expression 'sh(pkh( $PUB_KEY3 ))#qecu2240'" "sh(pkh( $PUB_KEY3 ))#qecu2240"
run_test "sh pkh wif, with space padding" "$BINARY script-expression 'sh(pkh( $WIF ))#5lchaun8'" "sh(pkh( $WIF ))#5lchaun8"

run_test "sh pkh private key1, with space padding" "$BINARY script-expression 'sh(pkh( $PRV_KEY1 ))#99999999'" "sh(pkh( $PRV_KEY1 ))#99999999"
run_test "sh pkh private key2, with space padding" "$BINARY script-expression 'sh(pkh( $PRV_KEY2 ))#99999999'" "sh(pkh( $PRV_KEY2 ))#99999999"
run_test "sh pkh private key3, with space padding" "$BINARY script-expression 'sh(pkh( $PRV_KEY3 ))#99999999'" "sh(pkh( $PRV_KEY3 ))#99999999"
run_test "sh pkh public key1, with space padding" "$BINARY script-expression 'sh(pkh( $PUB_KEY1 ))#99999999'" "sh(pkh( $PUB_KEY1 ))#99999999"
run_test "sh pkh public key2, with space padding" "$BINARY script-expression 'sh(pkh( $PUB_KEY2 ))#99999999'" "sh(pkh( $PUB_KEY2 ))#99999999"
run_test "sh pkh public key3, with space padding" "$BINARY script-expression 'sh(pkh( $PUB_KEY3 ))#99999999'" "sh(pkh( $PUB_KEY3 ))#99999999"
run_test "sh pkh wif, with space padding" "$BINARY script-expression 'sh(pkh( $WIF ))#99999999'" "sh(pkh( $WIF ))#99999999"

echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running valid tests for PKH --verify-checksum ...${NC}"
run_test "sh pkh --verify-checksum private key1" "$BINARY script-expression --verify-checksum 'sh(pkh($PRV_KEY1))#3jcn5swh'" "OK"
run_test "sh pkh --verify-checksum private key2" "$BINARY script-expression --verify-checksum 'sh(pkh($PRV_KEY2))#ly2yvs7c'" "OK"
run_test "sh pkh --verify-checksum private key3" "$BINARY script-expression --verify-checksum 'sh(pkh($PRV_KEY3))#8w4ca7h6'" "OK"
run_test "sh pkh --verify-checksum public key1" "$BINARY script-expression --verify-checksum 'sh(pkh($PUB_KEY1))#7xvl7kfh'" "OK"
run_test "sh pkh --verify-checksum public key2" "$BINARY script-expression --verify-checksum 'sh(pkh($PUB_KEY2))#93gel8wc'" "OK"
run_test "sh pkh --verify-checksum public key3" "$BINARY script-expression --verify-checksum 'sh(pkh($PUB_KEY3))#23kkg7dt'" "OK"
run_test "sh pkh --verify-checksum wif" "$BINARY script-expression --verify-checksum 'sh(pkh($WIF))#6fx953n6'" "OK"

echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running valid tests for PKH --compute-checksum ...${NC}"
run_test "sh pkh --compute-checksum private key1" "$BINARY script-expression --compute-checksum 'sh(pkh($PRV_KEY1))#dse8d4mx'" "sh(pkh($PRV_KEY1))#3jcn5swh"
run_test "sh pkh --compute-checksum private key2" "$BINARY script-expression --compute-checksum 'sh(pkh($PRV_KEY2))#ew5qtxuy'" "sh(pkh($PRV_KEY2))#ly2yvs7c"
run_test "sh pkh --compute-checksum private key3" "$BINARY script-expression --compute-checksum 'sh(pkh($PRV_KEY3))#l7e8w7wc'" "sh(pkh($PRV_KEY3))#8w4ca7h6"
run_test "sh pkh --compute-checksum public key1" "$BINARY script-expression --compute-checksum 'sh(pkh($PUB_KEY1))#axav5m0j'" "sh(pkh($PUB_KEY1))#7xvl7kfh"
run_test "sh pkh --compute-checksum public key2" "$BINARY script-expression --compute-checksum 'sh(pkh($PUB_KEY2))#cga9zxuz'" "sh(pkh($PUB_KEY2))#93gel8wc"
run_test "sh pkh --compute-checksum public key3" "$BINARY script-expression --compute-checksum 'sh(pkh($PUB_KEY3))#lqn0r8mc'" "sh(pkh($PUB_KEY3))#23kkg7dt"
run_test "sh pkh --compute-checksum wif" "$BINARY script-expression --compute-checksum 'sh(pkh($WIF))#alm7cpqh'" "sh(pkh($WIF))#6fx953n6"

run_test "sh pkh --compute-checksum private key1, with space padding" "$BINARY script-expression 'sh(pkh( $PRV_KEY1 ))#e3pmfztz'" "sh(pkh( $PRV_KEY1 ))#e3pmfztz"
run_test "sh pkh --compute-checksum private key2, with space padding" "$BINARY script-expression 'sh(pkh( $PRV_KEY2 ))#85n8tjw6'" "sh(pkh( $PRV_KEY2 ))#85n8tjw6"
run_test "sh pkh --compute-checksum private key3, with space padding" "$BINARY script-expression 'sh(pkh( $PRV_KEY3 ))#g5dgutdf'" "sh(pkh( $PRV_KEY3 ))#g5dgutdf"
run_test "sh pkh --compute-checksum public key1, with space padding" "$BINARY script-expression 'sh(pkh( $PUB_KEY1 ))#nhrdq9w4'" "sh(pkh( $PUB_KEY1 ))#nhrdq9w4"
run_test "sh pkh --compute-checksum public key2, with space padding" "$BINARY script-expression 'sh(pkh( $PUB_KEY2 ))#cn8qmyud'" "sh(pkh( $PUB_KEY2 ))#cn8qmyud"
run_test "sh pkh --compute-checksum public key3, with space padding" "$BINARY script-expression 'sh(pkh( $PUB_KEY3 ))#qecu2240'" "sh(pkh( $PUB_KEY3 ))#qecu2240"
run_test "sh pkh --compute-checksum wif, with space padding" "$BINARY script-expression 'sh(pkh( $WIF ))#5lchaun8'" "sh(pkh( $WIF ))#5lchaun8"

run_test "sh pkh --compute-checksum private key1, short checksum1" "$BINARY script-expression --compute-checksum 'sh(pkh($PRV_KEY1))#dse8d4m'" "sh(pkh($PRV_KEY1))#3jcn5swh"
run_test "sh pkh --compute-checksum private key1, short checksum2" "$BINARY script-expression --compute-checksum 'sh(pkh($PRV_KEY1))#dse8d4'" "sh(pkh($PRV_KEY1))#3jcn5swh"
run_test "sh pkh --compute-checksum private key1, short checksum3" "$BINARY script-expression --compute-checksum 'sh(pkh($PRV_KEY1))#dse8d'" "sh(pkh($PRV_KEY1))#3jcn5swh"
run_test "sh pkh --compute-checksum private key1, short checksum4" "$BINARY script-expression --compute-checksum 'sh(pkh($PRV_KEY1))#dse8'" "sh(pkh($PRV_KEY1))#3jcn5swh"
run_test "sh pkh --compute-checksum private key1, short checksum5" "$BINARY script-expression --compute-checksum 'sh(pkh($PRV_KEY1))#dse'" "sh(pkh($PRV_KEY1))#3jcn5swh"
run_test "sh pkh --compute-checksum private key1, short checksum6" "$BINARY script-expression --compute-checksum 'sh(pkh($PRV_KEY1))#ds'" "sh(pkh($PRV_KEY1))#3jcn5swh"
run_test "sh pkh --compute-checksum private key1, short checksum7" "$BINARY script-expression --compute-checksum 'sh(pkh($PRV_KEY1))#d'" "sh(pkh($PRV_KEY1))#3jcn5swh"
run_test "sh pkh --compute-checksum private key1, short checksum8" "$BINARY script-expression --compute-checksum 'sh(pkh($PRV_KEY1))#'" "sh(pkh($PRV_KEY1))#3jcn5swh"
run_test "sh pkh --compute-checksum private key1, short checksum9" "$BINARY script-expression --compute-checksum 'sh(pkh($PRV_KEY1))'" "sh(pkh($PRV_KEY1))#3jcn5swh"

run_test "sh pkh --compute-checksum public key1, short checksum1" "$BINARY script-expression --compute-checksum 'sh(pkh($PUB_KEY1))#axav5m0'" "sh(pkh($PUB_KEY1))#7xvl7kfh"
run_test "sh pkh --compute-checksum public key1, short checksum2" "$BINARY script-expression --compute-checksum 'sh(pkh($PUB_KEY1))#axav5m'" "sh(pkh($PUB_KEY1))#7xvl7kfh"
run_test "sh pkh --compute-checksum public key1, short checksum3" "$BINARY script-expression --compute-checksum 'sh(pkh($PUB_KEY1))#axav5'" "sh(pkh($PUB_KEY1))#7xvl7kfh"
run_test "sh pkh --compute-checksum public key1, short checksum4" "$BINARY script-expression --compute-checksum 'sh(pkh($PUB_KEY1))#axav'" "sh(pkh($PUB_KEY1))#7xvl7kfh"
run_test "sh pkh --compute-checksum public key1, short checksum5" "$BINARY script-expression --compute-checksum 'sh(pkh($PUB_KEY1))#axa'" "sh(pkh($PUB_KEY1))#7xvl7kfh"
run_test "sh pkh --compute-checksum public key1, short checksum6" "$BINARY script-expression --compute-checksum 'sh(pkh($PUB_KEY1))#ax'" "sh(pkh($PUB_KEY1))#7xvl7kfh"
run_test "sh pkh --compute-checksum public key1, short checksum7" "$BINARY script-expression --compute-checksum 'sh(pkh($PUB_KEY1))#a'" "sh(pkh($PUB_KEY1))#7xvl7kfh"
run_test "sh pkh --compute-checksum public key1, short checksum8" "$BINARY script-expression --compute-checksum 'sh(pkh($PUB_KEY1))#'" "sh(pkh($PUB_KEY1))#7xvl7kfh"
run_test "sh pkh --compute-checksum public key1, short checksum9" "$BINARY script-expression --compute-checksum 'sh(pkh($PUB_KEY1))'" "sh(pkh($PUB_KEY1))#7xvl7kfh"

run_test "sh pkh --compute-checksum wif, short checksum1" "$BINARY script-expression --compute-checksum 'sh(pkh($WIF))#alm7cpq'" "sh(pkh($WIF))#6fx953n6"
run_test "sh pkh --compute-checksum wif, short checksum2" "$BINARY script-expression --compute-checksum 'sh(pkh($WIF))#alm7cp'" "sh(pkh($WIF))#6fx953n6"
run_test "sh pkh --compute-checksum wif, short checksum3" "$BINARY script-expression --compute-checksum 'sh(pkh($WIF))#alm7c'" "sh(pkh($WIF))#6fx953n6"
run_test "sh pkh --compute-checksum wif, short checksum4" "$BINARY script-expression --compute-checksum 'sh(pkh($WIF))#alm7'" "sh(pkh($WIF))#6fx953n6"
run_test "sh pkh --compute-checksum wif, short checksum5" "$BINARY script-expression --compute-checksum 'sh(pkh($WIF))#alm'" "sh(pkh($WIF))#6fx953n6"
run_test "sh pkh --compute-checksum wif, short checksum6" "$BINARY script-expression --compute-checksum 'sh(pkh($WIF))#al'" "sh(pkh($WIF))#6fx953n6"
run_test "sh pkh --compute-checksum wif, short checksum7" "$BINARY script-expression --compute-checksum 'sh(pkh($WIF))#a'" "sh(pkh($WIF))#6fx953n6"
run_test "sh pkh --compute-checksum wif, short checksum8" "$BINARY script-expression --compute-checksum 'sh(pkh($WIF))#'" "sh(pkh($WIF))#6fx953n6"
run_test "sh pkh --compute-checksum wif, short checksum9" "$BINARY script-expression --compute-checksum 'sh(pkh($WIF))'" "sh(pkh($WIF))#6fx953n6"

run_test "sh pkh --compute-checksum private key1, large checksum" "$BINARY script-expression --compute-checksum 'sh(pkh($PRV_KEY1))#62px7n5g'" "sh(pkh($PRV_KEY1))#3jcn5swh"
run_test "sh pkh --compute-checksum public key1, large checksum" "$BINARY script-expression --compute-checksum 'sh(pkh($PUB_KEY1))#qlvf5ul4'" "sh(pkh($PUB_KEY1))#7xvl7kfh"
run_test "sh pkh --compute-checksum wif, large checksum" "$BINARY script-expression --compute-checksum 'sh(pkh($WIF))#90g9xgnn'" "sh(pkh($WIF))#6fx953n6"

run_test "sh pkh --compute-checksum private key1, large checksum2" "$BINARY script-expression --compute-checksum 'sh(pkh($PRV_KEY1))#62px7n5g'" "sh(pkh($PRV_KEY1))#3jcn5swh"
run_test "sh pkh --compute-checksum public key1, large checksum2" "$BINARY script-expression --compute-checksum 'sh(pkh($PUB_KEY1))#qlvf5ul4'" "sh(pkh($PUB_KEY1))#7xvl7kfh"
run_test "sh pkh --compute-checksum wif, large checksum2" "$BINARY script-expression --compute-checksum 'sh(pkh($WIF))#90g9xgnn'" "sh(pkh($WIF))#6fx953n6"

run_test "sh pkh --compute-checksum private key1, extra large checksum" "$BINARY script-expression --compute-checksum 'sh(pkh($PRV_KEY1))#dse8dsafbidsnjofdibvsundodiifdbuhnoinidfufdsaf4m1'" "sh(pkh($PRV_KEY1))#3jcn5swh"
run_test "sh pkh --compute-checksum public key1, extra large checksum" "$BINARY script-expression --compute-checksum 'sh(pkh($PUB_KEY1))#axdav5mgwefvurbhinuoimqiewnoubrnomwrguifokpgronuinmf01'" "sh(pkh($PUB_KEY1))#7xvl7kfh"

run_test "sh pkh --compute-checksum private key1, checksum is another script" "$BINARY script-expression --compute-checksum 'sh(pkh($PRV_KEY1))#sh(multi(0, xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8))))'" "sh(pkh($PRV_KEY1))#3jcn5swh"
run_test "sh pkh --compute-checksum public key1, checksum is another script" "$BINARY script-expression --compute-checksum 'sh(pkh($PUB_KEY1))#sh(multi(0, xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8))))'" "sh(pkh($PUB_KEY1))#7xvl7kfh"
run_test "sh pkh --compute-checksum wif, checksum is another script" "$BINARY script-expression --compute-checksum 'sh(pkh($WIF))#sh(multi(0, xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8))))'" "sh(pkh($WIF))#6fx953n6"

run_test "sh pkh --compute-checksum private key1, checksum has multiple hashes" "$BINARY script-expression --compute-checksum 'sh(pkh($PRV_KEY1))###sh(multi(0, xpub661MyMwAqRbc#gS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8#))#))#))))'" "sh(pkh($PRV_KEY1))#3jcn5swh"
run_test "sh pkh --compute-checksum public key1, checksum has multiple hashes" "$BINARY script-expression --compute-checksum 'sh(pkh($PUB_KEY1))###sh(multi(0, xpub661MyMwAqRbc#gS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8#))#))#))))'" "sh(pkh($PUB_KEY1))#7xvl7kfh"
run_test "sh pkh --compute-checksum wif, checksum has multiple hashes" "$BINARY script-expression --compute-checksum 'sh(pkh($WIF))###sh(multi(0, xpub661MyMwAqRbc#gS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8#))#))#))))'" "sh(pkh($WIF))#6fx953n6"

# --- SH MULTI ---
echo -e "\n\n${GREEN}✔ [SCRIPT-EXPRESSION] Running valid tests for SH MULTI with no flags ...${NC}"
run_test "Basic sh multi" "$BINARY script-expression 'sh(multi(1, $PUB_KEY1))'" "sh(multi(1, $PUB_KEY1))"
run_test "Basic sh multi with multiple public keys" "$BINARY script-expression 'sh(multi(3, $PUB_KEY1, $PUB_KEY2, $PUB_KEY3))'" "sh(multi(3, $PUB_KEY1, $PUB_KEY2, $PUB_KEY3))"
run_test "Basic sh multi with multiple private keys" "$BINARY script-expression 'sh(multi(3, $PRV_KEY1, $PRV_KEY2, $PRV_KEY3))'" "sh(multi(3, $PRV_KEY1, $PRV_KEY2, $PRV_KEY3))"

run_test "Basic sh multi with multiple public keys - small k" "$BINARY script-expression 'sh(multi(2, $PUB_KEY1, $PUB_KEY2, $PUB_KEY3))'" "sh(multi(2, $PUB_KEY1, $PUB_KEY2, $PUB_KEY3))"
run_test "Basic sh multi with multiple private keys large k" "$BINARY script-expression 'sh(multi(1, $PRV_KEY1, $PRV_KEY2, $PRV_KEY3))'" "sh(multi(1, $PRV_KEY1, $PRV_KEY2, $PRV_KEY3))"

run_test "sh multi private key1, no checksum" "$BINARY script-expression 'sh(multi(1, $PRV_KEY1))'" "sh(multi(1, $PRV_KEY1))"
run_test "sh multi private key2, no checksum" "$BINARY script-expression 'sh(multi(1, $PRV_KEY2))'" "sh(multi(1, $PRV_KEY2))"
run_test "sh multi private key3, no checksum" "$BINARY script-expression 'sh(multi(1, $PRV_KEY3))'" "sh(multi(1, $PRV_KEY3))"
run_test "sh multi public key1, no checksum" "$BINARY script-expression 'sh(multi(1, $PUB_KEY1))'" "sh(multi(1, $PUB_KEY1))"
run_test "sh multi public key2, no checksum" "$BINARY script-expression 'sh(multi(1, $PUB_KEY2))'" "sh(multi(1, $PUB_KEY2))"
run_test "sh multi public key3, no checksum" "$BINARY script-expression 'sh(multi(1, $PUB_KEY3))'" "sh(multi(1, $PUB_KEY3))"

run_test "sh multi private key1, wrong checksum" "$BINARY script-expression 'sh(multi(1, $PRV_KEY1))#axav5maj'" "sh(multi(1, $PRV_KEY1))#axav5maj"
run_test "sh multi private key2, wrong checksum" "$BINARY script-expression 'sh(multi(1, $PRV_KEY2))#cga9zxux'" "sh(multi(1, $PRV_KEY2))#cga9zxux"
run_test "sh multi private key3, wrong checksum" "$BINARY script-expression 'sh(multi(1, $PRV_KEY3))#lqn0r8mx'" "sh(multi(1, $PRV_KEY3))#lqn0r8mx"
run_test "sh multi public key1, wrong checksum" "$BINARY script-expression 'sh(multi(1, $PUB_KEY1))#dse8d4mc'" "sh(multi(1, $PUB_KEY1))#dse8d4mc"
run_test "sh multi public key2, wrong checksum" "$BINARY script-expression 'sh(multi(1, $PUB_KEY2))#ew5qtxux'" "sh(multi(1, $PUB_KEY2))#ew5qtxux"
run_test "sh multi public key3, wrong checksum" "$BINARY script-expression 'sh(multi(1, $PUB_KEY3))#l7e8w7ww'" "sh(multi(1, $PUB_KEY3))#l7e8w7ww"

run_test "sh multi private key1, with space padding" "$BINARY script-expression 'sh(multi(1,  $PRV_KEY1 ))#e3pmfztz'" "sh(multi(1,  $PRV_KEY1 ))#e3pmfztz"
run_test "sh multi private key2, with space padding" "$BINARY script-expression 'sh(multi(1,  $PRV_KEY2 ))#85n8tjw6'" "sh(multi(1,  $PRV_KEY2 ))#85n8tjw6"
run_test "sh multi private key3, with space padding" "$BINARY script-expression 'sh(multi(1,  $PRV_KEY3 ))#g5dgutdf'" "sh(multi(1,  $PRV_KEY3 ))#g5dgutdf"
run_test "sh multi public key1, with space padding" "$BINARY script-expression 'sh(multi(1,  $PUB_KEY1 ))#nhrdq9w4'" "sh(multi(1,  $PUB_KEY1 ))#nhrdq9w4"
run_test "sh multi public key2, with space padding" "$BINARY script-expression 'sh(multi(1,  $PUB_KEY2 ))#cn8qmyud'" "sh(multi(1,  $PUB_KEY2 ))#cn8qmyud"
run_test "sh multi public key3, with space padding" "$BINARY script-expression 'sh(multi(1,  $PUB_KEY3 ))#qecu2240'" "sh(multi(1,  $PUB_KEY3 ))#qecu2240"

run_test "sh multi private key1, with space padding" "$BINARY script-expression 'sh(multi(1,  $PRV_KEY1 ))#99999999'" "sh(multi(1,  $PRV_KEY1 ))#99999999"
run_test "sh multi private key2, with space padding" "$BINARY script-expression 'sh(multi(1,  $PRV_KEY2 ))#99999999'" "sh(multi(1,  $PRV_KEY2 ))#99999999"
run_test "sh multi private key3, with space padding" "$BINARY script-expression 'sh(multi(1,  $PRV_KEY3 ))#99999999'" "sh(multi(1,  $PRV_KEY3 ))#99999999"
run_test "sh multi public key1, with space padding" "$BINARY script-expression 'sh(multi(1,  $PUB_KEY1 ))#99999999'" "sh(multi(1,  $PUB_KEY1 ))#99999999"
run_test "sh multi public key2, with space padding" "$BINARY script-expression 'sh(multi(1,  $PUB_KEY2 ))#99999999'" "sh(multi(1,  $PUB_KEY2 ))#99999999"
run_test "sh multi public key3, with space padding" "$BINARY script-expression 'sh(multi(1,  $PUB_KEY3 ))#99999999'" "sh(multi(1,  $PUB_KEY3 ))#99999999"

echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running valid tests for multi --verify-checksum ...${NC}"
run_test "sh multi --verify-checksum private key1" "$BINARY script-expression --verify-checksum 'sh(multi(1, $PRV_KEY1))#h37lap95'" "OK"
run_test "sh multi --verify-checksum private key2" "$BINARY script-expression --verify-checksum 'sh(multi(1, $PRV_KEY2))#xr27t9py'" "OK"
run_test "sh multi --verify-checksum private key3" "$BINARY script-expression --verify-checksum 'sh(multi(1, $PRV_KEY3))#q8xkxrum'" "OK"
run_test "sh multi --verify-checksum public key1" "$BINARY script-expression --verify-checksum 'sh(multi(1, $PUB_KEY1))#dynshwwf'" "OK"
run_test "sh multi --verify-checksum public key2" "$BINARY script-expression --verify-checksum 'sh(multi(1, $PUB_KEY2))#7aqeprtd'" "OK"
run_test "sh multi --verify-checksum public key3" "$BINARY script-expression --verify-checksum 'sh(multi(1, $PUB_KEY3))#7dwmlkum'" "OK"

echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running valid tests for multi --compute-checksum ...${NC}"
run_test "sh multi --compute-checksum private key1" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PRV_KEY1))#ga2lpt74'" "sh(multi(1, $PRV_KEY1))#h37lap95"
run_test "sh multi --compute-checksum private key2" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PRV_KEY2))#y0a5tzt6'" "sh(multi(1, $PRV_KEY2))#xr27t9py"
run_test "sh multi --compute-checksum private key3" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PRV_KEY3))#zlsnw6ex'" "sh(multi(1, $PRV_KEY3))#q8xkxrum"
run_test "sh multi --compute-checksum public key1" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PUB_KEY1))#q85c5lcv'" "sh(multi(1, $PUB_KEY1))#dynshwwf"
run_test "sh multi --compute-checksum public key2" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PUB_KEY2))#9f53zztu'" "sh(multi(1, $PUB_KEY2))#7aqeprtd"
run_test "sh multi --compute-checksum public key3" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PUB_KEY3))#zp6mrrvx'" "sh(multi(1, $PUB_KEY3))#7dwmlkum"

run_test "sh multi --compute-checksum private key1, with space padding" "$BINARY script-expression 'sh(multi(1,  $PRV_KEY1 ))#s3snd3vc'" "sh(multi(1,  $PRV_KEY1 ))#s3snd3vc"
run_test "sh multi --compute-checksum private key2, with space padding" "$BINARY script-expression 'sh(multi(1,  $PRV_KEY2 ))#85n8tjw6'" "sh(multi(1,  $PRV_KEY2 ))#85n8tjw6"
run_test "sh multi --compute-checksum private key3, with space padding" "$BINARY script-expression 'sh(multi(1,  $PRV_KEY3 ))#g5dgutdf'" "sh(multi(1,  $PRV_KEY3 ))#g5dgutdf"
run_test "sh multi --compute-checksum public key1, with space padding" "$BINARY script-expression 'sh(multi(1,  $PUB_KEY1 ))#q85c5lcv'" "sh(multi(1,  $PUB_KEY1 ))#q85c5lcv"
run_test "sh multi --compute-checksum public key2, with space padding" "$BINARY script-expression 'sh(multi(1,  $PUB_KEY2 ))#9f53zztu'" "sh(multi(1,  $PUB_KEY2 ))#9f53zztu"
run_test "sh multi --compute-checksum public key3, with space padding" "$BINARY script-expression 'sh(multi(1,  $PUB_KEY3 ))#zp6mrrvx'" "sh(multi(1,  $PUB_KEY3 ))#zp6mrrvx"

run_test "sh multi --compute-checksum private key1, short checksum1" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PRV_KEY1))#dse8d4m'" "sh(multi(1, $PRV_KEY1))#h37lap95"
run_test "sh multi --compute-checksum private key1, short checksum2" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PRV_KEY1))#dse8d4'" "sh(multi(1, $PRV_KEY1))#h37lap95"
run_test "sh multi --compute-checksum private key1, short checksum3" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PRV_KEY1))#dse8d'" "sh(multi(1, $PRV_KEY1))#h37lap95"
run_test "sh multi --compute-checksum private key1, short checksum4" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PRV_KEY1))#dse8'" "sh(multi(1, $PRV_KEY1))#h37lap95"
run_test "sh multi --compute-checksum private key1, short checksum5" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PRV_KEY1))#dse'" "sh(multi(1, $PRV_KEY1))#h37lap95"
run_test "sh multi --compute-checksum private key1, short checksum6" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PRV_KEY1))#ds'" "sh(multi(1, $PRV_KEY1))#h37lap95"
run_test "sh multi --compute-checksum private key1, short checksum7" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PRV_KEY1))#d'" "sh(multi(1, $PRV_KEY1))#h37lap95"
run_test "sh multi --compute-checksum private key1, short checksum8" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PRV_KEY1))#'" "sh(multi(1, $PRV_KEY1))#h37lap95"
run_test "sh multi --compute-checksum private key1, short checksum9" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PRV_KEY1))'" "sh(multi(1, $PRV_KEY1))#h37lap95"

run_test "sh multi --compute-checksum public key1, short checksum1" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PUB_KEY1))#axav5m0'" "sh(multi(1, $PUB_KEY1))#dynshwwf"
run_test "sh multi --compute-checksum public key1, short checksum2" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PUB_KEY1))#axav5m'" "sh(multi(1, $PUB_KEY1))#dynshwwf"
run_test "sh multi --compute-checksum public key1, short checksum3" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PUB_KEY1))#axav5'" "sh(multi(1, $PUB_KEY1))#dynshwwf"
run_test "sh multi --compute-checksum public key1, short checksum4" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PUB_KEY1))#axav'" "sh(multi(1, $PUB_KEY1))#dynshwwf"
run_test "sh multi --compute-checksum public key1, short checksum5" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PUB_KEY1))#axa'" "sh(multi(1, $PUB_KEY1))#dynshwwf"
run_test "sh multi --compute-checksum public key1, short checksum6" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PUB_KEY1))#ax'" "sh(multi(1, $PUB_KEY1))#dynshwwf"
run_test "sh multi --compute-checksum public key1, short checksum7" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PUB_KEY1))#a'" "sh(multi(1, $PUB_KEY1))#dynshwwf"
run_test "sh multi --compute-checksum public key1, short checksum8" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PUB_KEY1))#'" "sh(multi(1, $PUB_KEY1))#dynshwwf"
run_test "sh multi --compute-checksum public key1, short checksum9" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PUB_KEY1))'" "sh(multi(1, $PUB_KEY1))#dynshwwf"

run_test "sh multi --compute-checksum private key1, large checksum" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PRV_KEY1))#s3snd3vc'" "sh(multi(1, $PRV_KEY1))#h37lap95"
run_test "sh multi --compute-checksum public key1, large checksum" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PUB_KEY1))#axav5m01'" "sh(multi(1, $PUB_KEY1))#dynshwwf"

run_test "sh multi --compute-checksum private key1, large checksum2" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PRV_KEY1))#dse8ds4m1'" "sh(multi(1, $PRV_KEY1))#h37lap95"
run_test "sh multi --compute-checksum public key1, large checksum2" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PUB_KEY1))#axdav5m01'" "sh(multi(1, $PUB_KEY1))#dynshwwf"

run_test "sh multi --compute-checksum private key1, extra large checksum" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PRV_KEY1))#dse8dsafbidsnjofdibvsundodiifdbuhnoinidfufdsaf4m1'" "sh(multi(1, $PRV_KEY1))#h37lap95"
run_test "sh multi --compute-checksum public key1, extra large checksum" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PUB_KEY1))#axdav5mgwefvurbhinuoimqiewnoubrnomwrguifokpgronuinmf01'" "sh(multi(1, $PUB_KEY1))#dynshwwf"




# -------- Fail tests --------
# --- RAW ---
echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for RAW with no flags ...${NC}"
run_fail_test "Raw checksum wrong length" "$BINARY script-expression 'raw(deadbeef)#89f8sp'"
run_fail_test "Raw no checksum" "$BINARY script-expression 'raw(deadbeef)#'"
run_fail_test "Raw wrong expression1" "$BINARY script-expression 'r aw(deadbeef)'"
run_fail_test "Raw wrong expression2" "$BINARY script-expression 'raww(deadbeef)'"
run_fail_test "Raw wrong space padding" "$BINARY script-expression 'raw (deadbeef)'"
run_fail_test "Raw unknown pre-fix" "$BINARY script-expression 'aasdsd raw(deadbeef)'"
run_fail_test "Raw another expression pre-fix" "$BINARY script-expression 'raw(deadbeef)raw(deadbeef)'"
run_fail_test "Raw multiple parenthesis" "$BINARY script-expression 'raw(deadbeef)(deadbeef)'"
run_fail_test "Raw wrong parenthesis1" "$BINARY script-expression 'raw{deadbeef}'"
run_fail_test "Raw wrong parenthesis2" "$BINARY script-expression 'raw[deadbeef]'"
run_fail_test "Raw script caps-lock" "$BINARY script-expression 'RAW(deadbeef)'"
run_fail_test "Raw wrong order" "$BINARY script-expression '89f8spxm#raw(deadbeef)'"

echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for RAW --verify-checksum ...${NC}"
run_fail_test "Raw wrong checksum" "$BINARY script-expression --verify-checksum 'raw(deadbeef)#89f8spxx'"
run_fail_test "Raw checksum wrong length" "$BINARY script-expression --verify-checksum 'raw(deadbeef)#89f8sp'"
run_fail_test "Raw no checksum" "$BINARY script-expression --verify-checksum 'raw(deadbeef)#'"
run_fail_test "Raw wrong expression1" "$BINARY script-expression --verify-checksum 'r aw(deadbeef)'"
run_fail_test "Raw wrong expression2" "$BINARY script-expression --verify-checksum 'raww(deadbeef)'"
run_fail_test "Raw wrong space padding" "$BINARY script-expression --verify-checksum 'raw (deadbeef)'"
run_fail_test "Raw unknown pre-fix" "$BINARY script-expression --verify-checksum 'aasdsd raw(deadbeef)'"
run_fail_test "Raw another expression pre-fix" "$BINARY script-expression --verify-checksum 'raw(deadbeef)raw(deadbeef)'"
run_fail_test "Raw bad HEX" "$BINARY script-expression --verify-checksum 'raw(deadbeefdeadbeef)'"
run_fail_test "Raw multiple parenthesis" "$BINARY script-expression --verify-checksum 'raw(deadbeef)(deadbeef)'"
run_fail_test "Raw wrong parenthesis1" "$BINARY script-expression --verify-checksum 'raw{deadbeef}'"
run_fail_test "Raw wrong parenthesis2" "$BINARY script-expression --verify-checksum 'raw[deadbeef]'"
run_fail_test "Raw script caps-lock" "$BINARY script-expression --verify-checksum 'RAW(deadbeef)'"
run_fail_test "Raw wrong order" "$BINARY script-expression --verify-checksum '89f8spxm#raw(deadbeef)'"

echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for RAW --compute-checksum ...${NC}"
run_fail_test "Raw wrong expression1" "$BINARY script-expression --compute-checksum 'r aw(deadbeef)'"
run_fail_test "Raw wrong expression2" "$BINARY script-expression --compute-checksum 'raww(deadbeef)'"
run_fail_test "Raw wrong space padding" "$BINARY script-expression --compute-checksum 'raw (deadbeef)'"
run_fail_test "Raw unknown pre-fix" "$BINARY script-expression --compute-checksum 'aasdsd raw(deadbeef)'"
run_fail_test "Raw another expression pre-fix" "$BINARY script-expression --compute-checksum 'raw(deadbeef)raw(deadbeef)'"
run_fail_test "Raw multiple parenthesis" "$BINARY script-expression --compute-checksum 'raw(deadbeef)(deadbeef)'"
run_fail_test "Raw wrong parenthesis1" "$BINARY script-expression --compute-checksum 'raw{deadbeef}'"
run_fail_test "Raw wrong parenthesis2" "$BINARY script-expression --compute-checksum 'raw[deadbeef]'"
run_fail_test "Raw script caps-lock" "$BINARY script-expression --compute-checksum 'RAW(deadbeef)'"
run_fail_test "Raw wrong order" "$BINARY script-expression --compute-checksum '89f8spxm#raw(deadbeef)'"

echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for RAW with 2 flags ...${NC}"
run_fail_test "Raw both flags presented1" "$BINARY script-expression --verify-checksum --compute-checksum 'raw(deadbeef)#89f8spxm'"
run_fail_test "Raw both flags presented2" "$BINARY script-expression --compute-checksum --verify-checksum 'raw(deadbeef)#89f8spxm'"

# --- PK ---
echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for PK with no flags ..."
run_fail_test "pk wrong private key" "$BINARY script-expression 'pk(xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8)#dse8d4'"
run_fail_test "pk wrong public key" "$BINARY script-expression 'pk(xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHsi)#axav5m'"
run_fail_test "pk wrong wif" "$BINARY script-expression 'pk([deadbeef/0h/1h/2]5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTsJ)#alm7cp'"

run_fail_test "pk private key, checksum wrong length" "$BINARY script-expression 'pk($PRV_KEY1)#dse8d4'"
run_fail_test "pk public key, wrong length" "$BINARY script-expression 'pk($PUB_KEY1)#axav5m'"
run_fail_test "pk wif, checksum wrong length" "$BINARY script-expression 'pk($WIF)#alm7cp'"

run_fail_test "pk private key, no checksum and hashtag" "$BINARY script-expression 'pk($PRV_KEY1)#'"
run_fail_test "pk public key, no checksum and hashtag" "$BINARY script-expression 'pk($PUB_KEY1)#'"
run_fail_test "pk wif, no checksum and hashtag" "$BINARY script-expression 'pk($WIF)#'"

run_fail_test "pk private key, wrong expression1" "$BINARY script-expression 'p k($PRV_KEY1)#'"
run_fail_test "pk public key, wrong expression1" "$BINARY script-expression 'p k($PUB_KEY1)#'"
run_fail_test "pk wif, wrong expression1" "$BINARY script-expression 'p k($WIF)#'"

run_fail_test "pk private key, wrong expression2" "$BINARY script-expression 'pkk($PRV_KEY1)#'"
run_fail_test "pk public key, wrong expression2" "$BINARY script-expression 'pkk($PUB_KEY1)#'"
run_fail_test "pk wif, wrong expression2" "$BINARY script-expression 'pkk($WIF)#'"

run_fail_test "pk private key, wrong space padding" "$BINARY script-expression 'pk ($PRV_KEY1)#'"
run_fail_test "pk public key, wrong space padding" "$BINARY script-expression 'pk ($PUB_KEY1)#'"
run_fail_test "pk wif, wrong space padding" "$BINARY script-expression 'pk ($WIF)#'"

run_fail_test "pk private key, unknown pre-fix" "$BINARY script-expression 'asdsad pk($PRV_KEY1)#'"
run_fail_test "pk public key, unknown pre-fix" "$BINARY script-expression 'dasdsa pk($PUB_KEY1)#'"
run_fail_test "pk wif, unknown pre-fix" "$BINARY script-expression 'rqwrew pk($WIF)#'"

run_fail_test "pk private key, another expression pre-fix" "$BINARY script-expression 'pk($PRV_KEY1)pk($PRV_KEY1)'"
run_fail_test "pk public key, another expression pre-fix" "$BINARY script-expression 'pk($PUB_KEY1)pk($PRV_KEY1)'"
run_fail_test "pk wif, another expression pre-fix" "$BINARY script-expression 'pk($WIF)pk($PRV_KEY1)'"

run_fail_test "pk private key, bad argument" "$BINARY script-expression 'pk($PRV_KEY1$PRV_KEY1)'"
run_fail_test "pk public key, bad argument" "$BINARY script-expression 'pk($PUB_KEY1$PUB_KEY1)'"
run_fail_test "pk wif, bad argument" "$BINARY script-expression 'pk($WIF$WIF)'"

run_fail_test "pk private key, multiple parenthesis" "$BINARY script-expression 'pk($PRV_KEY1)($PRV_KEY1)'"
run_fail_test "pk public key, multiple parenthesis" "$BINARY script-expression 'pk($PUB_KEY1)($PRV_KEY1)'"
run_fail_test "pk wif, multiple parenthesis" "$BINARY script-expression 'pk($WIF)($PRV_KEY1)'"

run_fail_test "pk private key, wrong parenthesis" "$BINARY script-expression 'pk{$PRV_KEY1}'"
run_fail_test "pk public key, wrong parenthesis" "$BINARY script-expression 'pk{$PUB_KEY1}'"
run_fail_test "pk wif, wrong parenthesis" "$BINARY script-expression 'pk{$WIF}'"

run_fail_test "pk private key, wrong parenthesis2" "$BINARY script-expression 'pk[$PRV_KEY1]'"
run_fail_test "pk public key, wrong parenthesis2" "$BINARY script-expression 'pk[$PUB_KEY1]'"
run_fail_test "pk wif, wrong parenthesis2" "$BINARY script-expression 'pk[$WIF]'"

run_fail_test "pk private key, script caps-lock" "$BINARY script-expression 'PK($PRV_KEY1)'"
run_fail_test "pk public key, script caps-lock" "$BINARY script-expression 'PK($PUB_KEY1)'"
run_fail_test "pk wif, script caps-lock" "$BINARY script-expression 'PK($WIF)'"

run_fail_test "pk private key, wrong order" "$BINARY script-expression 'dse8d4mx#pk($PRV_KEY1)'"
run_fail_test "pk public key, wrong order" "$BINARY script-expression 'axav5m01#pk($PUB_KEY1)'"
run_fail_test "pk wif, wrong order" "$BINARY script-expression 'alm7cpqh#pk($WIF)'"


echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for PK with --verify-checksum ...${NC}"
run_fail_test "pk private key --verify-checksum, checksum wrong length" "$BINARY script-expression --verify-checksum 'pk($PRV_KEY1)#dse8d4'"
run_fail_test "pk public key --verify-checksum, wrong length" "$BINARY script-expression --verify-checksum 'pk($PUB_KEY1)#axav5m'"
run_fail_test "pk wif --verify-checksum, checksum wrong length" "$BINARY script-expression --verify-checksum 'pk($WIF)#alm7cp'"

run_fail_test "pk private key --verify-checksum, no checksum and hashtag" "$BINARY script-expression --verify-checksum 'pk($PRV_KEY1)#'"
run_fail_test "pk public key --verify-checksum, no checksum and hashtag" "$BINARY script-expression --verify-checksum 'pk($PUB_KEY1)#'"
run_fail_test "pk wif --verify-checksum, no checksum and hashtag" "$BINARY script-expression --verify-checksum 'pk($WIF)#'"

run_fail_test "pk private key --verify-checksum, wrong expression1" "$BINARY script-expression --verify-checksum 'p k($PRV_KEY1)#'"
run_fail_test "pk public key --verify-checksum, wrong expression1" "$BINARY script-expression --verify-checksum 'p k($PUB_KEY1)#'"
run_fail_test "pk wif --verify-checksum, wrong expression1" "$BINARY script-expression --verify-checksum 'p k($WIF)#'"

run_fail_test "pk private key --verify-checksum, wrong expression2" "$BINARY script-expression --verify-checksum 'pkk($PRV_KEY1)#'"
run_fail_test "pk public key --verify-checksum, wrong expression2" "$BINARY script-expression --verify-checksum 'pkk($PUB_KEY1)#'"
run_fail_test "pk wif --verify-checksum, wrong expression2" "$BINARY script-expression --verify-checksum 'pkk($WIF)#'"

run_fail_test "pk private key --verify-checksum, wrong space padding" "$BINARY script-expression --verify-checksum 'pk ($PRV_KEY1)#'"
run_fail_test "pk public key --verify-checksum, wrong space padding" "$BINARY script-expression --verify-checksum 'pk ($PUB_KEY1)#'"
run_fail_test "pk wif --verify-checksum, wrong space padding" "$BINARY script-expression --verify-checksum 'pk ($WIF)#'"

run_fail_test "pk private key --verify-checksum, unknown pre-fix" "$BINARY script-expression --verify-checksum 'asdsad pk($PRV_KEY1)#'"
run_fail_test "pk public key --verify-checksum, unknown pre-fix" "$BINARY script-expression --verify-checksum 'dasdsa pk($PUB_KEY1)#'"
run_fail_test "pk wif --verify-checksum, unknown pre-fix" "$BINARY script-expression --verify-checksum 'rqwrew pk($WIF)#'"

run_fail_test "pk private key --verify-checksum, another expression pre-fix" "$BINARY script-expression --verify-checksum 'pk($PRV_KEY1)pk($PRV_KEY1)'"
run_fail_test "pk public key --verify-checksum, another expression pre-fix" "$BINARY script-expression --verify-checksum 'pk($PUB_KEY1)pk($PRV_KEY1)'"
run_fail_test "pk wif --verify-checksum, another expression pre-fix" "$BINARY script-expression --verify-checksum 'pk($WIF)pk($PRV_KEY1)'"

run_fail_test "pk private key --verify-checksum, bad argument" "$BINARY script-expression --verify-checksum 'pk($PRV_KEY1$PRV_KEY1)'"
run_fail_test "pk public key --verify-checksum, bad argument" "$BINARY script-expression --verify-checksum 'pk($PUB_KEY1$PUB_KEY1)'"
run_fail_test "pk wif --verify-checksum, bad argument" "$BINARY script-expression --verify-checksum 'pk($WIF$WIF)'"

run_fail_test "pk private key --verify-checksum, multiple parenthesis" "$BINARY script-expression --verify-checksum 'pk($PRV_KEY1)($PRV_KEY1)'"
run_fail_test "pk public key --verify-checksum, multiple parenthesis" "$BINARY script-expression --verify-checksum 'pk($PUB_KEY1)($PRV_KEY1)'"
run_fail_test "pk wif --verify-checksum, multiple parenthesis" "$BINARY script-expression --verify-checksum 'pk($WIF)($PRV_KEY1)'"

run_fail_test "pk private key --verify-checksum, wrong parenthesis" "$BINARY script-expression --verify-checksum 'pk{$PRV_KEY1}'"
run_fail_test "pk public key --verify-checksum, wrong parenthesis" "$BINARY script-expression --verify-checksum 'pk{$PUB_KEY1}'"
run_fail_test "pk wif --verify-checksum, wrong parenthesis" "$BINARY script-expression --verify-checksum 'pk{$WIF}'"

run_fail_test "pk private key --verify-checksum, wrong parenthesis2" "$BINARY script-expression --verify-checksum 'pk[$PRV_KEY1]'"
run_fail_test "pk public key --verify-checksum, wrong parenthesis2" "$BINARY script-expression --verify-checksum 'pk[$PUB_KEY1]'"
run_fail_test "pk wif --verify-checksum, wrong parenthesis2" "$BINARY script-expression --verify-checksum 'pk[$WIF]'"

run_fail_test "pk private key --verify-checksum, script caps-lock" "$BINARY script-expression --verify-checksum 'PK($PRV_KEY1)'"
run_fail_test "pk public key --verify-checksum, script caps-lock" "$BINARY script-expression --verify-checksum 'PK($PUB_KEY1)'"
run_fail_test "pk wif --verify-checksum, script caps-lock" "$BINARY script-expression --verify-checksum 'PK($WIF)'"

run_fail_test "pk private key --verify-checksum, wrong order" "$BINARY script-expression --verify-checksum 'dse8d4mx#pk($PRV_KEY1)'"
run_fail_test "pk public key --verify-checksum, wrong order" "$BINARY script-expression --verify-checksum 'axav5m01#pk($PUB_KEY1)'"
run_fail_test "pk wif --verify-checksum, wrong order" "$BINARY script-expression --verify-checksum 'alm7cpqh#pk($WIF)'"


echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for PK with --compute-checksum ...${NC}"

run_fail_test "pk private key --compute-checksum, wrong expression1" "$BINARY script-expression --compute-checksum 'p k($PRV_KEY1)#'"
run_fail_test "pk public key --compute-checksum, wrong expression1" "$BINARY script-expression --compute-checksum 'p k($PUB_KEY1)#'"
run_fail_test "pk wif --compute-checksum, wrong expression1" "$BINARY script-expression --compute-checksum 'p k($WIF)#'"

run_fail_test "pk private key --compute-checksum, wrong expression2" "$BINARY script-expression --compute-checksum 'pkk($PRV_KEY1)#'"
run_fail_test "pk public key --compute-checksum, wrong expression2" "$BINARY script-expression --compute-checksum 'pkk($PUB_KEY1)#'"
run_fail_test "pk wif --compute-checksum, wrong expression2" "$BINARY script-expression --compute-checksum 'pkk($WIF)#'"

run_fail_test "pk private key --compute-checksum, wrong space padding" "$BINARY script-expression --compute-checksum 'pk ($PRV_KEY1)#'"
run_fail_test "pk public key --compute-checksum, wrong space padding" "$BINARY script-expression --compute-checksum 'pk ($PUB_KEY1)#'"
run_fail_test "pk wif --compute-checksum, wrong space padding" "$BINARY script-expression --compute-checksum 'pk ($WIF)#'"

run_fail_test "pk private key --compute-checksum, unknown pre-fix" "$BINARY script-expression --compute-checksum 'asdsad pk($PRV_KEY1)#'"
run_fail_test "pk public key --compute-checksum, unknown pre-fix" "$BINARY script-expression --compute-checksum 'dasdsa pk($PUB_KEY1)#'"
run_fail_test "pk wif --compute-checksum, unknown pre-fix" "$BINARY script-expression --compute-checksum 'rqwrew pk($WIF)#'"

run_fail_test "pk private key --compute-checksum, another expression pre-fix" "$BINARY script-expression --compute-checksum 'pk($PRV_KEY1)pk($PRV_KEY1)'"
run_fail_test "pk public key --compute-checksum, another expression pre-fix" "$BINARY script-expression --compute-checksum 'pk($PUB_KEY1)pk($PRV_KEY1)'"
run_fail_test "pk wif --compute-checksum, another expression pre-fix" "$BINARY script-expression --compute-checksum 'pk($WIF)pk($PRV_KEY1)'"

run_fail_test "pk private key --compute-checksum, bad argument" "$BINARY script-expression --compute-checksum 'pk($PRV_KEY1$PRV_KEY1)'"
run_fail_test "pk public key --compute-checksum, bad argument" "$BINARY script-expression --compute-checksum 'pk($PUB_KEY1$PUB_KEY1)'"
run_fail_test "pk wif --compute-checksum, bad argument" "$BINARY script-expression --compute-checksum 'pk($WIF$WIF)'"

run_fail_test "pk private key --compute-checksum, multiple parenthesis" "$BINARY script-expression --compute-checksum 'pk($PRV_KEY1)($PRV_KEY1)'"
run_fail_test "pk public key --compute-checksum, multiple parenthesis" "$BINARY script-expression --compute-checksum 'pk($PUB_KEY1)($PRV_KEY1)'"
run_fail_test "pk wif --compute-checksum, multiple parenthesis" "$BINARY script-expression --compute-checksum 'pk($WIF)($PRV_KEY1)'"

run_fail_test "pk private key --compute-checksum, wrong parenthesis" "$BINARY script-expression --compute-checksum 'pk{$PRV_KEY1}'"
run_fail_test "pk public key --compute-checksum, wrong parenthesis" "$BINARY script-expression --compute-checksum 'pk{$PUB_KEY1}'"
run_fail_test "pk wif --compute-checksum, wrong parenthesis" "$BINARY script-expression --compute-checksum 'pk{$WIF}'"

run_fail_test "pk private key --compute-checksum, wrong parenthesis2" "$BINARY script-expression --compute-checksum 'pk[$PRV_KEY1]'"
run_fail_test "pk public key --compute-checksum, wrong parenthesis2" "$BINARY script-expression --compute-checksum 'pk[$PUB_KEY1]'"
run_fail_test "pk wif --compute-checksum, wrong parenthesis2" "$BINARY script-expression --compute-checksum 'pk[$WIF]'"

run_fail_test "pk private key --compute-checksum, script caps-lock" "$BINARY script-expression --compute-checksum 'PK($PRV_KEY1)'"
run_fail_test "pk public key --compute-checksum, script caps-lock" "$BINARY script-expression --compute-checksum 'PK($PUB_KEY1)'"
run_fail_test "pk wif --compute-checksum, script caps-lock" "$BINARY script-expression --compute-checksum 'PK($WIF)'"

run_fail_test "pk private key --compute-checksum, wrong order" "$BINARY script-expression --compute-checksum 'dse8d4mx#pk($PRV_KEY1)'"
run_fail_test "pk public key --compute-checksum, wrong order" "$BINARY script-expression --compute-checksum 'axav5m01#pk($PUB_KEY1)'"
run_fail_test "pk wif --compute-checksum, wrong order" "$BINARY script-expression --compute-checksum 'alm7cpqh#pk($WIF)'"

echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for PK with 2 flags ...${NC}"
run_fail_test "pk both flags presented1" "$BINARY script-expression --verify-checksum --compute-checksum 'pk($PUB_KEY1)#89f8spxm'"
run_fail_test "pk both flags presented2" "$BINARY script-expression --compute-checksum --verify-checksum 'pk($PUB_KEY1)#89f8spxm'"


# --- PKH ---
echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for PKH with no flags ..."
run_fail_test "pkh wrong private key" "$BINARY script-expression 'pkh(xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8)#dse8d4'"
run_fail_test "pkh wrong public key" "$BINARY script-expression 'pkh(xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHsi)#axav5m'"
run_fail_test "pkh wrong wif" "$BINARY script-expression 'pkh([deadbeef/0h/1h/2]5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTsJ)#alm7cp'"

run_fail_test "pkh private key, checksum wrong length" "$BINARY script-expression 'pkh($PRV_KEY1)#dse8d4'"
run_fail_test "pkh public key, wrong length" "$BINARY script-expression 'pkh($PUB_KEY1)#axav5m'"
run_fail_test "pkh wif, checksum wrong length" "$BINARY script-expression 'pkh($WIF)#alm7cp'"

run_fail_test "pkh private key, no checksum and hashtag" "$BINARY script-expression 'pkh($PRV_KEY1)#'"
run_fail_test "pkh public key, no checksum and hashtag" "$BINARY script-expression 'pkh($PUB_KEY1)#'"
run_fail_test "pkh wif, no checksum and hashtag" "$BINARY script-expression 'pkh($WIF)#'"

run_fail_test "pkh private key, wrong expression1" "$BINARY script-expression 'p k($PRV_KEY1)#'"
run_fail_test "pkh public key, wrong expression1" "$BINARY script-expression 'p k($PUB_KEY1)#'"
run_fail_test "pkh wif, wrong expression1" "$BINARY script-expression 'p k($WIF)#'"

run_fail_test "pkh private key, wrong expression2" "$BINARY script-expression 'pkhk($PRV_KEY1)#'"
run_fail_test "pkh public key, wrong expression2" "$BINARY script-expression 'pkhk($PUB_KEY1)#'"
run_fail_test "pkh wif, wrong expression2" "$BINARY script-expression 'pkhk($WIF)#'"

run_fail_test "pkh private key, wrong space padding" "$BINARY script-expression 'pkh ($PRV_KEY1)#'"
run_fail_test "pkh public key, wrong space padding" "$BINARY script-expression 'pkh ($PUB_KEY1)#'"
run_fail_test "pkh wif, wrong space padding" "$BINARY script-expression 'pkh ($WIF)#'"

run_fail_test "pkh private key, unknown pre-fix" "$BINARY script-expression 'asdsad pkh($PRV_KEY1)#'"
run_fail_test "pkh public key, unknown pre-fix" "$BINARY script-expression 'dasdsa pkh($PUB_KEY1)#'"
run_fail_test "pkh wif, unknown pre-fix" "$BINARY script-expression 'rqwrew pkh($WIF)#'"

run_fail_test "pkh private key, another expression pre-fix" "$BINARY script-expression 'pkh($PRV_KEY1)pkh($PRV_KEY1)'"
run_fail_test "pkh public key, another expression pre-fix" "$BINARY script-expression 'pkh($PUB_KEY1)pkh($PRV_KEY1)'"
run_fail_test "pkh wif, another expression pre-fix" "$BINARY script-expression 'pkh($WIF)pkh($PRV_KEY1)'"

run_fail_test "pkh private key, bad argument" "$BINARY script-expression 'pkh($PRV_KEY1$PRV_KEY1)'"
run_fail_test "pkh public key, bad argument" "$BINARY script-expression 'pkh($PUB_KEY1$PUB_KEY1)'"
run_fail_test "pkh wif, bad argument" "$BINARY script-expression 'pkh($WIF$WIF)'"

run_fail_test "pkh private key, multiple parenthesis" "$BINARY script-expression 'pkh($PRV_KEY1)($PRV_KEY1)'"
run_fail_test "pkh public key, multiple parenthesis" "$BINARY script-expression 'pkh($PUB_KEY1)($PRV_KEY1)'"
run_fail_test "pkh wif, multiple parenthesis" "$BINARY script-expression 'pkh($WIF)($PRV_KEY1)'"

run_fail_test "pkh private key, wrong parenthesis" "$BINARY script-expression 'pkh{$PRV_KEY1}'"
run_fail_test "pkh public key, wrong parenthesis" "$BINARY script-expression 'pkh{$PUB_KEY1}'"
run_fail_test "pkh wif, wrong parenthesis" "$BINARY script-expression 'pkh{$WIF}'"

run_fail_test "pkh private key, wrong parenthesis2" "$BINARY script-expression 'pkh[$PRV_KEY1]'"
run_fail_test "pkh public key, wrong parenthesis2" "$BINARY script-expression 'pkh[$PUB_KEY1]'"
run_fail_test "pkh wif, wrong parenthesis2" "$BINARY script-expression 'pkh[$WIF]'"

run_fail_test "pkh private key, script caps-lock" "$BINARY script-expression 'PKH($PRV_KEY1)'"
run_fail_test "pkh public key, script caps-lock" "$BINARY script-expression 'PKH($PUB_KEY1)'"
run_fail_test "pkh wif, script caps-lock" "$BINARY script-expression 'PKH($WIF)'"

run_fail_test "pkh private key, wrong order" "$BINARY script-expression 'dse8d4mx#pkh($PRV_KEY1)'"
run_fail_test "pkh public key, wrong order" "$BINARY script-expression 'axav5m01#pkh($PUB_KEY1)'"
run_fail_test "pkh wif, wrong order" "$BINARY script-expression 'alm7cpqh#pkh($WIF)'"


echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for PKH with --verify-checksum ...${NC}"
run_fail_test "pkh private key --verify-checksum, checksum wrong length" "$BINARY script-expression --verify-checksum 'pkh($PRV_KEY1)#dse8d4'"
run_fail_test "pkh public key --verify-checksum, wrong length" "$BINARY script-expression --verify-checksum 'pkh($PUB_KEY1)#axav5m'"
run_fail_test "pkh wif --verify-checksum, checksum wrong length" "$BINARY script-expression --verify-checksum 'pkh($WIF)#alm7cp'"

run_fail_test "pkh private key --verify-checksum, no checksum and hashtag" "$BINARY script-expression --verify-checksum 'pkh($PRV_KEY1)#'"
run_fail_test "pkh public key --verify-checksum, no checksum and hashtag" "$BINARY script-expression --verify-checksum 'pkh($PUB_KEY1)#'"
run_fail_test "pkh wif --verify-checksum, no checksum and hashtag" "$BINARY script-expression --verify-checksum 'pkh($WIF)#'"

run_fail_test "pkh private key --verify-checksum, wrong expression1" "$BINARY script-expression --verify-checksum 'p k($PRV_KEY1)#'"
run_fail_test "pkh public key --verify-checksum, wrong expression1" "$BINARY script-expression --verify-checksum 'p k($PUB_KEY1)#'"
run_fail_test "pkh wif --verify-checksum, wrong expression1" "$BINARY script-expression --verify-checksum 'p k($WIF)#'"

run_fail_test "pkh private key --verify-checksum, wrong expression2" "$BINARY script-expression --verify-checksum 'pkhk($PRV_KEY1)#'"
run_fail_test "pkh public key --verify-checksum, wrong expression2" "$BINARY script-expression --verify-checksum 'pkhk($PUB_KEY1)#'"
run_fail_test "pkh wif --verify-checksum, wrong expression2" "$BINARY script-expression --verify-checksum 'pkhk($WIF)#'"

run_fail_test "pkh private key --verify-checksum, wrong space padding" "$BINARY script-expression --verify-checksum 'pkh ($PRV_KEY1)#'"
run_fail_test "pkh public key --verify-checksum, wrong space padding" "$BINARY script-expression --verify-checksum 'pkh ($PUB_KEY1)#'"
run_fail_test "pkh wif --verify-checksum, wrong space padding" "$BINARY script-expression --verify-checksum 'pkh ($WIF)#'"

run_fail_test "pkh private key --verify-checksum, unknown pre-fix" "$BINARY script-expression --verify-checksum 'asdsad pkh($PRV_KEY1)#'"
run_fail_test "pkh public key --verify-checksum, unknown pre-fix" "$BINARY script-expression --verify-checksum 'dasdsa pkh($PUB_KEY1)#'"
run_fail_test "pkh wif --verify-checksum, unknown pre-fix" "$BINARY script-expression --verify-checksum 'rqwrew pkh($WIF)#'"

run_fail_test "pkh private key --verify-checksum, another expression pre-fix" "$BINARY script-expression --verify-checksum 'pkh($PRV_KEY1)pkh($PRV_KEY1)'"
run_fail_test "pkh public key --verify-checksum, another expression pre-fix" "$BINARY script-expression --verify-checksum 'pkh($PUB_KEY1)pkh($PRV_KEY1)'"
run_fail_test "pkh wif --verify-checksum, another expression pre-fix" "$BINARY script-expression --verify-checksum 'pkh($WIF)pkh($PRV_KEY1)'"

run_fail_test "pkh private key --verify-checksum, bad argument" "$BINARY script-expression --verify-checksum 'pkh($PRV_KEY1$PRV_KEY1)'"
run_fail_test "pkh public key --verify-checksum, bad argument" "$BINARY script-expression --verify-checksum 'pkh($PUB_KEY1$PUB_KEY1)'"
run_fail_test "pkh wif --verify-checksum, bad argument" "$BINARY script-expression --verify-checksum 'pkh($WIF$WIF)'"

run_fail_test "pkh private key --verify-checksum, multiple parenthesis" "$BINARY script-expression --verify-checksum 'pkh($PRV_KEY1)($PRV_KEY1)'"
run_fail_test "pkh public key --verify-checksum, multiple parenthesis" "$BINARY script-expression --verify-checksum 'pkh($PUB_KEY1)($PRV_KEY1)'"
run_fail_test "pkh wif --verify-checksum, multiple parenthesis" "$BINARY script-expression --verify-checksum 'pkh($WIF)($PRV_KEY1)'"

run_fail_test "pkh private key --verify-checksum, wrong parenthesis" "$BINARY script-expression --verify-checksum 'pkh{$PRV_KEY1}'"
run_fail_test "pkh public key --verify-checksum, wrong parenthesis" "$BINARY script-expression --verify-checksum 'pkh{$PUB_KEY1}'"
run_fail_test "pkh wif --verify-checksum, wrong parenthesis" "$BINARY script-expression --verify-checksum 'pkh{$WIF}'"

run_fail_test "pkh private key --verify-checksum, wrong parenthesis2" "$BINARY script-expression --verify-checksum 'pkh[$PRV_KEY1]'"
run_fail_test "pkh public key --verify-checksum, wrong parenthesis2" "$BINARY script-expression --verify-checksum 'pkh[$PUB_KEY1]'"
run_fail_test "pkh wif --verify-checksum, wrong parenthesis2" "$BINARY script-expression --verify-checksum 'pkh[$WIF]'"

run_fail_test "pkh private key --verify-checksum, script caps-lock" "$BINARY script-expression --verify-checksum 'pkh($PRV_KEY1)'"
run_fail_test "pkh public key --verify-checksum, script caps-lock" "$BINARY script-expression --verify-checksum 'pkh($PUB_KEY1)'"
run_fail_test "pkh wif --verify-checksum, script caps-lock" "$BINARY script-expression --verify-checksum 'pkh($WIF)'"

run_fail_test "pkh private key --verify-checksum, wrong order" "$BINARY script-expression --verify-checksum 'dse8d4mx#pkh($PRV_KEY1)'"
run_fail_test "pkh public key --verify-checksum, wrong order" "$BINARY script-expression --verify-checksum 'axav5m01#pkh($PUB_KEY1)'"
run_fail_test "pkh wif --verify-checksum, wrong order" "$BINARY script-expression --verify-checksum 'alm7cpqh#pkh($WIF)'"


echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for PK with --compute-checksum ...${NC}"

run_fail_test "pkh private key --compute-checksum, wrong expression1" "$BINARY script-expression --compute-checksum 'p k($PRV_KEY1)#'"
run_fail_test "pkh public key --compute-checksum, wrong expression1" "$BINARY script-expression --compute-checksum 'p k($PUB_KEY1)#'"
run_fail_test "pkh wif --compute-checksum, wrong expression1" "$BINARY script-expression --compute-checksum 'p k($WIF)#'"

run_fail_test "pkh private key --compute-checksum, wrong expression2" "$BINARY script-expression --compute-checksum 'pkhk($PRV_KEY1)#'"
run_fail_test "pkh public key --compute-checksum, wrong expression2" "$BINARY script-expression --compute-checksum 'pkhk($PUB_KEY1)#'"
run_fail_test "pkh wif --compute-checksum, wrong expression2" "$BINARY script-expression --compute-checksum 'pkhk($WIF)#'"

run_fail_test "pkh private key --compute-checksum, wrong space padding" "$BINARY script-expression --compute-checksum 'pkh ($PRV_KEY1)#'"
run_fail_test "pkh public key --compute-checksum, wrong space padding" "$BINARY script-expression --compute-checksum 'pkh ($PUB_KEY1)#'"
run_fail_test "pkh wif --compute-checksum, wrong space padding" "$BINARY script-expression --compute-checksum 'pkh ($WIF)#'"

run_fail_test "pkh private key --compute-checksum, unknown pre-fix" "$BINARY script-expression --compute-checksum 'asdsad pkh($PRV_KEY1)#'"
run_fail_test "pkh public key --compute-checksum, unknown pre-fix" "$BINARY script-expression --compute-checksum 'dasdsa pkh($PUB_KEY1)#'"
run_fail_test "pkh wif --compute-checksum, unknown pre-fix" "$BINARY script-expression --compute-checksum 'rqwrew pkh($WIF)#'"

run_fail_test "pkh private key --compute-checksum, another expression pre-fix" "$BINARY script-expression --compute-checksum 'pkh($PRV_KEY1)pkh($PRV_KEY1)'"
run_fail_test "pkh public key --compute-checksum, another expression pre-fix" "$BINARY script-expression --compute-checksum 'pkh($PUB_KEY1)pkh($PRV_KEY1)'"
run_fail_test "pkh wif --compute-checksum, another expression pre-fix" "$BINARY script-expression --compute-checksum 'pkh($WIF)pkh($PRV_KEY1)'"

run_fail_test "pkh private key --compute-checksum, bad argument" "$BINARY script-expression --compute-checksum 'pkh($PRV_KEY1$PRV_KEY1)'"
run_fail_test "pkh public key --compute-checksum, bad argument" "$BINARY script-expression --compute-checksum 'pkh($PUB_KEY1$PUB_KEY1)'"
run_fail_test "pkh wif --compute-checksum, bad argument" "$BINARY script-expression --compute-checksum 'pkh($WIF$WIF)'"

run_fail_test "pkh private key --compute-checksum, multiple parenthesis" "$BINARY script-expression --compute-checksum 'pkh($PRV_KEY1)($PRV_KEY1)'"
run_fail_test "pkh public key --compute-checksum, multiple parenthesis" "$BINARY script-expression --compute-checksum 'pkh($PUB_KEY1)($PRV_KEY1)'"
run_fail_test "pkh wif --compute-checksum, multiple parenthesis" "$BINARY script-expression --compute-checksum 'pkh($WIF)($PRV_KEY1)'"

run_fail_test "pkh private key --compute-checksum, wrong parenthesis" "$BINARY script-expression --compute-checksum 'pkh{$PRV_KEY1}'"
run_fail_test "pkh public key --compute-checksum, wrong parenthesis" "$BINARY script-expression --compute-checksum 'pkh{$PUB_KEY1}'"
run_fail_test "pkh wif --compute-checksum, wrong parenthesis" "$BINARY script-expression --compute-checksum 'pkh{$WIF}'"

run_fail_test "pkh private key --compute-checksum, wrong parenthesis2" "$BINARY script-expression --compute-checksum 'pkh[$PRV_KEY1]'"
run_fail_test "pkh public key --compute-checksum, wrong parenthesis2" "$BINARY script-expression --compute-checksum 'pkh[$PUB_KEY1]'"
run_fail_test "pkh wif --compute-checksum, wrong parenthesis2" "$BINARY script-expression --compute-checksum 'pkh[$WIF]'"

run_fail_test "pkh private key --compute-checksum, script caps-lock" "$BINARY script-expression --compute-checksum 'PKH($PRV_KEY1)'"
run_fail_test "pkh public key --compute-checksum, script caps-lock" "$BINARY script-expression --compute-checksum 'PKH($PUB_KEY1)'"
run_fail_test "pkh wif --compute-checksum, script caps-lock" "$BINARY script-expression --compute-checksum 'PKH($WIF)'"

run_fail_test "pkh private key --compute-checksum, wrong order" "$BINARY script-expression --compute-checksum 'dse8d4mx#pkh($PRV_KEY1)'"
run_fail_test "pkh public key --compute-checksum, wrong order" "$BINARY script-expression --compute-checksum 'axav5m01#pkh($PUB_KEY1)'"
run_fail_test "pkh wif --compute-checksum, wrong order" "$BINARY script-expression --compute-checksum 'alm7cpqh#pkh($WIF)'"

echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for PKH with 2 flags ...${NC}"
run_fail_test "pkh both flags presented1" "$BINARY script-expression --verify-checksum --compute-checksum 'pkh($PUB_KEY1)#89f8spxm'"
run_fail_test "pkh both flags presented2" "$BINARY script-expression --compute-checksum --verify-checksum 'pkh($PUB_KEY1)#89f8spxm'"


# --- MULTI ---
echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for MULTI with no flags ..."
run_fail_test "multi wrong private key" "$BINARY script-expression 'multi(1, xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8)#dse8d4'"
run_fail_test "multi wrong public key" "$BINARY script-expression 'multi(1, xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHsi)#axav5m'"
run_fail_test "multi wrong wif" "$BINARY script-expression 'multi(1, [deadbeef/0h/1h/2]5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTsJ)#alm7cp'"

run_fail_test "multi wrong k as 0" "$BINARY script-expression 'multi(0, [deadbeef/0h/1h/2]5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTsJ)#alm7cp'"
run_fail_test "multi negative k1" "$BINARY script-expression 'multi(-0, [deadbeef/0h/1h/2]5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTsJ)#alm7cp'"
run_fail_test "multi negative k2" "$BINARY script-expression 'multi(-1, [deadbeef/0h/1h/2]5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTsJ)#alm7cp'"
run_fail_test "multi too big k" "$BINARY script-expression 'multi(2, [deadbeef/0h/1h/2]5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTsJ)#alm7cp'"

run_fail_test "multi k wrong order" "$BINARY script-expression 'multi($PUB_KEY1, 1)#alm7cp'"

run_fail_test "multi private key, wrong expression1" "$BINARY script-expression 'm ulti(1, $PRV_KEY1)#'"
run_fail_test "multi public key, wrong expression1" "$BINARY script-expression 'mult i(1, $PUB_KEY1)#'"
run_fail_test "multi wif, wrong expression1" "$BINARY script-expression 'mu lti(1, $WIF)#'"

run_fail_test "multi private key, wrong expression2" "$BINARY script-expression 'mullti(1, $PRV_KEY1)#'"
run_fail_test "multi public key, wrong expression2" "$BINARY script-expression 'multii(1, $PUB_KEY1)#'"
run_fail_test "multi wif, wrong expression2" "$BINARY script-expression 'mmulti(1, $WIF)#'"

run_fail_test "multi private key, wrong space padding" "$BINARY script-expression 'multi (1, $PRV_KEY1)#'"
run_fail_test "multi public key, wrong space padding" "$BINARY script-expression 'multi (1, $PUB_KEY1)#'"
run_fail_test "multi wif, wrong space padding" "$BINARY script-expression 'multi (1, $WIF)#'"

run_fail_test "multi private key, unknown pre-fix" "$BINARY script-expression 'asdsad multi($PRV_KEY1)#'"
run_fail_test "multi public key, unknown pre-fix" "$BINARY script-expression 'dasdsa multi($PUB_KEY1)#'"
run_fail_test "multi wif, unknown pre-fix" "$BINARY script-expression 'rqwrew multi($WIF)#'"

run_fail_test "multi private key, another expression pre-fix" "$BINARY script-expression 'multi(1, $PRV_KEY1)multi(1, $PRV_KEY1)'"
run_fail_test "multi public key, another expression pre-fix" "$BINARY script-expression 'multi(1, $PUB_KEY1)multi(1, $PRV_KEY1)'"
run_fail_test "multi wif, another expression pre-fix" "$BINARY script-expression 'multi(1, $WIF)multi(1, $PRV_KEY1)'"

run_fail_test "multi private key, bad argument" "$BINARY script-expression 'multi(1, $PRV_KEY1$PRV_KEY1)'"
run_fail_test "multi public key, bad argument" "$BINARY script-expression 'multi(1, $PUB_KEY1$PUB_KEY1)'"
run_fail_test "multi wif, bad argument" "$BINARY script-expression 'multi(1, $WIF$WIF)'"

run_fail_test "multi private key, multiple parenthesis" "$BINARY script-expression 'multi(1, $PRV_KEY1)($PRV_KEY1)'"
run_fail_test "multi public key, multiple parenthesis" "$BINARY script-expression 'multi(1, $PUB_KEY1)($PRV_KEY1)'"
run_fail_test "multi wif, multiple parenthesis" "$BINARY script-expression 'multi(1, $WIF)($PRV_KEY1)'"

run_fail_test "multi private key, wrong parenthesis" "$BINARY script-expression 'multi{1, $PRV_KEY1}'"
run_fail_test "multi public key, wrong parenthesis" "$BINARY script-expression 'multi{1, $PUB_KEY1}'"
run_fail_test "multi wif, wrong parenthesis" "$BINARY script-expression 'multi{1, $WIF}'"

run_fail_test "multi private key, wrong parenthesis2" "$BINARY script-expression 'multi[1, $PRV_KEY1]'"
run_fail_test "multi public key, wrong parenthesis2" "$BINARY script-expression 'multi[1, $PUB_KEY1]'"
run_fail_test "multi wif, wrong parenthesis2" "$BINARY script-expression 'multi[1, $WIF]'"

run_fail_test "multi private key, script caps-lock" "$BINARY script-expression 'MULTI(1, $PRV_KEY1)'"
run_fail_test "multi public key, script caps-lock" "$BINARY script-expression 'MULTI(1, $PUB_KEY1)'"
run_fail_test "multi wif, script caps-lock" "$BINARY script-expression 'MULTI(1, $WIF)'"

run_fail_test "multi private key, wrong order" "$BINARY script-expression 'dse8d4mx#multi(1, $PRV_KEY1)'"
run_fail_test "multi public key, wrong order" "$BINARY script-expression 'axav5m01#multi(1, $PUB_KEY1)'"
run_fail_test "multi wif, wrong order" "$BINARY script-expression 'alm7cpqh#multi(1, $WIF)'"


echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for MULTI with --verify-checksum ...${NC}"
run_fail_test "multi private key --verify-checksum, checksum wrong length" "$BINARY script-expression --verify-checksum 'multi(1, $PRV_KEY1)#dse8d4'"
run_fail_test "multi public key --verify-checksum, wrong length" "$BINARY script-expression --verify-checksum 'multi(1, $PUB_KEY1)#axav5m'"
run_fail_test "multi wif --verify-checksum, checksum wrong length" "$BINARY script-expression --verify-checksum 'multi(1, $WIF)#alm7cp'"

run_fail_test "multi private key --verify-checksum, no checksum and hashtag" "$BINARY script-expression --verify-checksum 'multi(1, $PRV_KEY1)#'"
run_fail_test "multi public key --verify-checksum, no checksum and hashtag" "$BINARY script-expression --verify-checksum 'multi(1, $PUB_KEY1)#'"
run_fail_test "multi wif --verify-checksum, no checksum and hashtag" "$BINARY script-expression --verify-checksum 'multi(1, $WIF)#'"

run_fail_test "multi private key --verify-checksum, wrong expression1" "$BINARY script-expression --verify-checksum 'mu lti($PRV_KEY1)#'"
run_fail_test "multi public key --verify-checksum, wrong expression1" "$BINARY script-expression --verify-checksum 'm ulti($PUB_KEY1)#'"
run_fail_test "multi wif --verify-checksum, wrong expression1" "$BINARY script-expression --verify-checksum 'mult ti($WIF)#'"

run_fail_test "multi private key --verify-checksum, wrong expression2" "$BINARY script-expression --verify-checksum 'multii($PRV_KEY1)#'"
run_fail_test "multi public key --verify-checksum, wrong expression2" "$BINARY script-expression --verify-checksum 'multti($PUB_KEY1)#'"
run_fail_test "multi wif --verify-checksum, wrong expression2" "$BINARY script-expression --verify-checksum 'muulti($WIF)#'"

run_fail_test "multi private key --verify-checksum, wrong space padding" "$BINARY script-expression --verify-checksum 'multi ($PRV_KEY1)#'"
run_fail_test "multi public key --verify-checksum, wrong space padding" "$BINARY script-expression --verify-checksum 'multi ($PUB_KEY1)#'"
run_fail_test "multi wif --verify-checksum, wrong space padding" "$BINARY script-expression --verify-checksum 'multi ($WIF)#'"

run_fail_test "multi private key --verify-checksum, unknown pre-fix" "$BINARY script-expression --verify-checksum 'asdsad multi(1, $PRV_KEY1)#'"
run_fail_test "multi public key --verify-checksum, unknown pre-fix" "$BINARY script-expression --verify-checksum 'dasdsa multi(1, $PUB_KEY1)#'"
run_fail_test "multi wif --verify-checksum, unknown pre-fix" "$BINARY script-expression --verify-checksum 'rqwrew multi(1, $WIF)#'"

run_fail_test "multi private key --verify-checksum, another expression pre-fix" "$BINARY script-expression --verify-checksum 'multi(1, $PRV_KEY1)multi(1, $PRV_KEY1)'"
run_fail_test "multi public key --verify-checksum, another expression pre-fix" "$BINARY script-expression --verify-checksum 'multi(1, $PUB_KEY1)multi(1, $PRV_KEY1)'"
run_fail_test "multi wif --verify-checksum, another expression pre-fix" "$BINARY script-expression --verify-checksum 'multi(1, $WIF)multi(1, $PRV_KEY1)'"

run_fail_test "multi private key --verify-checksum, bad argument" "$BINARY script-expression --verify-checksum 'multi(1, $PRV_KEY1$PRV_KEY1)'"
run_fail_test "multi public key --verify-checksum, bad argument" "$BINARY script-expression --verify-checksum 'multi(1, $PUB_KEY1$PUB_KEY1)'"
run_fail_test "multi wif --verify-checksum, bad argument" "$BINARY script-expression --verify-checksum 'multi(1, $WIF$WIF)'"

run_fail_test "multi private key --verify-checksum, multiple parenthesis" "$BINARY script-expression --verify-checksum 'multi(1, $PRV_KEY1)($PRV_KEY1)'"
run_fail_test "multi public key --verify-checksum, multiple parenthesis" "$BINARY script-expression --verify-checksum 'multi(1, $PUB_KEY1)($PRV_KEY1)'"
run_fail_test "multi wif --verify-checksum, multiple parenthesis" "$BINARY script-expression --verify-checksum 'multi(1, $WIF)($PRV_KEY1)'"

run_fail_test "multi private key --verify-checksum, wrong parenthesis" "$BINARY script-expression --verify-checksum 'multi{1, $PRV_KEY1}'"
run_fail_test "multi public key --verify-checksum, wrong parenthesis" "$BINARY script-expression --verify-checksum 'multi{1, $PUB_KEY1}'"
run_fail_test "multi wif --verify-checksum, wrong parenthesis" "$BINARY script-expression --verify-checksum 'multi{1, $WIF}'"

run_fail_test "multi private key --verify-checksum, wrong parenthesis2" "$BINARY script-expression --verify-checksum 'multi[1, $PRV_KEY1]'"
run_fail_test "multi public key --verify-checksum, wrong parenthesis2" "$BINARY script-expression --verify-checksum 'multi[1, $PUB_KEY1]'"
run_fail_test "multi wif --verify-checksum, wrong parenthesis2" "$BINARY script-expression --verify-checksum 'multi[1, $WIF]'"

run_fail_test "multi private key --verify-checksum, script caps-lock" "$BINARY script-expression --verify-checksum 'MULTI(1, $PRV_KEY1)'"
run_fail_test "multi public key --verify-checksum, script caps-lock" "$BINARY script-expression --verify-checksum 'MULTI(1, $PUB_KEY1)'"
run_fail_test "multi wif --verify-checksum, script caps-lock" "$BINARY script-expression --verify-checksum 'MULTI(1, $WIF)'"

run_fail_test "multi private key --verify-checksum, wrong order" "$BINARY script-expression --verify-checksum 'dse8d4mx#multi(1, $PRV_KEY1)'"
run_fail_test "multi public key --verify-checksum, wrong order" "$BINARY script-expression --verify-checksum 'axav5m01#multi(1, $PUB_KEY1)'"
run_fail_test "multi wif --verify-checksum, wrong order" "$BINARY script-expression --verify-checksum 'alm7cpqh#multi(1, $WIF)'"


echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for MULTI with --compute-checksum ...${NC}"

run_fail_test "multi private key --compute-checksum, wrong expression1" "$BINARY script-expression --compute-checksum 'mu lti($PRV_KEY1)#'"
run_fail_test "multi public key --compute-checksum, wrong expression1" "$BINARY script-expression --compute-checksum 'mult ti($PUB_KEY1)#'"
run_fail_test "multi wif --compute-checksum, wrong expression1" "$BINARY script-expression --compute-checksum 'mult i($WIF)#'"

run_fail_test "multi private key --compute-checksum, wrong expression2" "$BINARY script-expression --compute-checksum 'multii($PRV_KEY1)#'"
run_fail_test "multi public key --compute-checksum, wrong expression2" "$BINARY script-expression --compute-checksum 'multti($PUB_KEY1)#'"
run_fail_test "multi wif --compute-checksum, wrong expression2" "$BINARY script-expression --compute-checksum 'mullti($WIF)#'"

run_fail_test "multi private key --compute-checksum, wrong space padding" "$BINARY script-expression --compute-checksum 'multi ($PRV_KEY1)#'"
run_fail_test "multi public key --compute-checksum, wrong space padding" "$BINARY script-expression --compute-checksum 'multi ($PUB_KEY1)#'"
run_fail_test "multi wif --compute-checksum, wrong space padding" "$BINARY script-expression --compute-checksum 'multi ($WIF)#'"

run_fail_test "multi private key --compute-checksum, unknown pre-fix" "$BINARY script-expression --compute-checksum 'asdsad multi(1, $PRV_KEY1)#'"
run_fail_test "multi public key --compute-checksum, unknown pre-fix" "$BINARY script-expression --compute-checksum 'dasdsa multi(1, $PUB_KEY1)#'"
run_fail_test "multi wif --compute-checksum, unknown pre-fix" "$BINARY script-expression --compute-checksum 'rqwrew multi(1, $WIF)#'"

run_fail_test "multi private key --compute-checksum, another expression pre-fix" "$BINARY script-expression --compute-checksum 'multi(1, $PRV_KEY1)multi(1, $PRV_KEY1)'"
run_fail_test "multi public key --compute-checksum, another expression pre-fix" "$BINARY script-expression --compute-checksum 'multi(1, $PUB_KEY1)multi(1, $PRV_KEY1)'"
run_fail_test "multi wif --compute-checksum, another expression pre-fix" "$BINARY script-expression --compute-checksum 'multi(1, $WIF)multi(1, $PRV_KEY1)'"

run_fail_test "multi private key --compute-checksum, bad argument" "$BINARY script-expression --compute-checksum 'multi(1, $PRV_KEY1$PRV_KEY1)'"
run_fail_test "multi public key --compute-checksum, bad argument" "$BINARY script-expression --compute-checksum 'multi(1, $PUB_KEY1$PUB_KEY1)'"
run_fail_test "multi wif --compute-checksum, bad argument" "$BINARY script-expression --compute-checksum 'multi(1, $WIF$WIF)'"

run_fail_test "multi private key --compute-checksum, multiple parenthesis" "$BINARY script-expression --compute-checksum 'multi(1, $PRV_KEY1)($PRV_KEY1)'"
run_fail_test "multi public key --compute-checksum, multiple parenthesis" "$BINARY script-expression --compute-checksum 'multi(1, $PUB_KEY1)($PRV_KEY1)'"
run_fail_test "multi wif --compute-checksum, multiple parenthesis" "$BINARY script-expression --compute-checksum 'multi(1, $WIF)($PRV_KEY1)'"

run_fail_test "multi private key --compute-checksum, wrong parenthesis" "$BINARY script-expression --compute-checksum 'multi{1, $PRV_KEY1}'"
run_fail_test "multi public key --compute-checksum, wrong parenthesis" "$BINARY script-expression --compute-checksum 'multi{1, $PUB_KEY1}'"
run_fail_test "multi wif --compute-checksum, wrong parenthesis" "$BINARY script-expression --compute-checksum 'multi{1, $WIF}'"

run_fail_test "multi private key --compute-checksum, wrong parenthesis2" "$BINARY script-expression --compute-checksum 'multi[1, $PRV_KEY1]'"
run_fail_test "multi public key --compute-checksum, wrong parenthesis2" "$BINARY script-expression --compute-checksum 'multi[1, $PUB_KEY1]'"
run_fail_test "multi wif --compute-checksum, wrong parenthesis2" "$BINARY script-expression --compute-checksum 'multi[1, $WIF]'"

run_fail_test "multi private key --compute-checksum, script caps-lock" "$BINARY script-expression --compute-checksum 'MULTI(1, $PRV_KEY1)'"
run_fail_test "multi public key --compute-checksum, script caps-lock" "$BINARY script-expression --compute-checksum 'MULTI(1, $PUB_KEY1)'"
run_fail_test "multi wif --compute-checksum, script caps-lock" "$BINARY script-expression --compute-checksum 'MULTI(1, $WIF)'"

run_fail_test "multi private key --compute-checksum, wrong order" "$BINARY script-expression --compute-checksum 'dse8d4mx#multi(1, $PRV_KEY1)'"
run_fail_test "multi public key --compute-checksum, wrong order" "$BINARY script-expression --compute-checksum 'axav5m01#multi(1, $PUB_KEY1)'"
run_fail_test "multi wif --compute-checksum, wrong order" "$BINARY script-expression --compute-checksum 'alm7cpqh#multi(1, $WIF)'"

echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for MULTI with 2 flags ...${NC}"
run_fail_test "multi both flags presented1" "$BINARY script-expression --verify-checksum --compute-checksum 'multi(1, $PUB_KEY1)#89f8spxm'"
run_fail_test "multi both flags presented2" "$BINARY script-expression --compute-checksum --verify-checksum 'multi(1, $PUB_KEY1)#89f8spxm'"


# --- SH PK ---
echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for SH PK with no flags ..."
run_fail_test "sh pk wrong private key" "$BINARY script-expression 'sh(pk(xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8))#dse8d4'"
run_fail_test "sh pk wrong public key" "$BINARY script-expression 'sh(pk(xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHsi))#axav5m'"
run_fail_test "sh pk wrong wif" "$BINARY script-expression 'sh(pk([deadbeef/0h/1h/2]5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTsJ))#alm7cp'"

run_fail_test "sh pk private key, checksum wrong length" "$BINARY script-expression 'sh(pk($PRV_KEY1))#dse8d4'"
run_fail_test "sh pk public key, wrong length" "$BINARY script-expression 'sh(pk($PUB_KEY1))#axav5m'"
run_fail_test "sh pk wif, checksum wrong length" "$BINARY script-expression 'sh(pk($WIF))#alm7cp'"

run_fail_test "sh pk private key, no checksum and hashtag" "$BINARY script-expression 'sh(pk($PRV_KEY1))#'"
run_fail_test "sh pk public key, no checksum and hashtag" "$BINARY script-expression 'sh(pk($PUB_KEY1))#'"
run_fail_test "sh pk wif, no checksum and hashtag" "$BINARY script-expression 'sh(pk($WIF))#'"

run_fail_test "sh pk private key, wrong expression1" "$BINARY script-expression 's h(pk($PRV_KEY1))#'"
run_fail_test "sh pk public key, wrong expression1" "$BINARY script-expression 's h(pk($PUB_KEY1))#'"
run_fail_test "sh pk wif, wrong expression1" "$BINARY script-expression 's h(pk($WIF))#'"

run_fail_test "sh pk private key, wrong expression2" "$BINARY script-expression 'shh(pk($PRV_KEY1))#'"
run_fail_test "sh pk public key, wrong expression2" "$BINARY script-expression 'ssh(pk($PUB_KEY1))#'"
run_fail_test "sh pk wif, wrong expression2" "$BINARY script-expression 'shh(pk($WIF))#'"

run_fail_test "sh pk private key, wrong space padding" "$BINARY script-expression 'sh(pk ($PRV_KEY1))#'"
run_fail_test "sh pk public key, wrong space padding" "$BINARY script-expression 'sh(pk ($PUB_KEY1))#'"
run_fail_test "sh pk wif, wrong space padding" "$BINARY script-expression 'sh(pk ($WIF))#'"

run_fail_test "sh pk private key, unknown pre-fix" "$BINARY script-expression 'asdsad sh(pk($PRV_KEY1))#'"
run_fail_test "sh pk public key, unknown pre-fix" "$BINARY script-expression 'dasdsa sh(pk($PUB_KEY1))#'"
run_fail_test "sh pk wif, unknown pre-fix" "$BINARY script-expression 'rqwrew sh(pk($WIF))#'"

run_fail_test "sh pk private key, another expression pre-fix" "$BINARY script-expression 'sh(pk($PRV_KEY1)sh(pk($PRV_KEY1))'"
run_fail_test "sh pk public key, another expression pre-fix" "$BINARY script-expression 'sh(pk($PUB_KEY1)sh(pk($PRV_KEY1))'"
run_fail_test "sh pk wif, another expression pre-fix" "$BINARY script-expression 'sh(pk($WIF)sh(pk($PRV_KEY1))'"

run_fail_test "sh pk private key, bad argument" "$BINARY script-expression 'sh(pk($PRV_KEY1$PRV_KEY1))'"
run_fail_test "sh pk public key, bad argument" "$BINARY script-expression 'sh(pk($PUB_KEY1$PUB_KEY1))'"
run_fail_test "sh pk wif, bad argument" "$BINARY script-expression 'sh(pk($WIF$WIF))'"

run_fail_test "sh pk private key, multiple parenthesis" "$BINARY script-expression 'sh(pk($PRV_KEY1)($PRV_KEY1))'"
run_fail_test "sh pk public key, multiple parenthesis" "$BINARY script-expression 'sh(pk($PUB_KEY1)($PRV_KEY1))'"
run_fail_test "sh pk wif, multiple parenthesis" "$BINARY script-expression 'sh(pk($WIF)($PRV_KEY1))'"

run_fail_test "sh pk private key, wrong parenthesis" "$BINARY script-expression 'sh{pk{$PRV_KEY1}}'"
run_fail_test "sh pk public key, wrong parenthesis" "$BINARY script-expression 'sh{pk{$PUB_KEY1}}'"
run_fail_test "sh pk wif, wrong parenthesis" "$BINARY script-expression 'sh{pk{$WIF}}'"

run_fail_test "sh pk private key, wrong parenthesis2" "$BINARY script-expression 'sh[pk[$PRV_KEY1]]'"
run_fail_test "sh pk public key, wrong parenthesis2" "$BINARY script-expression 'sh[pk[$PUB_KEY1]]'"
run_fail_test "sh pk wif, wrong parenthesis2" "$BINARY script-expression 'sh[pk[$WIF]]'"

run_fail_test "sh pk private key, script caps-lock" "$BINARY script-expression 'SH(PK($PRV_KEY1))'"
run_fail_test "sh pk public key, script caps-lock" "$BINARY script-expression 'SH(PK($PUB_KEY1))'"
run_fail_test "sh pk wif, script caps-lock" "$BINARY script-expression 'SH(PK($WIF))'"

run_fail_test "sh pk private key, wrong order" "$BINARY script-expression 'dse8d4mx#sh(pk($PRV_KEY1))'"
run_fail_test "sh pk public key, wrong order" "$BINARY script-expression 'axav5m01#sh(pk($PUB_KEY1))'"
run_fail_test "sh pk wif, wrong order" "$BINARY script-expression 'alm7cpqh#sh(pk($WIF))'"


echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for PK with --verify-checksum ...${NC}"
run_fail_test "sh pk private key --verify-checksum, checksum wrong length" "$BINARY script-expression --verify-checksum 'sh(pk($PRV_KEY1))#dse8d4'"
run_fail_test "sh pk public key --verify-checksum, wrong length" "$BINARY script-expression --verify-checksum 'sh(pk($PUB_KEY1))#axav5m'"
run_fail_test "sh pk wif --verify-checksum, checksum wrong length" "$BINARY script-expression --verify-checksum 'sh(pk($WIF))#alm7cp'"

run_fail_test "sh pk private key --verify-checksum, no checksum and hashtag" "$BINARY script-expression --verify-checksum 'sh(pk($PRV_KEY1))#'"
run_fail_test "sh pk public key --verify-checksum, no checksum and hashtag" "$BINARY script-expression --verify-checksum 'sh(pk($PUB_KEY1))#'"
run_fail_test "sh pk wif --verify-checksum, no checksum and hashtag" "$BINARY script-expression --verify-checksum 'sh(pk($WIF))#'"

run_fail_test "sh pk private key --verify-checksum, wrong expression1" "$BINARY script-expression --verify-checksum 's h(pk($PRV_KEY1))#'"
run_fail_test "sh pk public key --verify-checksum, wrong expression1" "$BINARY script-expression --verify-checksum 's h(pk($PUB_KEY1))#'"
run_fail_test "sh pk wif --verify-checksum, wrong expression1" "$BINARY script-expression --verify-checksum 'sh(pk($WIF))#'"

run_fail_test "sh pk private key --verify-checksum, wrong expression2" "$BINARY script-expression --verify-checksum 'sh(pk($PRV_KEY1))#'"
run_fail_test "sh pk public key --verify-checksum, wrong expression2" "$BINARY script-expression --verify-checksum 'sh(pk($PUB_KEY1))#'"
run_fail_test "sh pk wif --verify-checksum, wrong expression2" "$BINARY script-expression --verify-checksum 'sh(pk($WIF))#'"

run_fail_test "sh pk private key --verify-checksum, wrong space padding" "$BINARY script-expression --verify-checksum 'sh(pk ($PRV_KEY1))'"
run_fail_test "sh pk public key --verify-checksum, wrong space padding" "$BINARY script-expression --verify-checksum 'sh(pk ($PUB_KEY1))'"
run_fail_test "sh pk wif --verify-checksum, wrong space padding" "$BINARY script-expression --verify-checksum 'sh(pk ($WIF))'"

run_fail_test "sh pk private key --verify-checksum, unknown pre-fix" "$BINARY script-expression --verify-checksum 'asdsad sh(pk($PRV_KEY1))'"
run_fail_test "sh pk public key --verify-checksum, unknown pre-fix" "$BINARY script-expression --verify-checksum 'dasdsa sh(pk($PUB_KEY1))'"
run_fail_test "sh pk wif --verify-checksum, unknown pre-fix" "$BINARY script-expression --verify-checksum 'rqwrew sh(pk($WIF))'"

run_fail_test "sh pk private key --verify-checksum, another expression pre-fix" "$BINARY script-expression --verify-checksum 'sh(pk($PRV_KEY1)sh(pk($PRV_KEY1))'"
run_fail_test "sh pk public key --verify-checksum, another expression pre-fix" "$BINARY script-expression --verify-checksum 'sh(pk($PUB_KEY1)sh(pk($PRV_KEY1))'"
run_fail_test "sh pk wif --verify-checksum, another expression pre-fix" "$BINARY script-expression --verify-checksum 'sh(pk($WIF)sh(pk($PRV_KEY1))'"

run_fail_test "sh pk private key --verify-checksum, bad argument" "$BINARY script-expression --verify-checksum 'sh(pk($PRV_KEY1$PRV_KEY1))'"
run_fail_test "sh pk public key --verify-checksum, bad argument" "$BINARY script-expression --verify-checksum 'sh(pk($PUB_KEY1$PUB_KEY1))'"
run_fail_test "sh pk wif --verify-checksum, bad argument" "$BINARY script-expression --verify-checksum 'sh(pk($WIF$WIF))'"

run_fail_test "sh pk private key --verify-checksum, multiple parenthesis" "$BINARY script-expression --verify-checksum 'sh(pk($PRV_KEY1)($PRV_KEY1))'"
run_fail_test "sh pk public key --verify-checksum, multiple parenthesis" "$BINARY script-expression --verify-checksum 'sh(pk($PUB_KEY1)($PRV_KEY1))'"
run_fail_test "sh pk wif --verify-checksum, multiple parenthesis" "$BINARY script-expression --verify-checksum 'sh(pk($WIF)($PRV_KEY1))'"

run_fail_test "sh pk private key --verify-checksum, wrong parenthesis" "$BINARY script-expression --verify-checksum 'sh{pk{$PRV_KEY1}}'"
run_fail_test "sh pk public key --verify-checksum, wrong parenthesis" "$BINARY script-expression --verify-checksum 'sh{pk{$PUB_KEY1}}'"
run_fail_test "sh pk wif --verify-checksum, wrong parenthesis" "$BINARY script-expression --verify-checksum 'sh{pk{$WIF}}'"

run_fail_test "sh pk private key --verify-checksum, wrong parenthesis2" "$BINARY script-expression --verify-checksum 'sh[pk[$PRV_KEY1]]'"
run_fail_test "sh pk public key --verify-checksum, wrong parenthesis2" "$BINARY script-expression --verify-checksum 'sh[pk[$PUB_KEY1]]'"
run_fail_test "sh pk wif --verify-checksum, wrong parenthesis2" "$BINARY script-expression --verify-checksum 'sh[pk[$WIF]]'"

run_fail_test "sh pk private key --verify-checksum, script caps-lock" "$BINARY script-expression --verify-checksum 'SH(PK($PRV_KEY1))'"
run_fail_test "sh pk public key --verify-checksum, script caps-lock" "$BINARY script-expression --verify-checksum 'SH(PK($PUB_KEY1))'"
run_fail_test "sh pk wif --verify-checksum, script caps-lock" "$BINARY script-expression --verify-checksum 'SH(PK($WIF))'"

run_fail_test "sh pk private key --verify-checksum, wrong order" "$BINARY script-expression --verify-checksum 'dse8d4mx#sh(pk($PRV_KEY1))'"
run_fail_test "sh pk public key --verify-checksum, wrong order" "$BINARY script-expression --verify-checksum 'axav5m01#sh(pk($PUB_KEY1))'"
run_fail_test "sh pk wif --verify-checksum, wrong order" "$BINARY script-expression --verify-checksum 'alm7cpqh#sh(pk($WIF))'"


echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for PK with --compute-checksum ...${NC}"

run_fail_test "sh pk private key --compute-checksum, wrong expression1" "$BINARY script-expression --compute-checksum 's h(pk($PRV_KEY1))#'"
run_fail_test "sh pk public key --compute-checksum, wrong expression1" "$BINARY script-expression --compute-checksum 's h(pk($PUB_KEY1))#'"
run_fail_test "sh pk wif --compute-checksum, wrong expression1" "$BINARY script-expression --compute-checksum 's h(pk($WIF))#'"

run_fail_test "sh pk private key --compute-checksum, wrong expression2" "$BINARY script-expression --compute-checksum 'shh(pk($PRV_KEY1))#'"
run_fail_test "sh pk public key --compute-checksum, wrong expression2" "$BINARY script-expression --compute-checksum 'shh(pk($PUB_KEY1))#'"
run_fail_test "sh pk wif --compute-checksum, wrong expression2" "$BINARY script-expression --compute-checksum 'ssh(pk($WIF))#'"

run_fail_test "sh pk private key --compute-checksum, wrong space padding" "$BINARY script-expression --compute-checksum 'sh (pk($PRV_KEY1))#'"
run_fail_test "sh pk public key --compute-checksum, wrong space padding" "$BINARY script-expression --compute-checksum 'sh (pk($PUB_KEY1))#'"
run_fail_test "sh pk wif --compute-checksum, wrong space padding" "$BINARY script-expression --compute-checksum 'sh (pk($WIF))#'"

run_fail_test "sh pk private key --compute-checksum, unknown pre-fix" "$BINARY script-expression --compute-checksum 'asdsad sh(pk($PRV_KEY1))'"
run_fail_test "sh pk public key --compute-checksum, unknown pre-fix" "$BINARY script-expression --compute-checksum 'dasdsa sh(pk($PUB_KEY1))'"
run_fail_test "sh pk wif --compute-checksum, unknown pre-fix" "$BINARY script-expression --compute-checksum 'rqwrew sh(pk($WIF))'"

run_fail_test "sh pk private key --compute-checksum, another expression pre-fix" "$BINARY script-expression --compute-checksum 'sh(pk($PRV_KEY1)sh(pk($PRV_KEY1))'"
run_fail_test "sh pk public key --compute-checksum, another expression pre-fix" "$BINARY script-expression --compute-checksum 'sh(pk($PUB_KEY1)sh(pk($PRV_KEY1))'"
run_fail_test "sh pk wif --compute-checksum, another expression pre-fix" "$BINARY script-expression --compute-checksum 'sh(pk($WIF)sh(pk($PRV_KEY1))'"

run_fail_test "sh pk private key --compute-checksum, bad argument" "$BINARY script-expression --compute-checksum 'sh(pk($PRV_KEY1$PRV_KEY1))'"
run_fail_test "sh pk public key --compute-checksum, bad argument" "$BINARY script-expression --compute-checksum 'sh(pk($PUB_KEY1$PUB_KEY1))'"
run_fail_test "sh pk wif --compute-checksum, bad argument" "$BINARY script-expression --compute-checksum 'sh(pk($WIF$WIF))'"

run_fail_test "sh pk private key --compute-checksum, multiple parenthesis" "$BINARY script-expression --compute-checksum 'sh(pk($PRV_KEY1)($PRV_KEY1))'"
run_fail_test "sh pk public key --compute-checksum, multiple parenthesis" "$BINARY script-expression --compute-checksum 'sh(pk($PUB_KEY1)($PRV_KEY1))'"
run_fail_test "sh pk wif --compute-checksum, multiple parenthesis" "$BINARY script-expression --compute-checksum 'sh(pk($WIF)($PRV_KEY1))'"

run_fail_test "sh pk private key --compute-checksum, wrong parenthesis" "$BINARY script-expression --compute-checksum 'sh{pk{$PRV_KEY1}}'"
run_fail_test "sh pk public key --compute-checksum, wrong parenthesis" "$BINARY script-expression --compute-checksum 'sh{pk{$PUB_KEY1}}'"
run_fail_test "sh pk wif --compute-checksum, wrong parenthesis" "$BINARY script-expression --compute-checksum 'sh{pk{$WIF}}'"

run_fail_test "sh pk private key --compute-checksum, wrong parenthesis2" "$BINARY script-expression --compute-checksum 'sh[pk[$PRV_KEY1]]'"
run_fail_test "sh pk public key --compute-checksum, wrong parenthesis2" "$BINARY script-expression --compute-checksum 'sh[pk[$PUB_KEY1]]'"
run_fail_test "sh pk wif --compute-checksum, wrong parenthesis2" "$BINARY script-expression --compute-checksum 'sh[pk[$WIF]]'"

run_fail_test "sh pk private key --compute-checksum, script caps-lock" "$BINARY script-expression --compute-checksum 'SH(PK($PRV_KEY1))'"
run_fail_test "sh pk public key --compute-checksum, script caps-lock" "$BINARY script-expression --compute-checksum 'SH(PK($PUB_KEY1))'"
run_fail_test "sh pk wif --compute-checksum, script caps-lock" "$BINARY script-expression --compute-checksum 'SH(PK($WIF))'"

run_fail_test "sh pk private key --compute-checksum, wrong order" "$BINARY script-expression --compute-checksum 'dse8d4mx#sh(pk($PRV_KEY1))'"
run_fail_test "sh pk public key --compute-checksum, wrong order" "$BINARY script-expression --compute-checksum 'axav5m01#sh(pk($PUB_KEY1))'"
run_fail_test "sh pk wif --compute-checksum, wrong order" "$BINARY script-expression --compute-checksum 'alm7cpqh#sh(pk($WIF))'"

echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for PK with 2 flags ...${NC}"
run_fail_test "sh pk both flags presented1" "$BINARY script-expression --verify-checksum --compute-checksum 'sh(pk($PUB_KEY1))#89f8spxm'"
run_fail_test "sh pk both flags presented2" "$BINARY script-expression --compute-checksum --verify-checksum 'sh(pk($PUB_KEY1))#89f8spxm'"


# --- SH PKH ---
echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for SH PKH with no flags ..."
run_fail_test "sh pkh wrong private key" "$BINARY script-expression 'sh(pkh(xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8))#dse8d4'"
run_fail_test "sh pkh wrong public key" "$BINARY script-expression 'sh(pkh(xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHsi))#axav5m'"
run_fail_test "sh pkh wrong wif" "$BINARY script-expression 'sh(pkh([deadbeef/0h/1h/2]5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTsJ))#alm7cp'"

run_fail_test "sh pkh private key, checksum wrong length" "$BINARY script-expression 'sh(pkh($PRV_KEY1))#dse8d4'"
run_fail_test "sh pkh public key, wrong length" "$BINARY script-expression 'sh(pkh($PUB_KEY1))#axav5m'"
run_fail_test "sh pkh wif, checksum wrong length" "$BINARY script-expression 'sh(pkh($WIF))#alm7cp'"

run_fail_test "sh pkh private key, no checksum and hashtag" "$BINARY script-expression 'sh(pkh($PRV_KEY1))#'"
run_fail_test "sh pkh public key, no checksum and hashtag" "$BINARY script-expression 'sh(pkh($PUB_KEY1))#'"
run_fail_test "sh pkh wif, no checksum and hashtag" "$BINARY script-expression 'sh(pkh($WIF))#'"

run_fail_test "sh pkh private key, wrong expression1" "$BINARY script-expression 's h(pkh($PRV_KEY1))#'"
run_fail_test "sh pkh public key, wrong expression1" "$BINARY script-expression 's h(pkh($PUB_KEY1))#'"
run_fail_test "sh pkh wif, wrong expression1" "$BINARY script-expression 's h(pkh($WIF))#'"

run_fail_test "sh pkh private key, wrong expression2" "$BINARY script-expression 'shh(pkh($PRV_KEY1))#'"
run_fail_test "sh pkh public key, wrong expression2" "$BINARY script-expression 'ssh(pkh($PUB_KEY1))#'"
run_fail_test "sh pkh wif, wrong expression2" "$BINARY script-expression 'shh(pkh($WIF))#'"

run_fail_test "sh pkh private key, wrong space padding" "$BINARY script-expression 'sh(pkh ($PRV_KEY1))#'"
run_fail_test "sh pkh public key, wrong space padding" "$BINARY script-expression 'sh(pkh ($PUB_KEY1))#'"
run_fail_test "sh pkh wif, wrong space padding" "$BINARY script-expression 'sh(pkh ($WIF))#'"

run_fail_test "sh pkh private key, unknown pre-fix" "$BINARY script-expression 'asdsad sh(pkh($PRV_KEY1))#'"
run_fail_test "sh pkh public key, unknown pre-fix" "$BINARY script-expression 'dasdsa sh(pkh($PUB_KEY1))#'"
run_fail_test "sh pkh wif, unknown pre-fix" "$BINARY script-expression 'rqwrew sh(pkh($WIF))#'"

run_fail_test "sh pkh private key, another expression pre-fix" "$BINARY script-expression 'sh(pkh($PRV_KEY1)sh(pkh($PRV_KEY1))'"
run_fail_test "sh pkh public key, another expression pre-fix" "$BINARY script-expression 'sh(pkh($PUB_KEY1)sh(pkh($PRV_KEY1))'"
run_fail_test "sh pkh wif, another expression pre-fix" "$BINARY script-expression 'sh(pkh($WIF)sh(pkh($PRV_KEY1))'"

run_fail_test "sh pkh private key, bad argument" "$BINARY script-expression 'sh(pkh($PRV_KEY1$PRV_KEY1))'"
run_fail_test "sh pkh public key, bad argument" "$BINARY script-expression 'sh(pkh($PUB_KEY1$PUB_KEY1))'"
run_fail_test "sh pkh wif, bad argument" "$BINARY script-expression 'sh(pkh($WIF$WIF))'"

run_fail_test "sh pkh private key, multiple parenthesis" "$BINARY script-expression 'sh(pkh($PRV_KEY1)($PRV_KEY1))'"
run_fail_test "sh pkh public key, multiple parenthesis" "$BINARY script-expression 'sh(pkh($PUB_KEY1)($PRV_KEY1))'"
run_fail_test "sh pkh wif, multiple parenthesis" "$BINARY script-expression 'sh(pkh($WIF)($PRV_KEY1))'"

run_fail_test "sh pkh private key, wrong parenthesis" "$BINARY script-expression 'sh{pkh{$PRV_KEY1}}'"
run_fail_test "sh pkh public key, wrong parenthesis" "$BINARY script-expression 'sh{pkh{$PUB_KEY1}}'"
run_fail_test "sh pkh wif, wrong parenthesis" "$BINARY script-expression 'sh{pkh{$WIF}}'"

run_fail_test "sh pkh private key, wrong parenthesis2" "$BINARY script-expression 'sh[pkh[$PRV_KEY1]]'"
run_fail_test "sh pkh public key, wrong parenthesis2" "$BINARY script-expression 'sh[pkh[$PUB_KEY1]]'"
run_fail_test "sh pkh wif, wrong parenthesis2" "$BINARY script-expression 'sh[pkh[$WIF]]'"

run_fail_test "sh pkh private key, script caps-lock" "$BINARY script-expression 'SH(pkh($PRV_KEY1))'"
run_fail_test "sh pkh public key, script caps-lock" "$BINARY script-expression 'SH(pkh($PUB_KEY1))'"
run_fail_test "sh pkh wif, script caps-lock" "$BINARY script-expression 'SH(pkh($WIF))'"

run_fail_test "sh pkh private key, wrong order" "$BINARY script-expression 'dse8d4mx#sh(pkh($PRV_KEY1))'"
run_fail_test "sh pkh public key, wrong order" "$BINARY script-expression 'axav5m01#sh(pkh($PUB_KEY1))'"
run_fail_test "sh pkh wif, wrong order" "$BINARY script-expression 'alm7cpqh#sh(pkh($WIF))'"


echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for PKH with --verify-checksum ...${NC}"
run_fail_test "sh pkh private key --verify-checksum, checksum wrong length" "$BINARY script-expression --verify-checksum 'sh(pkh($PRV_KEY1))#dse8d4'"
run_fail_test "sh pkh public key --verify-checksum, wrong length" "$BINARY script-expression --verify-checksum 'sh(pkh($PUB_KEY1))#axav5m'"
run_fail_test "sh pkh wif --verify-checksum, checksum wrong length" "$BINARY script-expression --verify-checksum 'sh(pkh($WIF))#alm7cp'"

run_fail_test "sh pkh private key --verify-checksum, no checksum and hashtag" "$BINARY script-expression --verify-checksum 'sh(pkh($PRV_KEY1))#'"
run_fail_test "sh pkh public key --verify-checksum, no checksum and hashtag" "$BINARY script-expression --verify-checksum 'sh(pkh($PUB_KEY1))#'"
run_fail_test "sh pkh wif --verify-checksum, no checksum and hashtag" "$BINARY script-expression --verify-checksum 'sh(pkh($WIF))#'"

run_fail_test "sh pkh private key --verify-checksum, wrong expression1" "$BINARY script-expression --verify-checksum 's h(pkh($PRV_KEY1))#'"
run_fail_test "sh pkh public key --verify-checksum, wrong expression1" "$BINARY script-expression --verify-checksum 's h(pkh($PUB_KEY1))#'"
run_fail_test "sh pkh wif --verify-checksum, wrong expression1" "$BINARY script-expression --verify-checksum 'sh(pkh($WIF))#'"

run_fail_test "sh pkh private key --verify-checksum, wrong expression2" "$BINARY script-expression --verify-checksum 'sh(pkh($PRV_KEY1))#'"
run_fail_test "sh pkh public key --verify-checksum, wrong expression2" "$BINARY script-expression --verify-checksum 'sh(pkh($PUB_KEY1))#'"
run_fail_test "sh pkh wif --verify-checksum, wrong expression2" "$BINARY script-expression --verify-checksum 'sh(pkh($WIF))#'"

run_fail_test "sh pkh private key --verify-checksum, wrong space padding" "$BINARY script-expression --verify-checksum 'sh(pkh ($PRV_KEY1))'"
run_fail_test "sh pkh public key --verify-checksum, wrong space padding" "$BINARY script-expression --verify-checksum 'sh(pkh ($PUB_KEY1))'"
run_fail_test "sh pkh wif --verify-checksum, wrong space padding" "$BINARY script-expression --verify-checksum 'sh(pkh ($WIF))'"

run_fail_test "sh pkh private key --verify-checksum, unknown pre-fix" "$BINARY script-expression --verify-checksum 'asdsad sh(pkh($PRV_KEY1))'"
run_fail_test "sh pkh public key --verify-checksum, unknown pre-fix" "$BINARY script-expression --verify-checksum 'dasdsa sh(pkh($PUB_KEY1))'"
run_fail_test "sh pkh wif --verify-checksum, unknown pre-fix" "$BINARY script-expression --verify-checksum 'rqwrew sh(pkh($WIF))'"

run_fail_test "sh pkh private key --verify-checksum, another expression pre-fix" "$BINARY script-expression --verify-checksum 'sh(pkh($PRV_KEY1)sh(pkh($PRV_KEY1))'"
run_fail_test "sh pkh public key --verify-checksum, another expression pre-fix" "$BINARY script-expression --verify-checksum 'sh(pkh($PUB_KEY1)sh(pkh($PRV_KEY1))'"
run_fail_test "sh pkh wif --verify-checksum, another expression pre-fix" "$BINARY script-expression --verify-checksum 'sh(pkh($WIF)sh(pkh($PRV_KEY1))'"

run_fail_test "sh pkh private key --verify-checksum, bad argument" "$BINARY script-expression --verify-checksum 'sh(pkh($PRV_KEY1$PRV_KEY1))'"
run_fail_test "sh pkh public key --verify-checksum, bad argument" "$BINARY script-expression --verify-checksum 'sh(pkh($PUB_KEY1$PUB_KEY1))'"
run_fail_test "sh pkh wif --verify-checksum, bad argument" "$BINARY script-expression --verify-checksum 'sh(pkh($WIF$WIF))'"

run_fail_test "sh pkh private key --verify-checksum, multiple parenthesis" "$BINARY script-expression --verify-checksum 'sh(pkh($PRV_KEY1)($PRV_KEY1))'"
run_fail_test "sh pkh public key --verify-checksum, multiple parenthesis" "$BINARY script-expression --verify-checksum 'sh(pkh($PUB_KEY1)($PRV_KEY1))'"
run_fail_test "sh pkh wif --verify-checksum, multiple parenthesis" "$BINARY script-expression --verify-checksum 'sh(pkh($WIF)($PRV_KEY1))'"

run_fail_test "sh pkh private key --verify-checksum, wrong parenthesis" "$BINARY script-expression --verify-checksum 'sh{pkh{$PRV_KEY1}}'"
run_fail_test "sh pkh public key --verify-checksum, wrong parenthesis" "$BINARY script-expression --verify-checksum 'sh{pkh{$PUB_KEY1}}'"
run_fail_test "sh pkh wif --verify-checksum, wrong parenthesis" "$BINARY script-expression --verify-checksum 'sh{pkh{$WIF}}'"

run_fail_test "sh pkh private key --verify-checksum, wrong parenthesis2" "$BINARY script-expression --verify-checksum 'sh[pkh[$PRV_KEY1]]'"
run_fail_test "sh pkh public key --verify-checksum, wrong parenthesis2" "$BINARY script-expression --verify-checksum 'sh[pkh[$PUB_KEY1]]'"
run_fail_test "sh pkh wif --verify-checksum, wrong parenthesis2" "$BINARY script-expression --verify-checksum 'sh[pkh[$WIF]]'"

run_fail_test "sh pkh private key --verify-checksum, script caps-lock" "$BINARY script-expression --verify-checksum 'SH(pkh($PRV_KEY1))'"
run_fail_test "sh pkh public key --verify-checksum, script caps-lock" "$BINARY script-expression --verify-checksum 'SH(pkh($PUB_KEY1))'"
run_fail_test "sh pkh wif --verify-checksum, script caps-lock" "$BINARY script-expression --verify-checksum 'SH(pkh($WIF))'"

run_fail_test "sh pkh private key --verify-checksum, wrong order" "$BINARY script-expression --verify-checksum 'dse8d4mx#sh(pkh($PRV_KEY1))'"
run_fail_test "sh pkh public key --verify-checksum, wrong order" "$BINARY script-expression --verify-checksum 'axav5m01#sh(pkh($PUB_KEY1))'"
run_fail_test "sh pkh wif --verify-checksum, wrong order" "$BINARY script-expression --verify-checksum 'alm7cpqh#sh(pkh($WIF))'"


echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for PKH with --compute-checksum ...${NC}"

run_fail_test "sh pkh private key --compute-checksum, wrong expression1" "$BINARY script-expression --compute-checksum 's h(pkh($PRV_KEY1))#'"
run_fail_test "sh pkh public key --compute-checksum, wrong expression1" "$BINARY script-expression --compute-checksum 's h(pkh($PUB_KEY1))#'"
run_fail_test "sh pkh wif --compute-checksum, wrong expression1" "$BINARY script-expression --compute-checksum 's h(pkh($WIF))#'"

run_fail_test "sh pkh private key --compute-checksum, wrong expression2" "$BINARY script-expression --compute-checksum 'shh(pkh($PRV_KEY1))#'"
run_fail_test "sh pkh public key --compute-checksum, wrong expression2" "$BINARY script-expression --compute-checksum 'shh(pkh($PUB_KEY1))#'"
run_fail_test "sh pkh wif --compute-checksum, wrong expression2" "$BINARY script-expression --compute-checksum 'ssh(pkh($WIF))#'"

run_fail_test "sh pkh private key --compute-checksum, wrong space padding" "$BINARY script-expression --compute-checksum 'sh (pkh($PRV_KEY1))#'"
run_fail_test "sh pkh public key --compute-checksum, wrong space padding" "$BINARY script-expression --compute-checksum 'sh (pkh($PUB_KEY1))#'"
run_fail_test "sh pkh wif --compute-checksum, wrong space padding" "$BINARY script-expression --compute-checksum 'sh (pkh($WIF))#'"

run_fail_test "sh pkh private key --compute-checksum, unknown pre-fix" "$BINARY script-expression --compute-checksum 'asdsad sh(pkh($PRV_KEY1))'"
run_fail_test "sh pkh public key --compute-checksum, unknown pre-fix" "$BINARY script-expression --compute-checksum 'dasdsa sh(pkh($PUB_KEY1))'"
run_fail_test "sh pkh wif --compute-checksum, unknown pre-fix" "$BINARY script-expression --compute-checksum 'rqwrew sh(pkh($WIF))'"

run_fail_test "sh pkh private key --compute-checksum, another expression pre-fix" "$BINARY script-expression --compute-checksum 'sh(pkh($PRV_KEY1)sh(pkh($PRV_KEY1))'"
run_fail_test "sh pkh public key --compute-checksum, another expression pre-fix" "$BINARY script-expression --compute-checksum 'sh(pkh($PUB_KEY1)sh(pkh($PRV_KEY1))'"
run_fail_test "sh pkh wif --compute-checksum, another expression pre-fix" "$BINARY script-expression --compute-checksum 'sh(pkh($WIF)sh(pkh($PRV_KEY1))'"

run_fail_test "sh pkh private key --compute-checksum, bad argument" "$BINARY script-expression --compute-checksum 'sh(pkh($PRV_KEY1$PRV_KEY1))'"
run_fail_test "sh pkh public key --compute-checksum, bad argument" "$BINARY script-expression --compute-checksum 'sh(pkh($PUB_KEY1$PUB_KEY1))'"
run_fail_test "sh pkh wif --compute-checksum, bad argument" "$BINARY script-expression --compute-checksum 'sh(pkh($WIF$WIF))'"

run_fail_test "sh pkh private key --compute-checksum, multiple parenthesis" "$BINARY script-expression --compute-checksum 'sh(pkh($PRV_KEY1)($PRV_KEY1))'"
run_fail_test "sh pkh public key --compute-checksum, multiple parenthesis" "$BINARY script-expression --compute-checksum 'sh(pkh($PUB_KEY1)($PRV_KEY1))'"
run_fail_test "sh pkh wif --compute-checksum, multiple parenthesis" "$BINARY script-expression --compute-checksum 'sh(pkh($WIF)($PRV_KEY1))'"

run_fail_test "sh pkh private key --compute-checksum, wrong parenthesis" "$BINARY script-expression --compute-checksum 'sh{pkh{$PRV_KEY1}}'"
run_fail_test "sh pkh public key --compute-checksum, wrong parenthesis" "$BINARY script-expression --compute-checksum 'sh{pkh{$PUB_KEY1}}'"
run_fail_test "sh pkh wif --compute-checksum, wrong parenthesis" "$BINARY script-expression --compute-checksum 'sh{pkh{$WIF}}'"

run_fail_test "sh pkh private key --compute-checksum, wrong parenthesis2" "$BINARY script-expression --compute-checksum 'sh[pkh[$PRV_KEY1]]'"
run_fail_test "sh pkh public key --compute-checksum, wrong parenthesis2" "$BINARY script-expression --compute-checksum 'sh[pkh[$PUB_KEY1]]'"
run_fail_test "sh pkh wif --compute-checksum, wrong parenthesis2" "$BINARY script-expression --compute-checksum 'sh[pkh[$WIF]]'"

run_fail_test "sh pkh private key --compute-checksum, script caps-lock" "$BINARY script-expression --compute-checksum 'SH(pkh($PRV_KEY1))'"
run_fail_test "sh pkh public key --compute-checksum, script caps-lock" "$BINARY script-expression --compute-checksum 'SH(pkh($PUB_KEY1))'"
run_fail_test "sh pkh wif --compute-checksum, script caps-lock" "$BINARY script-expression --compute-checksum 'SH(pkh($WIF))'"

run_fail_test "sh pkh private key --compute-checksum, wrong order" "$BINARY script-expression --compute-checksum 'dse8d4mx#sh(pkh($PRV_KEY1))'"
run_fail_test "sh pkh public key --compute-checksum, wrong order" "$BINARY script-expression --compute-checksum 'axav5m01#sh(pkh($PUB_KEY1))'"
run_fail_test "sh pkh wif --compute-checksum, wrong order" "$BINARY script-expression --compute-checksum 'alm7cpqh#sh(pkh($WIF))'"

echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for PKH with 2 flags ...${NC}"
run_fail_test "sh pkh both flags presented1" "$BINARY script-expression --verify-checksum --compute-checksum 'sh(pkh($PUB_KEY1))#89f8spxm'"
run_fail_test "sh pkh both flags presented2" "$BINARY script-expression --compute-checksum --verify-checksum 'sh(pkh($PUB_KEY1))#89f8spxm'"


# --- SH MULTI ---
echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for SH MULTI with no flags ..."
run_fail_test "sh multi wrong private key" "$BINARY script-expression 'sh(multi(1, xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8))#dse8d4'"
run_fail_test "sh multi wrong public key" "$BINARY script-expression 'sh(multi(1, xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHsi))#axav5m'"
run_fail_test "sh multi wrong wif" "$BINARY script-expression 'sh(multi(1, [deadbeef/0h/1h/2]5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTsJ))#alm7cp'"

run_fail_test "sh multi wrong k as 0" "$BINARY script-expression 'sh(multi(0, [deadbeef/0h/1h/2]5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTsJ))#alm7cp'"
run_fail_test "sh multi negative k1" "$BINARY script-expression 'sh(multi(-0, [deadbeef/0h/1h/2]5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTsJ))#alm7cp'"
run_fail_test "sh multi negative k2" "$BINARY script-expression 'sh(multi(-1, [deadbeef/0h/1h/2]5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTsJ))#alm7cp'"
run_fail_test "sh multi too big k" "$BINARY script-expression 'sh(multi(2, [deadbeef/0h/1h/2]5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTsJ))#alm7cp'"

run_fail_test "sh multi k wrong order" "$BINARY script-expression 'sh(multi($PUB_KEY1, 1))#alm7cp'"

run_fail_test "sh multi private key, wrong expression1" "$BINARY script-expression 's h(multi(1, $PRV_KEY1))#'"
run_fail_test "sh multi public key, wrong expression1" "$BINARY script-expression 's h(multi(1, $PUB_KEY1))#'"
run_fail_test "sh multi wif, wrong expression1" "$BINARY script-expression 's h(multi(1, $WIF))#'"

run_fail_test "sh multi private key, wrong expression2" "$BINARY script-expression 'ssh(multi(1, $PRV_KEY1))#'"
run_fail_test "sh multi public key, wrong expression2" "$BINARY script-expression 'shh(multi(1, $PUB_KEY1))#'"
run_fail_test "sh multi wif, wrong expression2" "$BINARY script-expression 'ssh(multi(1, $WIF))#'"

run_fail_test "sh multi private key, wrong space padding" "$BINARY script-expression 'sh (multi(1, $PRV_KEY1))#'"
run_fail_test "sh multi public key, wrong space padding" "$BINARY script-expression 'sh (multi(1, $PUB_KEY1))#'"
run_fail_test "sh multi wif, wrong space padding" "$BINARY script-expression 'sh (multi(1, $WIF))#'"

run_fail_test "sh multi private key, unknown pre-fix" "$BINARY script-expression 'asdsad sh(multi($PRV_KEY1))#'"
run_fail_test "sh multi public key, unknown pre-fix" "$BINARY script-expression 'dasdsa sh(multi($PUB_KEY1))#'"
run_fail_test "sh multi wif, unknown pre-fix" "$BINARY script-expression 'rqwrew sh(multi($WIF))#'"

run_fail_test "sh multi private key, another expression pre-fix" "$BINARY script-expression 'sh(multi(1, $PRV_KEY1)sh(multi(1, $PRV_KEY1))'"
run_fail_test "sh multi public key, another expression pre-fix" "$BINARY script-expression 'sh(multi(1, $PUB_KEY1)sh(multi(1, $PRV_KEY1))'"
run_fail_test "sh multi wif, another expression pre-fix" "$BINARY script-expression 'sh(multi(1, $WIF)sh(multi(1, $PRV_KEY1))'"

run_fail_test "sh multi private key, bad argument" "$BINARY script-expression 'sh(multi(1, $PRV_KEY1$PRV_KEY1))'"
run_fail_test "sh multi public key, bad argument" "$BINARY script-expression 'sh(multi(1, $PUB_KEY1$PUB_KEY1))'"
run_fail_test "sh multi wif, bad argument" "$BINARY script-expression 'sh(multi(1, $WIF$WIF))'"

run_fail_test "sh multi private key, multiple parenthesis" "$BINARY script-expression 'sh(multi(1, $PRV_KEY1)($PRV_KEY1))'"
run_fail_test "sh multi public key, multiple parenthesis" "$BINARY script-expression 'sh(multi(1, $PUB_KEY1)($PRV_KEY1))'"
run_fail_test "sh multi wif, multiple parenthesis" "$BINARY script-expression 'sh(multi(1, $WIF)($PRV_KEY1))'"

run_fail_test "sh multi private key, wrong parenthesis" "$BINARY script-expression 'sh{multi{1, $PRV_KEY1}}'"
run_fail_test "sh multi public key, wrong parenthesis" "$BINARY script-expression 'sh{multi{1, $PUB_KEY1}}'"
run_fail_test "sh multi wif, wrong parenthesis" "$BINARY script-expression 'sh{multi{1, $WIF}}'"

run_fail_test "sh multi private key, wrong parenthesis2" "$BINARY script-expression 'sh[multi[1, $PRV_KEY1]]'"
run_fail_test "sh multi public key, wrong parenthesis2" "$BINARY script-expression 'sh[multi[1, $PUB_KEY1]]'"
run_fail_test "sh multi wif, wrong parenthesis2" "$BINARY script-expression 'sh[multi[1, $WIF]]'"

run_fail_test "sh multi private key, script caps-lock" "$BINARY script-expression 'SH(MULTI(1, $PRV_KEY1))'"
run_fail_test "sh multi public key, script caps-lock" "$BINARY script-expression 'SH(MULTI(1, $PUB_KEY1))'"
run_fail_test "sh multi wif, script caps-lock" "$BINARY script-expression 'SH(MULTI(1, $WIF))'"

run_fail_test "sh multi private key, wrong order" "$BINARY script-expression 'dse8d4mx#sh(multi(1, $PRV_KEY1))'"
run_fail_test "sh multi public key, wrong order" "$BINARY script-expression 'axav5m01#sh(multi(1, $PUB_KEY1))'"
run_fail_test "sh multi wif, wrong order" "$BINARY script-expression 'alm7cpqh#sh(multi(1, $WIF))'"


echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for SH MULTI with --verify-checksum ...${NC}"
run_fail_test "sh multi private key --verify-checksum, checksum wrong length" "$BINARY script-expression --verify-checksum 'sh(multi(1, $PRV_KEY1))#dse8d4'"
run_fail_test "sh multi public key --verify-checksum, wrong length" "$BINARY script-expression --verify-checksum 'sh(multi(1, $PUB_KEY1))#axav5m'"
run_fail_test "sh multi wif --verify-checksum, checksum wrong length" "$BINARY script-expression --verify-checksum 'sh(multi(1, $WIF))#alm7cp'"

run_fail_test "sh multi private key --verify-checksum, no checksum and hashtag" "$BINARY script-expression --verify-checksum 'sh(multi(1, $PRV_KEY1))#'"
run_fail_test "sh multi public key --verify-checksum, no checksum and hashtag" "$BINARY script-expression --verify-checksum 'sh(multi(1, $PUB_KEY1))#'"
run_fail_test "sh multi wif --verify-checksum, no checksum and hashtag" "$BINARY script-expression --verify-checksum 'sh(multi(1, $WIF))#'"

run_fail_test "sh multi private key --verify-checksum, wrong expression1" "$BINARY script-expression --verify-checksum 's h(multi($PRV_KEY1))#'"
run_fail_test "sh multi public key --verify-checksum, wrong expression1" "$BINARY script-expression --verify-checksum 's h(multi($PUB_KEY1))#'"
run_fail_test "sh multi wif --verify-checksum, wrong expression1" "$BINARY script-expression --verify-checksum 's h(multti($WIF))#'"

run_fail_test "sh multi private key --verify-checksum, wrong expression2" "$BINARY script-expression --verify-checksum 'ssh(multi($PRV_KEY1))#'"
run_fail_test "sh multi public key --verify-checksum, wrong expression2" "$BINARY script-expression --verify-checksum 'shh(multi($PUB_KEY1))#'"
run_fail_test "sh multi wif --verify-checksum, wrong expression2" "$BINARY script-expression --verify-checksum 'ssh(multi($WIF))#'"

run_fail_test "sh multi private key --verify-checksum, wrong space padding" "$BINARY script-expression --verify-checksum 'sh (multi($PRV_KEY1))#'"
run_fail_test "sh multi public key --verify-checksum, wrong space padding" "$BINARY script-expression --verify-checksum 'sh (multi($PUB_KEY1))#'"
run_fail_test "sh multi wif --verify-checksum, wrong space padding" "$BINARY script-expression --verify-checksum 'sh (multi($WIF))#'"

run_fail_test "sh multi private key --verify-checksum, unknown pre-fix" "$BINARY script-expression --verify-checksum 'asdsad sh(multi(1, $PRV_KEY1))#'"
run_fail_test "sh multi public key --verify-checksum, unknown pre-fix" "$BINARY script-expression --verify-checksum 'dasdsa sh(multi(1, $PUB_KEY1))#'"
run_fail_test "sh multi wif --verify-checksum, unknown pre-fix" "$BINARY script-expression --verify-checksum 'rqwrew sh(multi(1, $WIF))#'"

run_fail_test "sh multi private key --verify-checksum, another expression pre-fix" "$BINARY script-expression --verify-checksum 'sh(multi(1, $PRV_KEY1)sh(multi(1, $PRV_KEY1))'"
run_fail_test "sh multi public key --verify-checksum, another expression pre-fix" "$BINARY script-expression --verify-checksum 'sh(multi(1, $PUB_KEY1)sh(multi(1, $PRV_KEY1))'"
run_fail_test "sh multi wif --verify-checksum, another expression pre-fix" "$BINARY script-expression --verify-checksum 'sh(multi(1, $WIF)sh(multi(1, $PRV_KEY1))'"

run_fail_test "sh multi private key --verify-checksum, bad argument" "$BINARY script-expression --verify-checksum 'sh(multi(1, $PRV_KEY1$PRV_KEY1))'"
run_fail_test "sh multi public key --verify-checksum, bad argument" "$BINARY script-expression --verify-checksum 'sh(multi(1, $PUB_KEY1$PUB_KEY1))'"
run_fail_test "sh multi wif --verify-checksum, bad argument" "$BINARY script-expression --verify-checksum 'sh(multi(1, $WIF$WIF))'"

run_fail_test "sh multi private key --verify-checksum, multiple parenthesis" "$BINARY script-expression --verify-checksum 'sh(multi(1, $PRV_KEY1)($PRV_KEY1))'"
run_fail_test "sh multi public key --verify-checksum, multiple parenthesis" "$BINARY script-expression --verify-checksum 'sh(multi(1, $PUB_KEY1)($PRV_KEY1))'"
run_fail_test "sh multi wif --verify-checksum, multiple parenthesis" "$BINARY script-expression --verify-checksum 'sh(multi(1, $WIF)($PRV_KEY1))'"

run_fail_test "sh multi private key --verify-checksum, wrong parenthesis" "$BINARY script-expression --verify-checksum 'sh{multi{1, $PRV_KEY1}}'"
run_fail_test "sh multi public key --verify-checksum, wrong parenthesis" "$BINARY script-expression --verify-checksum 'sh{multi{1, $PUB_KEY1}}'"
run_fail_test "sh multi wif --verify-checksum, wrong parenthesis" "$BINARY script-expression --verify-checksum 'sh{multi{1, $WIF}}'"

run_fail_test "sh multi private key --verify-checksum, wrong parenthesis2" "$BINARY script-expression --verify-checksum 'sh[multi[1, $PRV_KEY1]]'"
run_fail_test "sh multi public key --verify-checksum, wrong parenthesis2" "$BINARY script-expression --verify-checksum 'sh[multi[1, $PUB_KEY1]]'"
run_fail_test "sh multi wif --verify-checksum, wrong parenthesis2" "$BINARY script-expression --verify-checksum 'sh[multi[1, $WIF]]'"

run_fail_test "sh multi private key --verify-checksum, script caps-lock" "$BINARY script-expression --verify-checksum 'SH(MULTI(1, $PRV_KEY1))'"
run_fail_test "sh multi public key --verify-checksum, script caps-lock" "$BINARY script-expression --verify-checksum 'SH(MULTI(1, $PUB_KEY1))'"
run_fail_test "sh multi wif --verify-checksum, script caps-lock" "$BINARY script-expression --verify-checksum 'SH(MULTI(1, $WIF))'"

run_fail_test "sh multi private key --verify-checksum, wrong order" "$BINARY script-expression --verify-checksum 'dse8d4mx#sh(multi(1, $PRV_KEY1))'"
run_fail_test "sh multi public key --verify-checksum, wrong order" "$BINARY script-expression --verify-checksum 'axav5m01#sh(multi(1, $PUB_KEY1))'"
run_fail_test "sh multi wif --verify-checksum, wrong order" "$BINARY script-expression --verify-checksum 'alm7cpqh#sh(multi(1, $WIF))'"


echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for MULTI with --compute-checksum ...${NC}"

run_fail_test "sh multi private key --compute-checksum, wrong expression1" "$BINARY script-expression --compute-checksum 's h(multi($PRV_KEY1))#'"
run_fail_test "sh multi public key --compute-checksum, wrong expression1" "$BINARY script-expression --compute-checksum 's h(multti($PUB_KEY1))#'"
run_fail_test "sh multi wif --compute-checksum, wrong expression1" "$BINARY script-expression --compute-checksum 's h(multi($WIF))#'"

run_fail_test "sh multi private key --compute-checksum, wrong expression2" "$BINARY script-expression --compute-checksum 'shh(multi($PRV_KEY1))#'"
run_fail_test "sh multi public key --compute-checksum, wrong expression2" "$BINARY script-expression --compute-checksum 'ssh(multi($PUB_KEY1))#'"
run_fail_test "sh multi wif --compute-checksum, wrong expression2" "$BINARY script-expression --compute-checksum 'ssh(multi($WIF))#'"

run_fail_test "sh multi private key --compute-checksum, wrong space padding" "$BINARY script-expression --compute-checksum 'sh (multi($PRV_KEY1))#'"
run_fail_test "sh multi public key --compute-checksum, wrong space padding" "$BINARY script-expression --compute-checksum 'sh (multi($PUB_KEY1))#'"
run_fail_test "sh multi wif --compute-checksum, wrong space padding" "$BINARY script-expression --compute-checksum 'sh (multi($WIF))#'"

run_fail_test "sh multi private key --compute-checksum, unknown pre-fix" "$BINARY script-expression --compute-checksum 'asdsad sh(multi(1, $PRV_KEY1))#'"
run_fail_test "sh multi public key --compute-checksum, unknown pre-fix" "$BINARY script-expression --compute-checksum 'dasdsa sh(multi(1, $PUB_KEY1))#'"
run_fail_test "sh multi wif --compute-checksum, unknown pre-fix" "$BINARY script-expression --compute-checksum 'rqwrew sh(multi(1, $WIF))#'"

run_fail_test "sh multi private key --compute-checksum, another expression pre-fix" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PRV_KEY1)sh(multi(1, $PRV_KEY1))'"
run_fail_test "sh multi public key --compute-checksum, another expression pre-fix" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PUB_KEY1)sh(multi(1, $PRV_KEY1))'"
run_fail_test "sh multi wif --compute-checksum, another expression pre-fix" "$BINARY script-expression --compute-checksum 'sh(multi(1, $WIF)sh(multi(1, $PRV_KEY1))'"

run_fail_test "sh multi private key --compute-checksum, bad argument" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PRV_KEY1$PRV_KEY1))'"
run_fail_test "sh multi public key --compute-checksum, bad argument" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PUB_KEY1$PUB_KEY1))'"
run_fail_test "sh multi wif --compute-checksum, bad argument" "$BINARY script-expression --compute-checksum 'sh(multi(1, $WIF$WIF))'"

run_fail_test "sh multi private key --compute-checksum, multiple parenthesis" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PRV_KEY1)($PRV_KEY1))'"
run_fail_test "sh multi public key --compute-checksum, multiple parenthesis" "$BINARY script-expression --compute-checksum 'sh(multi(1, $PUB_KEY1)($PRV_KEY1))'"
run_fail_test "sh multi wif --compute-checksum, multiple parenthesis" "$BINARY script-expression --compute-checksum 'sh(multi(1, $WIF)($PRV_KEY1))'"

run_fail_test "sh multi private key --compute-checksum, wrong parenthesis" "$BINARY script-expression --compute-checksum 'sh{multi{1, $PRV_KEY1}}'"
run_fail_test "sh multi public key --compute-checksum, wrong parenthesis" "$BINARY script-expression --compute-checksum 'sh{multi{1, $PUB_KEY1}}'"
run_fail_test "sh multi wif --compute-checksum, wrong parenthesis" "$BINARY script-expression --compute-checksum 'sh{multi{1, $WIF}}'"

run_fail_test "sh multi private key --compute-checksum, wrong parenthesis2" "$BINARY script-expression --compute-checksum 'sh[multi[1, $PRV_KEY1]]'"
run_fail_test "sh multi public key --compute-checksum, wrong parenthesis2" "$BINARY script-expression --compute-checksum 'sh[multi[1, $PUB_KEY1]]'"
run_fail_test "sh multi wif --compute-checksum, wrong parenthesis2" "$BINARY script-expression --compute-checksum 'sh[multi[1, $WIF]]'"

run_fail_test "sh multi private key --compute-checksum, script caps-lock" "$BINARY script-expression --compute-checksum 'SH(MULTI(1, $PRV_KEY1))'"
run_fail_test "sh multi public key --compute-checksum, script caps-lock" "$BINARY script-expression --compute-checksum 'SH(MULTI(1, $PUB_KEY1))'"
run_fail_test "sh multi wif --compute-checksum, script caps-lock" "$BINARY script-expression --compute-checksum 'SH(MULTI(1, $WIF))'"

run_fail_test "sh multi private key --compute-checksum, wrong order" "$BINARY script-expression --compute-checksum 'dse8d4mx#sh(multi(1, $PRV_KEY1))'"
run_fail_test "sh multi public key --compute-checksum, wrong order" "$BINARY script-expression --compute-checksum 'axav5m01#sh(multi(1, $PUB_KEY1))'"
run_fail_test "sh multi wif --compute-checksum, wrong order" "$BINARY script-expression --compute-checksum 'alm7cpqh#sh(multi(1, $WIF))'"

echo -e "\n${GREEN}✔ [SCRIPT-EXPRESSION] Running tests that are expected to fail for MULTI with 2 flags ...${NC}"
run_fail_test "sh multi both flags presented1" "$BINARY script-expression --verify-checksum --compute-checksum 'sh(multi(1, $PUB_KEY1))#89f8spxm'"
run_fail_test "sh multi both flags presented2" "$BINARY script-expression --compute-checksum --verify-checksum 'sh(multi(1, $PUB_KEY1))#89f8spxm'"



# In case we found some test fails, exit with 1
if [[ $FAILED_TESTS -ne 0 ]]; then
    exit 1
fi
