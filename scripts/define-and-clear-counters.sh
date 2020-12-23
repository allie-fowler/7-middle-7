#!/bin/bash
set -x
# Set threshold that defines "sideways"
# May have to change this for various symbols

# 3% should be written as 0.03, for example
export sideways_threshold=0.04

for month in Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
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

today=$( date +"%Y-%b-%d" )
echo "This job was run ${today}."
