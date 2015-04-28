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
# $1 1° file to compare
# $2 2° file to compare
#
# This script returns:
# OK if files match
# PRESENTATION ERROR if files match if case is ignored and all white spaces are discarded
# WRONG ANSWER if files don't match
#
# Given 2 files, check if they match

# Check parameters
if [ ! -r "$1" -a ! -r "$2" ]; then
  echo "Parameter problem" >&2
  exit -1
fi

# Compare files
diff -q -N $1 $2 &> /dev/null
if [[ $? == 0 ]]; then
    echo -e "\e[1;32mOK\e[0m"
    exit 0
fi

# Compare files discarding presentation
diff -q -i -b -B -w -E -Z -N $1 $2 &> /dev/null
if [[ $? == 0 ]]; then
    echo -e "\e[1;34mPRESENTATION ERROR\e[0m"
    exit 1
fi

# Further checking
file1=$(cat $1 2> /dev/null | tr --delete '[:space:]')
file2=$(cat $2 2> /dev/null | tr --delete '[:space:]')
diff -q -i <(echo $file1) <(echo $file2) &> /dev/null
if [[ $? == 0 ]]; then
    echo -e "\e[1;34mPRESENTATION ERROR\e[0m"
    exit 1
fi

# Else, files are different
echo -e "\e[1;31mWRONG ANSWER\e[0m"
exit 2
