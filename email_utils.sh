#!/bin/bash
if [ "$1" != "verbose" ]; then
  exec > /dev/null 2>&1 
fi

mypath=`dirname "$0"`
date_now=`date +%D`
filename_month="`date --date='next month' +%b`"

to_addr_1="john@johngorosz.com, ebay@johngorosz.com"
to_addr_2="chief@johngorosz.com, buy@johngorosz.com"
from_addr="chief@johngorosz.com"
subject="${filename_month} rent"

unit_1_file="$mypath/${filename_month}_1.txt"
unit_2_file="$mypath/${filename_month}_2.txt"

cmd_1="mail -s \"${subject}\" ${to_addr_1} < ${unit_1_file}"
cmd_2="mail -s \"${subject}\" ${to_addr_2} < ${unit_2_file}"


if [ -e ${unit_1_file} ]; then
  echo $cmd_1
  eval "$cmd_1"
fi

if [ -e ${unit_2_file} ]; then
  echo $cmd_2
  eval "$cmd_2"
fi
