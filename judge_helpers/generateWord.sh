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
# $1 Function
# $2 Dictionary
#
# Given 1 dictionary, return the first/last/random word in it

# Check if function name is valid
if [ "$1" != "firstWord" -a "$1" != "lastWord" -a "$1" != "randomWord" ]; then
    echo "Invalid function name $1" >&2
    exit 1
fi

# Check if dictionary file is valid
if [ -z "$2" -o ! -f "$2" -o ! -r "$2" ]; then
    echo "Problem loading dictionary $2" >&2
    exit 1
fi

function firstWord() {
    # Get the first line of dictionary
    nth_line=$(head -n 1 $1)
}

function lastWord() {
    # Get the last line of dictionary
    nth_line=$(tail -n 1 $1)
}

function randomWord() {
    # Get number of files in dictionary
    RANGE=$(wc -l < $1)

    # Assert positive range
    if [[ $RANGE > 0 ]]; then 
        # Generate random number
        x=$RANDOM

        # Assert random number in range
        let "x %= ${RANGE}"
        let "x += 1"

        # Get the X° line of dictionary
        nth_line=$(awk -v x=$x 'NR==x{print;exit}' $1)
    else
        nth_line="dictionaryempty"
    fi
}

# Exec Function
$@

# Filter word definition
word=$(echo $nth_line | cut -f1 -d:)

# Return word
echo $word
