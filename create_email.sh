#!/bin/bash
if [ "$1" != "verbose" ]; then
  exec > /dev/null 2>&1 
fi

# ------------------------------ #
# ------------------------------ #
# configuration values

mypath=`dirname "$0"`

gas_2_num="\#1205 971 0165"
elec_1_num="\#2040 022 1048"
gas_1_num="\#1205 970 0133"
elec_2_num="\#2040 021 1098"


date_now=`date +%m/%Y`
filename_month="`date --date='next month' +%b`"
month_year="`date --date='next month' +%m/%Y`"

#filename=test.txt
filename1="$mypath/${filename_month}_1.txt"
filename2="$mypath/${filename_month}_2.txt"
tempfile="$mypath/temp"
emailfile="$mypath/${filename_month}_email"

unit_1_file="$mypath/unit_1_${filename_month}.txt"
unit_2_file="$mypath/unit_2_${filename_month}.txt"

murdock_utils="$mypath/murdock.csv"


# ------------------------------ #
# ------------------------------ #

printf "0=%s\n" $0
printf "mypath=%s\n" $mypath

let count=0
let index=0
export price=0
price_str=""
export unit=0
export bill_type=""

function calculate_rent
{
  current=0

  if [ "$unit" == "1" ];then
    gas_mult_str=".33333"
    elec_mult_str=".25"

    current="${rent1}"
    rent_sum=$( echo "scale=2; $current + $ELEC_1 * ($elec_mult_str) + $GAS_1 * ($gas_mult_str)" | bc)
    printf -v rent_util_1 "${name1}: $%.02f" $rent_sum

    current="${rent2}"
    rent_sum=$( echo "scale=2; $current + $ELEC_1 * ($elec_mult_str) + $GAS_1 * ($gas_mult_str)" | bc)
    printf -v rent_util_2 "${name2}: $%.02f" $rent_sum

  elif [ $unit = 2 ];then
    mult_str="1.0"

    current=${rent1}
    rent_sum=$( echo "scale=2; $current + $ELEC_2 * ($mult_str) + $GAS_2 * ($mult_str)" | bc)
    printf -v rent_util_1 "${name1}: $%.02f" $rent_sum

  fi
}

# parse murdock_utils for values
last_line=$( tail -n 1 $murdock_utils )

#echo "$last_line"

DATE=$( echo "$last_line" | cut -d, -f1 )
ELEC_1=$( echo "$last_line" | cut -d, -f2 )
KW_1=$( echo "$last_line" | cut -d, -f3 )
GAS_1=$( echo "$last_line" | cut -d, -f4 )
THERM_1=$( echo "$last_line" | cut -d, -f5 )
ELEC_2=$( echo "$last_line" | cut -d, -f6 )
KW_2=$( echo "$last_line" | cut -d, -f7 )
GAS_2=$( echo "$last_line" | cut -d, -f8 )
THERM_2=$( echo "$last_line" | cut -d, -f9 )

#echo "parsed:"
#echo "$DATE"
#echo "$ELEC_1"
#echo "$KW_1"
#echo "$GAS_1"
#echo "$THERM_1"
#echo "$ELEC_2"
#echo "$KW_2"
#echo "$GAS_2"
#echo "$THERM_2"



rent_sum=""

rent_str=""
bill_str=""
name1_str=""
name2_str=""
name1=""
name2=""

# create unit 1 email
unit=1
rent="\$450/500"

name1="kristine"
rent1="450"
rent_util_1=""
name2="john"
rent2="500"
rent_util_2=""

calculate_rent

cat << FILE1 > $filename1
Here is the rent for ${filename_month}

rent            ${filename_month}     	${rent}
gas             ${DATE} 	\$${GAS_1}
electric        ${DATE} 	\$${ELEC_1}

${rent_util_1}
${rent_util_2}

FILE1

cat $filename1

# create unit 2 email
unit=2
rent="\$1000"

name1="eddie-laura"
rent1="1000"
rent_util_1=""
name2=""
rent2=""
rent_util_2=""

calculate_rent

cat << FILE2 > $filename2
Here is the rent for ${filename_month}

rent            ${filename_month}     	${rent}
gas             ${DATE} 	\$${GAS_2}
electric        ${DATE} 	\$${ELEC_2}

${rent_util_1}
${rent_util_2}

FILE2

cat $filename2

exit 0
