#!/bin/bash

# Set threshold that defines "sideways"
# May have to change this for various symbols

# 3% should be written as 0.03, for example
sideways_threshold=0.03

for month in {1..12}
do
  for period in  front middle back
  do
    for direction in up side down
    do
      export ${month}_${period}_${direction}=0
    done
  done
done

today=$( date +”%Y-%m-%d” )
echo "This job was run ${today}."
