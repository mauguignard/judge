#!/bin/bash
# ///////////////////////////////////////////////////////////////////////////////////////////////////////
# // Auto-Judge v1.2.2
# //    Feel free to read this code and modify it as you please
# //    Please report any mistakes/bugs/errors found in this code
# //
# //    Copyright (C) 2015 by Mauricio Guignard (mauguignard@gmail.com)
# //
# //    This program is free software: you can redistribute it and/or modify
# //    it under the terms of the GNU General Public License as published by
# //    the Free Software Foundation, either version 3 of the License, or
# //    (at your option) any later version.
# //
# //    This program is distributed in the hope that it will be useful,
# //    but WITHOUT ANY WARRANTY; without even the implied warranty of
# //    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# //    GNU General Public License for more details.
# //    You should have received a copy of the GNU General Public License
# //    along with this program.  If not, see <http://www.gnu.org/licenses/>.
# //
# //    DISCLAIMER:
# //        This judge is for learning purposes only.
# //        The user should ALWAYS run the application manually to ensure that it works properly.
# //
# ///////////////////////////////////////////////////////////////////////////////////////////////////////
#
# This script receives:
# $1 Application to check

# Customizable variables

    # Time Limit
    MAX_TIME="45s"

    # Maximum Output Size in bytes (Default 10MB)
    MAX_OUTPUT_SIZE=10000000

    # Application Output files
    TRUSTED_OUTPUT="TRUSTED_OUTPUT.txt"
    TO_CHECK_OUTPUT="TO_CHECK_OUTPUT.txt"

    # Application dictionary dump files
    TRUSTED_DUMP="trusted_dic.dic"
    TO_CHECK_DUMP="to_check_dic.dic"

    #Valgrind log file
    VALGRIND_LOG="VALGRIND_LOG.txt"

# Parse command line arguments
case $1 in
    -h | --help)
        help_file="judge_helpers/help.txt"
        if [ -f "$help_file" -a -r "$help_file" ]; then
            cat $help_file
            exit 0
        else
            echo "Error loading Help ($help_file)"
            exit 1
        fi
    ;;

    -v | --version)
        echo "Auto-Judge Version 1.2.2"
        exit 0
    ;;
esac

while test $# -gt 0; do
    case $1 in
        -t=* | --test=*)
            test_counter=$(echo $1 | cut -f2 -d=)
            test_case="tests/test${test_counter}.txt"
            test_defined="TRUE"
            if [ ! -f "$test_case" ]; then
                echo "$test_case does not exist." >&2
                exit 1
            elif [ ! -r "$test_case" ]; then
                echo "You don't have permission to read $test_case" >&2
                exit 1
            fi
        ;;

        -f=* | --file=*)
            file=$(echo $1 | cut -f2 -d=)
            file=$(echo "input/$file")
            file_defined="TRUE"
        ;;

        -*)
            echo "Invalid argument $1"
            exit 1
        ;;

        *)
            break
        ;;
        esac
        shift
done

# Check init.sh helper
inithelper="judge_helpers/init.sh"
if [ ! -f "$inithelper" ]; then
    echo "Init Helper ($inithelper) not found" >&2
    exit 1
elif [ ! -r "$inithelper" ]; then
    echo "You don't have permission to read Init Helper ($inithelper)" >&2
    exit 1
elif [ ! -x "$inithelper" ]; then
    exec=$(chmod +x $inithelper)
    if [ $? != 0 ]; then
        echo "Error trying to make executable Init Helper ($inithelper)" >&2
        exit 1
    fi
fi

# Check the CPU architecture and select proper TRUSTED_APP
if [ `getconf LONG_BIT` = "64" ]; then
    trustedapp="original_amd64"
else
    trustedapp="original_i386"
fi

# Load init.sh helper. On error, exit
./judge_helpers/init.sh $trustedapp $1 || exit 1

# Create alias for helpers
shopt -s expand_aliases
alias checkValgrind='./judge_helpers/checkValgrind.sh'
alias compare='./judge_helpers/compare.sh'
alias parseInput='./judge_helpers/parseInput.sh'


# Check if there are test cases to check
if [ ! -f "tests/test1.txt" -o ! -r "tests/test1.txt" -a ! -n "$test_defined" ]; then
    echo "Test folder is empty. There are no test cases to check"
    exit 0
fi

# Check if input folder is empty
if ! test "$(ls -A input/*.dic 2>/dev/null)"; then
    empty_input_folder="TRUE"
fi

# Abbreviate execution commands
function run_trusted () {
    printf "%s\n" "$1" | timeout $MAX_TIME ./$2 | head -c $MAX_OUTPUT_SIZE > $3
    exitcode=${PIPESTATUS[1]}
}
function run_to_check() {
    printf "%s\n" "$1" | timeout $MAX_TIME valgrind --leak-check=full --show-reachable=yes --log-file=$VALGRIND_LOG ./$2 | head -c $MAX_OUTPUT_SIZE > $3
    exitcode=${PIPESTATUS[1]}
}

