#!/bin/bash
# Name: monitor_mem_usage.sh
# Description: Script to check top memory consuming process for 2 seconds

# Change the SECS to total seconds to monitor Memory usage.
# UNIT_TIME is the interval in seconds between each sampling

function report_utilisation {
  # Process collected data
  echo
  echo "High memory utilization :"

  cat /tmp/mem_usage.$$ |
    awk '
      { process[$1]+=$2; }
      END{
        for(i in process)
        {
          printf("%-20s %s\n", i, process[i]) ;
        }
      }' | sort -nrk 2 | head -n 5

  # Remove the temporary log file
  rm /tmp/mem_usage.$$
  exit 0
}

trap 'report_utilisation' INT

SECS=2
UNIT_TIME=2

STEPS=$(( SECS / UNIT_TIME ))


# Collect data in temp file
for((i=0;i<STEPS;i++)); do
    ps -eocomm,pmem | egrep -v '(0.0)|(%MEM)' >> /tmp/mem_usage.$$
    sleep $UNIT_TIME
done

report_utilisation