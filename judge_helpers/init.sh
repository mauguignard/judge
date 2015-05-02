#!/bin/bash
# ///////////////////////////////////////////////////////////////////////////////////////////////////////
# // Auto-Judge v1.3
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
# $1 Trusted Application
# $2 Application to check

USAGE="USAGE: ./judge.sh [-ord | --ordered] [-T=TRUSTED_APP | --trusted=TRUSTED_APP]\n
       \t[-t=TESTNUM | --test=TESTNUM] [-f=FILE | --file=FILE] TO_CHECK_APP"
# Check if there are no parameters
if [ "$1" == "" -a "$2" == "" ]; then
    echo -e $USAGE
    exit 1
fi

# Check if parameters are correct
if [ "$1" == "" -o "$2" == "" ]; then
    echo -e $USAGE
    echo "This judge needs 1 parameters to work"
    exit 1
fi

# CHECK function
function check() {
    if [ ! -f "$1" ]; then
        echo "$1 not found" >&2
        exit 1
    elif [ ! -r "$1" ]; then
        echo "You don't have permission to read $1" >&2
        exit 1
    elif [ ! -x "$1" ]; then
        chmod +x $1
        if [[ $? != 0 ]]; then
            echo "Error trying to make executable $1" >&2
            exit 1
        fi
    fi
}

# Check the parameters
check $1
check $2

# Check Judge Helpers
check "judge_helpers/checkValgrind.sh"
check "judge_helpers/compare.sh"
check "judge_helpers/parseInput.sh"
check "judge_helpers/generateWord.sh"

# Check if Valgrind is installed
hash valgrind &> /dev/null
if [ $? != 0 ]; then
    echo "Valgrind it's not installed. Please install it before running this judge" >&2
    exit 1
fi
