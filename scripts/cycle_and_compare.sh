#!/bin/bash

this_year=$(echo ${today} | awk ' { print $1 } ')
# Cycle through the last 11 years
for (( year=${this_year}; year>=${year}-11; year-- ))
do
  for month in 1 2 3 4 5 6 7 8 9 10 11 12
  do
    echo "Processing for Month: ${month} Year: ${year}"
    # Get back.  
      for day in 31 30 29 28 27
      do
        if [ "$today" <= "${year}-${month}-${day}" ]
        then 
          echo "This date is after today.  Not valid."
          continue
        else
          # get the back_b close and break the loop.  if error continue
          grep "${year}-${month}-${day}" ${symbol}.csv || continue
          # Grab the adjusted close
          back_b_close=$( grep "${year}-${month}-${day}" ${symbol}.csv | awk ' { print $6 } ' ) && break
        fi
        
        # Find first market day after 20th. continue if later than today otherwise get the close
        for day in 20 21 22 23 24 25
        do
          # Find last market day of month. continue if later than today otherwise get the close
          # compare the two closes and increment the appropriate counter
        done
        
    # Get middle
      # Find first market day on or after 10th
    # Get front
  done
done