# ERROR checker
function checkError() {
    if [ $1 == 0 ]; then
        echo -e "\e[1;32mOK\e[0m"
    elif [ $1 == 124 ]; then
        echo -e "\e[1;31mTIME LIMIT EXCEEDED\e[0m"
    else
        echo -e "\e[1;31mERROR\e[0m"
    fi
}

# JUDGE function
function judge() {
    # Parse input file
    echo -ne "${3}Parsing input file... "
    input=$(parseInput "$test_case" "${file}" "temp_dump" 2> /dev/null)
    checkError $?

    # Execute trusted application
    echo -ne "${3}Executing ./$1... "
    run_trusted "$input" $1 $TRUSTED_OUTPUT
    checkError $exitcode
    mv temp_dump $TRUSTED_DUMP &> /dev/null

    # Execute application to check
    echo -ne "${3}Executing ./$2... "
    run_to_check "$input" $2 $TO_CHECK_OUTPUT
    checkError $exitcode
    mv temp_dump $TO_CHECK_DUMP &> /dev/null

    if [[ $exitcode == 0 ]]; then
        # Compare outputs
        echo -ne "${3}Comparing outputs... "
        compare $TRUSTED_OUTPUT $TO_CHECK_OUTPUT

        # Compare dumped dictionaries
        if [ -f "$TRUSTED_DUMP" -o -f "$TO_CHECK_DUMP" ]; then
            echo -ne "${3}Comparing dumped dictionaries... "
            compare $TRUSTED_DUMP $TO_CHECK_DUMP
        fi

        # Check memory leaks
        echo -ne "${3}Checking memory leaks... "
        checkValgrind checkMemLeaks $VALGRIND_LOG

        # Check memory errors
        echo -ne "${3}Checking memory errors... "
        checkValgrind checkMemErrors $VALGRIND_LOG
    fi

    echo
}

if [[ $test_defined != "TRUE" ]]; then
    test_counter=1
    test_case="tests/test1.txt"
fi

# Make sure there are no temporary files created before running the Judge
if [ -f $TRUSTED_OUTPUT ]; then rm $TRUSTED_OUTPUT; fi
if [ -f $TO_CHECK_OUTPUT ]; then rm $TO_CHECK_OUTPUT; fi
if [ -f $TRUSTED_DUMP ]; then rm $TRUSTED_DUMP; fi
if [ -f $TO_CHECK_DUMP ]; then rm $TO_CHECK_DUMP; fi
if [ -f $VALGRIND_LOG ]; then rm $VALGRIND_LOG; fi

# JUDGE
while [ -f "$test_case" -a -r "$test_case" ]; do
    echo "Test $test_counter"
    if [[ $(head -n 1 $test_case) == "#!File Dependant" ]]; then
        # Check if there are dictionaries to check
        if [[ $empty_input_folder == "TRUE" ]]; then
            echo -e "\tInput folder is empty. There are no dictionaries to check"
            echo
        else
            if [[ $file_defined == "TRUE" ]]; then
                echo -e "\tFile: ${file}"
                judge $trustedapp $1 "\t\t" 
            else
                # Run test case for every dictionary
                for file in input/*.dic; do
                    echo -e "\tFile: ${file}"
                    judge $trustedapp $1 "\t\t" 
                done
            fi
        fi
    else
        judge $trustedapp $1 "\t"
    fi
    if [[ $test_defined == "TRUE" ]]; then
        break
    fi
    let "test_counter += 1"
    test_case="tests/test$test_counter.txt"
done

# Show DISCLAIMER
bold=`tput bold`
normal=`tput sgr0`
echo -e "${bold}DISCLAIMER:${normal}
This Judge is for learning purposes only. It's no perfect.
As much it can be as good as the test cases that you are using.
The user should ALWAYS run the app manually to ensure that it works properly."

# If test number is defined by user, ask if temporary files should be removed
if [[ $test_defined == "TRUE" ]]; then
    echo
    while [[ $OPTION != "y" && $OPTION != "n" ]]; do
        echo -n "Remove temporary files? [y/n] "
        read OPTION
        OPTION=$(echo $OPTION | tr '[:upper:]' '[:lower:]')
    done
    if [[ $OPTION == "n" ]]; then
        # Remove all non-printable ASCII characters from outputs
        cat $TRUSTED_OUTPUT | tr -cd '\11\12\40-\176' > temp_output
        mv temp_output $TRUSTED_OUTPUT
        cat $TO_CHECK_OUTPUT | tr -cd '\11\12\40-\176' > temp_output
        mv temp_output $TO_CHECK_OUTPUT
        exit 0
    fi
fi
# Remove temporary files
rm $TRUSTED_OUTPUT
rm $TO_CHECK_OUTPUT
if [ -f $TRUSTED_DUMP ]; then rm $TRUSTED_DUMP; fi
if [ -f $TO_CHECK_DUMP ]; then rm $TO_CHECK_DUMP; fi
rm $VALGRIND_LOG
