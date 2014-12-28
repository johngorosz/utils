#!/bin/sh
if [ "$1" != "verbose" ]; then
  exec > /dev/null 2>&1 
fi

# ------------------------------ #
# ------------------------------ #
# configuration values

mypath=`dirname "$0"`

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

for file in $util_files; do
	if [ ! -e $file ]; then
		echo "ERROR: could not find file $file"
		exit 1
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
	if grep -q "in the amount of" $file; then
	price_str=$(grep "in the amount of" $file)
echo "price_str $price_str"
		# cut leading string
	price_str=${price_str#*in the amount of }
echo "price_str $price_str"
		# cut longest end string containing " "
	price_str=${price_str%% *}
echo "price_str $price_str"
		# cut leading $
	export price=${price_str#$}
	fi

	#echo "replacing ${bill_type}_${unit} with ${price}"

	cmd="sed -i s/${bill_type}_${unit}/${price}/ ${murdock_utils}"
	#echo $cmd
	$cmd
done

echo "updated ${murdock_utils}"

exit 0

