#!/bin/bash
# Steps through past 11 years
# Compares for each segment of each past month
# Tallies the counters

function usage {
        echo "./$(basename "$0") [-v] [-h] "
        echo "   Steps through past 11 years of history and compares each 7-m-7 segment of each past month."
}

is_past () {
# parameters:  today's date YYYY-MM-DD, comparison year YYYY, comparison month MM, comparison day DD
# (( $(date -d "2014-12-01T21:34:03+02:00" +%s) < $(date -d "2014-12-01T21:35:03+02:00" +%s) ))
  if [[ (( $(date +%s) < $(date -d "${1}-${2}-${3} " +%s) )) ]]
  then 
    echo 1;  # 1 is false
    if [ "$verbose" -eq 0 ]; then echo "This date is after today.  Not valid." ; fi    
  elif [[ (( $(date +%-m) -eq "$2" )) && (( $(date +%Y) -eq "$1" )) ]]
  then
    echo 1;  # 1 is false 
    if [ "$verbose" -eq 0 ]; then echo "Ignoring data for this month." ; fi 
  else 
    echo "0";  # 0 is true
    if [ "$verbose" -eq 0 ]; then echo "This date is past.  Valid for evaluation." ; fi
  fi  
}

latest_trade_close_of_range() {
# Parameters:  day1, day2, month, year
local day1=$1
local day2=$2
local month=$3
local year=$4
local latest_close

for (( i=day2; i>=day1; i=i-1 )); do
if [ "$verbose" -eq 0 ]; then echo "Evaluating Latest Close with $month $i, $year" ; echo "i is $i"; fi
  grepdate=$(date -d "${year}-${month}-${i}" +%Y-%m-%d)  
  [ "${grepdate}" = '' ] && continue  #skip to the next date if invalid like Feb 31st
  # get the back_b close and break the loop.  if not there, discontinue this iteration and go on with next value
  if grep "${grepdate}" "${GITHUB_WORKSPACE}/input/historical/${symbol}".csv
  then
    # Grab the adjusted close
    latest_close=$( grep "${grepdate}" "${GITHUB_WORKSPACE}/input/historical/${symbol}".csv | awk -F ',' ' { print $6 } ' )
    break  # We found the day, stop iterating
  else
    continue
  fi
done
echo "${latest_close}" 
}  # latest_trade_close_of_range

earliest_trade_close_of_range() {
# Parameters:  day1, day2, month, year
local day1=$1
local day2=$2
local month=$3
local year=$4
local earliest_close

for (( i=day1; i<=day2; i=i+1 )); do
    if [ "$verbose" -eq 0 ]; then echo "Evaluating Earliest Close with $month $i, $year" ; fi
    grepdate=$(date -d "${year}-${month}-${i}" +%Y-%m-%d) 
    [ "${grepdate}" = '' ] && continue  #skip to the next date if invalid like Feb 31st 
    # get the front close and break the loop.  if not there, discontinue this iteration and go on with next value
    if grep "${grepdate}" "${GITHUB_WORKSPACE}"/input/historical/"${symbol}".csv
    then
      # Grab the adjusted close
      earliest_close=$( grep "${grepdate}" "${GITHUB_WORKSPACE}/input/historical/${symbol}".csv | awk -F ',' ' { print $6 } ' )
      echo "earliest close between days $day1 and $day2 is ${earliest_close}"
      break  # We found the day, stop iterating
    else
      continue
    fi
done
echo "${earliest_close}" 
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
set -x
this_year=$(echo "${today}" | cut -c 7-13)
if [ "$verbose" -eq 0 ]; then echo "This year is ${this_year}" ; fi
first_year=$((this_year - 11))
if [ "$verbose" -eq 0 ]; then echo "First year is ${first_year}" ; fi
# Cycle through the last 11 years
for (( year=this_year; year>=first_year; year-- ))
do
  for month in {1..12}
  do
    echo "Processing for Month: $month Year: $year"
    
    result=$(is_past "$year" "$month" "1") 
    if [ "$result" == "0" ]
    then 
      # Throw away the date if it's in the future and go on with the next value
      if [ "$verbose" -eq 0 ]; then echo "${result} is in the future.  Discarding." ; fi
      continue
    else
      # Process for last 7 days of month
      # get closing price of latest trading day of range 
      if [ "$verbose" -eq 0 ]; then echo "is_past function returned $result" ; fi
      latest_close=""
      latest_close=$(latest_trade_close_of_range 27 31 "$month" "$year")
      if [ "$verbose" -eq 0 ]; then echo "Latest_close function returned ${latest_close}" ; fi
      if [ "${latest_close}" == "" ]; then echo "Latest close returned no data.  Skipping."; continue ; fi 
      
      # get close of earliest trading day of range 
      earliest_close=""
      earliest_close=$(earliest_trade_close_of_range 20 25 "$month" "$year")
      if [ "$verbose" -eq 0 ]; then echo "Earliest_close function returned ${earliest_close}" ; fi
      if [ "${earliest_close}" == "" ]; then echo "Earliest close returned no data.  Skipping."; continue ; fi 
    
      max_threshold=$( echo "${earliest_close} ${sideways_threshold}" | awk '{print $1 * (1 + $2)}' )    
      min_threshold=$( echo "${earliest_close} ${sideways_threshold}" | awk '{print $1 * (1 - $2)}' )
      if [ ! "${latest_close}" \< "${max_threshold}" ]
      then
        temp_var_name="_${month}_${period}_up"
        if [ "$verbose" -eq 0 ]; then echo "temp_var_name is ${temp_var_name}" ; fi
        ((${temp_var_name}++))
        if [ "$verbose" -eq 0 ]; then echo "temp_var_name is ${temp_var_name}" ; fi
        export ${temp_var_name}
      elif [ ! "${latest_close}" \< "${min_threshold}" ]
      then
        temp_var_name="_${month}_${period}_down"
        if [ "$verbose" -eq 0 ]; then echo "temp_var_name is ${temp_var_name}" ; fi
        ((${temp_var_name}++))
        if [ "$verbose" -eq 0 ]; then echo "temp_var_name is ${temp_var_name}" ; fi
        export ${temp_var_name}
      else
        temp_var_name="_${month}_${period}_side"
        if [ "$verbose" -eq 0 ]; then echo "temp_var_name is ${temp_var_name}" ; fi
        ((${temp_var_name}++))
        if [ "$verbose" -eq 0 ]; then echo "temp_var_name is ${temp_var_name}" ; fi
        export ${temp_var_name}
      fi
        
      # Process for middle 7
        # Find first market day on or after 10th
      
      # Process for front 7
    fi  
  done  # month
done  # year

# Cycle through months and directions
for month in {1..12}
do
  for period in front middle back
  do
    up_var_name="_${month}_${period}_up"
    down_var_name="_${month}_${period}_down"
    side_var_name="_${month}_${period}_side"
    echo "Month:  ${month}    ${period}  UP: ${!up_var_name}  DOWN:  ${!down_var_name}      SIDEWAYS:  ${!side_var_name}"
  done
done
