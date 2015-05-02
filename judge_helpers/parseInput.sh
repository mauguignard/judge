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
# $1 Input File
# $2 Dictionary to load
# $3 Dictionary to dump
#
# Given 1 input file, parse it, and return result
#
# Available commands:
# load_dictionary = Dictionary file name to load
# dump_dictionary = Dictionary file name to dump
# first_word = First word in dictionary to load
# last_word = Last word in dictionary to load
# random_word = Generate random word from dictionary to load


# Create alias for generateWord
shopt -s expand_aliases
alias generateWord='./judge_helpers/generateWord.sh'

# Check existance of quit command in last line of input file
lastline=$(tail -n 1 $1)
if [[ $lastline != "q" ]]; then
    echo -e "q\nq\nq" >> $1
fi

# Remove comments and load input file
inputfile=$(grep -ve '^\s*\#' $1)

# Parse load_dictionary
inputfile=$(printf "%s\n" "$inputfile" | awk -v dictionary_to_load=$2 '{ gsub("load_dictionary", dictionary_to_load); print }')

# Parse dump_dictionary
inputfile=$(printf "%s\n" "$inputfile" | awk -v dictionary_to_dump=$3 '{ gsub("dump_dictionary", dictionary_to_dump); print }')

# Parse first_word
word=$(generateWord firstWord $2 2> /dev/null)
if [ $? != 0 ]; then
    word="error"
fi
inputfile=$(printf "%s\n" "$inputfile" | awk -v word=$word '{ gsub("first_word", word); print }')
 
# Parse last_word
word=$(generateWord lastWord $2 2> /dev/null)
if [ $? != 0 ]; then
    word="error"
fi
inputfile=$(printf "%s\n" "$inputfile" | awk -v word=$word '{ gsub("last_word", word); print }')

# Parse random_word
while [[ $inputfile == *"random_word"* ]]; do
    word=$(generateWord randomWord $2 2> /dev/null)
    if [ $? != 0 ]; then
        word="error"
    fi
    inputfile=${inputfile/"random_word"/$word}
done

# Return parsed input file
printf "%s\n" "$inputfile"
