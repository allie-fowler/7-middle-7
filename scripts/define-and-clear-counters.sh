#!/bin/bash

# Set threshold that defines "sideways"
# May have to change this for various symbols

# 3% should be written as 0.03, for example
sideways_threshold=0.03

for month in Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
do
  for period in  front middle back
  do
    export ${month}_${period}=0
  done
done
