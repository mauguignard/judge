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
# $2 Valgrind log file
#
# Given log file, check if memory errors/leaks exist

# Check if function name is valid
if [ "$1" != "checkMemLeaks" -a "$1" != "checkMemErrors" ]; then
    echo "Invalid function name $1" >&2
    exit 1
fi

# Check if Valgrind log exists
if [ ! -r "$2" ]; then
  echo "Error opening $2" >&2
  exit -1
fi

function checkMemLeaks() {
    totalheapusage=$(cat $1 | grep -oe "total heap usage: [0-9]\+ allocs, [0-9]\+ frees")
    allocs=$(echo $totalheapusage | grep -oe "[0-9]\+ allocs" | grep -oe "[0-9]\+")
    frees=$(echo $totalheapusage | grep -oe "[0-9]\+ frees" | grep -oe "[0-9]\+")
    let "memleaks = allocs - frees"
    if [ $memleaks == 0 ]; then
        echo -e "\e[1;32mOK. No memory leaks were found\e[0m"
        exit 0
    elif [ $memleaks == 1 ]; then
        echo -e "\e[1;31mWRONG ANSWER. 1 memory leaks was found\e[0m"
        exit 1
    else
        echo -e "\e[1;31mWRONG ANSWER. $errors memory leaks were found\e[0m"
        exit 1
    fi
}

function checkMemErrors() {
    errors=$(tail -n 1 $1 | grep -oe "[0-9]\+ errors" | grep -oe "[0-9]\+")
    if [ $errors == 0 ]; then
        echo -e "\e[1;32mOK. No memory errors were found\e[0m"
        exit 0
    elif [ $errors == 1 ]; then
        echo -e "\e[1;31mWRONG ANSWER. 1 memory error was found\e[0m"
        exit 1
    else
        echo -e "\e[1;31mWRONG ANSWER. $errors memory errors were found\e[0m"
        exit 1
    fi
}

# Exec function
$@
