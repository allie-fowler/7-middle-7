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
  if [[ ! (( $(date -d "$1" +%s) > $(date -d "${3} ${4} ${2}" +%s) )) ]]
  then 
    if [ "$verbose" = 0 ]; then echo "This date is after today.  Not valid." ; fi
    return 1;  # 1 is false
  elif [[ (( $(date +%m) == "$3" )) && (( $(date +%Y) == "$2" )) ]]
  then
    if [ "$verbose" = 0 ]; then echo "Ignoring data for this month." ; fi
    return 1;  # 1 is false  
  else 
    if [ "$verbose" = 0 ]; then echo "This date is past.  Valid for evaluation." ; fi
    return 0;  # 0 is true
  fi  
}

latest_trade_close_of_range() {
# Parameters:  day1, day2, month, year
local day1=$1
local day2=$2
local month=$3
local year=$4
local latest_close

for (( i=$day2; i>=$day1; i=i-1 )); do
#if [ "$verbose" = 0 ]; then echo "Evaluating $month $i, $year" ; echo "i is $i"; fi
    
  # get the back_b close and break the loop.  if not there, discontinue this iteration and go on with next value
  if grep "$year-$month-$i" "${GITHUB_WORKSPACE}/input/historical/${symbol}".csv
  then
    # Grab the adjusted close
    grepdate=$(date -d "${month} ${i} ${year}" +%Y-%m-%i) 
    latest_close=$( grep "${grepdate}" "${GITHUB_WORKSPACE}/input/historical/${symbol}".csv | awk ' { print $6 } ' )
    break  # We found the day, no need to keep iterating
  else
    continue
  fi
done
eval "$5=${latest_close}" 
}  # latest_trade_close_of_range

earliest_trade_close_of_range() {
# Parameters:  day1, day2, month, year
local day1=$1
local day2=$2
local month=$3
local year=$4
local earliest_close

for (( i=$day1; i<=$day2; i=i+1 )); do
    #if [ "$verbose" = 0 ]; then echo "Evaluating $month $i, $year" ; fi
    
    # get the front close and break the loop.  if not there, discontinue this iteration and go on with next value
    if grep "$year-$month-$i" "${GITHUB_WORKSPACE}"/input/historical/"${symbol}".csv
    then
      # Grab the adjusted close
      grepdate=$(date -d "${month} ${i} ${year}" +%Y-%m-%i) 
      earliest_close=$( grep "${grepdate}" "${GITHUB_WORKSPACE}/input/historical/${symbol}".csv | awk ' { print $6 } ' )
      #echo "earliest close between days $day1 and $day2 is ${earliest_close}"
      break  # We found the day, no need to keep iterating
    else
      continue
    fi
done
eval "$5=${earliest_close}" 
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
this_year=$(echo "${today}" | cut -c 8-13)
first_year=$(expr this_year - 11)
# Cycle through the last 11 years
set -x
for (( year=this_year; year>=first_year; year-- ))
do
  for month in {1..12}
  do
    echo "Processing for Month: $month Year: $year"
    
    result=is_past "${today}" "$year" "$month" "1" 
    if [ result == 0 ]
    if [ "$verbose" = 0 ]; then echo "is_past function returned $is_past" ; fi
    then 
      # Discontinue this iteration of the for-day loop and go on with the next value
      continue
    else
      # Process for last 7 days of month
      # get close of latest trading day of range  
      latest_close=""
      latest_trade_close_of_range 27 31 "$month" "$year" "${latest_close}" 
       if [ "$verbose" = 0 ]; then echo "Latest_close function returned ${latest_close}" ; fi
      
      # get close of earliest trading day of range 
      earliest_close=""
      earliest_trade_close_of_range 20 25 "$month" "$year" "${earliest_close}" 
      if [ "$verbose" = 0 ]; then echo "Earliest_close function returned ${earliest_close}" ; fi
    
      if "${latest_close}" >= $(("${earliest_close}"*(1+sideways_threshold)))
      then
        export ((_{!month}_{!period}_up}++))

      elif "${latest_close}" <= $(("${earliest_close}"*(1-sideways_threshold)))
      then
        export ((_{!month}_{!period}_down}++))
      else
        export ((_{!month}_{!period}_side}++))
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
    echo "Month:  $month   UP: ${_[month]_[period]_up}  DOWN:  ${_[month]_[period]_down}      SIDEWAYS:  ${_[month]_[period]_side}"
  done
