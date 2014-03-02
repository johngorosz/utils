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
	printf "electric_2,kw_2,gas_2,therm_2\n" >> $murdock_utils
fi

# ------------------------------ #
# ------------------------------ #

printf "0=%s\n" $0
printf "mypath=%s\n" $mypath

util_files='electric_1 gas_1 electric_2 gas_2'

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




# assign filename
if [ $unit = 1 ];then
  filename="$unit_1_file"
elif [ $unit = 2 ];then
  filename="$unit_2_file"
else
  exit 0
fi

printf "Number of lines read:\t\t%d\n" $count
printf "date:\t\t\t\t%s\n" $date_now
printf "month:\t\t\t\t%s\n" $filename_month
printf "Unit #:\t\t\t\t%d\n" $unit
printf "Bill Type: \t\t\t%s\n" $bill_type
printf "Bill amount:\t\t\t$%.02f\n" $price
printf "Output file:\t\t\t%s\n" $filename



rent="\$1000"
if [ $unit = 1 ];then
  rent="\$450/500"
fi

rent_sum=""

rent_str=""
bill_str=""
name1_str=""
name2_str=""
name1=""
name2=""

printf -v rent_str "rent    \t%s\t\t%s" ${filename_month} $rent

printf -v bill_str "%-8s\t%s\t$%.02f" $bill_type $date_now $price

  if [ $unit = 1 ];then
	name1="kristine"
	name1_str="${name1}:\$450"
	name2="frank"
	name2_str="${name2}:\$500"
  elif [ $unit = 2 ];then
	name1="eddie-laura"
	name1_str="${name1}:\$1000"
	name2=""
	name2_str=""
  fi

# if the destination file does not exist, create it
if [ ! -e $filename ];then
  echo "creating file"
  printf "Here are the utilities for %s\n\nrent\ngas\nelectric\n\n%s\n%s\n" ${filename_month} $name1_str $name2_str > $filename
fi

# replace holders
cp "${filename}" ${tempfile}
eval "sed -e 's\\^.*${bill_type}.*\$\\${bill_str}\\' <${tempfile} >${filename}"

cp "${filename}" ${tempfile}
eval "sed -e 's\\rent.*\$\\${rent_str}\\' <${tempfile} >${filename}"

current_str=""
current=0

if [ $unit = 1 ];then
  if [ "$bill_type" == "gas" ]; then
    mult_str=".33333"
  else
    mult_str=".25"
  fi

  current_str=`grep ${name1} ${filename}`
  current=${current_str#*$}
  rent_sum=$( echo "scale=2; $current + $price * ($mult_str)" | bc)
  printf -v name1_str "${name1}: $%.02f" $rent_sum

  current_str=`grep ${name2} ${filename}`
  current=${current_str#*$}
  rent_sum=$( echo "scale=2; $current + $price * ($mult_str)" | bc)
  printf -v name2_str "${name2}: $%.02f" $rent_sum

elif [ $unit = 2 ];then
  mult_str="1.0"

  current_str=`grep ${name1} ${filename}`
  current=${current_str#*$}
  rent_sum=$( echo "scale=2; $current + $price * ($mult_str)" | bc)
  printf -v name1_str "${name1}: $%.02f" $rent_sum

  if [ -n "$name2" ]; then
    echo "no name 2 for unit 2"
    current_str=`grep ${name2} ${filename}`
    current=${current_str#*$}
    rent_sum=$( echo "scale=2; $current + $price * (0.0)" | bc)
    printf -v name2_str "${name2}: $%.02f" $rent_sum
  fi
fi

# replace breakdown by name
cp "${filename}" ${tempfile}
eval "sed -e 's\\${name1}.*\$\\${name1_str}\\' <${tempfile} >${filename}"

if [ -n "$name2" ]; then
  echo "not replacing name 2"
  cp "${filename}" ${tempfile}
  eval "sed -e 's\\${name2}.*\$\\${name2_str}\\' <${tempfile} >${filename}"
fi

if [ "$1" == "verbose" ]; then
  # do nothing
  printf "email body:\n\n"
  cat $filename
else
  #exec > $filename
  printf "not verbose\n"
fi

exit 0
