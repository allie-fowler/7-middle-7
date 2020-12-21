#!/bin/bash

# Set threshold that defines "sideways"
# May have to change this for various symbols

# 3% should be written as 0.03, for example
sideways_threshold=0.03

for month in Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
do
  for period in  front middle back
  do
    for direction in up side down
    do
      export ${month}_${period}_${direction}=0
    done
  done
done
