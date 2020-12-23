#!/bin/bash
# Steps through past 11 years
# Compares for each segment of each past month
# Tallies the counters
set -x

function usage {
        echo "./$(basename "$0") [-v] [-h] "
        echo "   Steps through past 11 years of history and compares each 7-m-7 segment of each past month."
}

is_past () {
# parameters:  today's date YYYY-MM-DD, comparison year YYYY, comparison month MM, comparison day DD
  if [[ ! "$1" > "${2}-${3}-${4}" ]]
  then 
    if [ "$verbose" = true ]; then echo "This date is after today.  Not valid." ; fi
    return 1;  # 1 is false
  else 
    if [ "$verbose" = true ]; then echo "This date is past.  Valid for evaluation." ; fi
    return 0;  # 0 is true
  fi
}

latest_trade_close_of_range() {
# Parameters:  day1, day2, month, year
local day1=$1
local day2=$2
local month=$3
local year=$4

  for (( i=day2; i<=day1; i-- )); do
    if [ "$verbose" = true ]; then echo "Evaluating $month $i, $year" ; fi
    
    if is_past "${today}" "$year" "$month" "$i" 
    then 
      # Discontinue this iteration of the for-day loop and go on with the next value
      continue
    else
      # get the back_b close and break the loop.  if not there, discontinue this iteration and go on with next value
      if grep "$year-$month-$i" "${symbol}".csv
      then
        # Grab the adjusted close
         
        latest_close=$( grep "${year}-${month}-${i}" "${symbol}".csv | awk ' { print $6 } ' )
        echo "${latest_close}"
        break  # We found the day, no need to keep iterating
      else
        continue
      fi
    fi
  done
}  # latest_trade_close_of_range

earliest_trade_close_of_range() {
# Parameters:  day1, day2, month, year
local day1=$1
local day2=$2
local month=$3
local year=$4

  for (( i=day2; i>=day1; i++ )); do
    if [ "$verbose" = true ]; then echo "Evaluating $month $i, $year" ; fi
    
    if is_past "${today}" "$year" "$month" "$i" 
    then 
      # Discontinue this iteration of the for-day loop and go on with the next value
      continue
    else
      # get the front close and break the loop.  if not there, discontinue this iteration and go on with next value
      if grep "$year-$month-$i" "${symbol}".csv
      then
        # Grab the adjusted close
         
        earliest_close=$( grep "$year-$month-$i" "${symbol}".csv | awk ' { print $6 } ' )
        echo "${earliest_close}"
        break  # We found the day, no need to keep iterating
      else
        continue
      fi
    fi
  done
}  # earliest_trade_close_of_range

# main -------------
verbose=1
# list of arguments expected in the input
# We use "$@" instead of $* to preserve argument-boundary information
while getopts hvs: name
do
     case $name in
     v)   verbose=0
          ;;
     h)   usage
          ;;
     s)   symbol="$OPTARG"
          ;;
     ?)   usage
          exit 2
          ;;
     esac
done
 
source scripts/define-and-clear-counters.sh
this_year=$(echo "${today}" | cut -c 2-7)
# Cycle through the last 11 years
for (( year=this_year; year>=year-11; year-- ))
do
  for month in Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
  do
    echo "Processing for Month: $month Year: $year"
    
    # Process for last 7 days of month
    # get close of latest trading day of range  
    latest_close=$( latest_trade_close_of_range 27 31 "$month" "$year" )
      
    # get close of earliest trading day of range 
    earliest_close=$( earliest_trade_close_of_range 20 25 "$month" "$year" )
    
    if latest_close >= earliest_close*$((1+sideways_threshold))
    then
      export "{!month}_{!period}_up}"++

    elif latest_close <= earliest_close*$((1-sideways_threshold))
    then
      export "{!month}_{!period}_down}"++
    else
      export export "{!month}_{!period}_side}"++
    fi
        
    # Process for middle 7
      # Find first market day on or after 10th
      
    # Process for front 7
  done  # month
done  # year

# Cycle through months and directions
for month in Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
  do
    echo "Month:  $month   UP: ${[month]_[period]_up}  DOWN:  ${[month]_[period]_down}      SIDEWAYS:  ${[month]_[period]_side}"
  done
