#!/bin/bash
if [ "$1" != "verbose" ]; then
  exec > /dev/null 2>&1 
fi

# ------------------------------ #
# ------------------------------ #
# configuration values

mypath=`dirname "$0"`

DEBUG="$mypath/.util_parse"
date > $DEBUG

gas_2_num="12059710165"
elec_1_num="20400221048"
gas_1_num="12059700133"
elec_2_num="20400211098"
elec_3_num="29128390019"


date_now=`date +%m/%Y`
filename_month="`date --date='next month' +%b`"
month_year="`date --date='next month' +%m/%Y`"

#filename=test.txt
filename="$mypath/${filename_month}.txt"
tempfile="$mypath/temp"
emailfile="$mypath/${filename_month}_email"

unit_1_file="$mypath/unit_1_${filename_month}.txt"
unit_2_file="$mypath/unit_2_${filename_month}.txt"

murdock_utils="$mypath/murdock.csv"

echo "checking primer" >> $DEBUG

# add primer line if necessary
if ! grep -q "${date_now}" $murdock_utils; then
	printf "${date_now},electric_1,kw_1,gas_1,therm_1," >> $murdock_utils
	printf "electric_2,kw_2,gas_2,therm_2,electric_3,kw_3\n" >> $murdock_utils
fi

# ------------------------------ #
# ------------------------------ #

printf "0=%s\n" $0
printf "mypath=%s\n" $mypath

util_files='electric_1 gas_1 electric_2 gas_2 electric_3'

########################################################
# parse each file

let count=0

# ----------------------------- #
# parse each line for price and account number
let index=0
export price=0
price_str=""
export unit=0
export bill_type=""

echo "loop through files" >> $DEBUG

pushd $mypath

for file in $util_files; do
  echo "file $file" >> $DEBUG
  echo "file $file"
	if [ ! -e $file ]; then
		echo "ERROR: could not find file $file"
    echo "ERROR: could not find file $file" >> $DEBUG
		continue
	fi

	if grep -q "$gas_1_num" $file; then
	export unit=1
	export bill_type="gas"
	elif grep -q "$elec_1_num" $file; then
	export unit=1
	export bill_type="electric"
	elif grep -q "$gas_2_num" $file; then
	export unit=2
	export bill_type="gas"
	elif grep -q "$elec_2_num" $file; then
	export unit=2
	export bill_type="electric"
	elif grep -q "$elec_3_num" $file; then
	export unit=3
	export bill_type="electric"
	fi

	# check for balance

	price_str=$(egrep '\$[0-9]+\.[0-9][0-9]' $file)
	if [ -n "$price_str" ]; then
  # remove trailing = and cat lines
  price=$(echo "$price_str" | sed 's/.*\$\([0-9]\+\.[0-9][0-9]\).*/\1/g')
  echo "amount $price"
	fi

	#echo "replacing ${bill_type}_${unit} with ${price}"

	cmd="sed -i s/${bill_type}_${unit}/${price}/ ${murdock_utils}"
	#echo $cmd
	$cmd
done

popd

echo "updated ${murdock_utils}"

exit 0

