#!/bin/bash

# Set threshold that defines "sideways"
# May have to change this for various symbols

# 3% should be written as 0.03, for example
export sideways_threshold=0.04

for month in {1..12}
do
  for period in  front middle back
  do
    for direction in up side down
    do
      myvariable="${month}_${period}_${direction}"
      export "${myvariable}"=0
    done
  done
done

today=$( date +"%m %d %Y" )
echo "This job was run ${today}."
