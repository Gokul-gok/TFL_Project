#!/bin/bash

sqoop import \
  -D mapreduce.framework.name=local \
  --connect 'jdbc:postgresql://13.42.152.118:5432/testdb' \
  --username admin --password admin123 \
  --table dim_date \
  --target-dir /tmp/yamini/tfl_project1/dim_date \
  --num-mappers 1 \
  --fields-terminated-by ',' \
  --delete-target-dir

sqoop import \
  -D mapreduce.framework.name=local \
  --connect 'jdbc:postgresql://13.42.152.118:5432/testdb' \
  --username admin --password admin123 \
  --table dim_stations \
  --target-dir /tmp/yamini/tfl_project1/dim_stations \
  --num-mappers 1 \
  --fields-terminated-by ',' \
  --delete-target-dir

sqoop import \
  -D mapreduce.framework.name=local \
  --connect 'jdbc:postgresql://13.42.152.118:5432/testdb' \
  --username admin --password admin123 \
  --table dim_networks \
  --target-dir /tmp/yamini/tfl_project1/dim_networks \
  --num-mappers 1 \
  --fields-terminated-by ',' \
  --delete-target-dir

sqoop import \
  -D mapreduce.framework.name=local \
  --connect 'jdbc:postgresql://13.42.152.118:5432/testdb' \
  --username admin --password admin123 \
  --table dim_lines \
  --target-dir /tmp/yamini/tfl_project1/dim_lines \
  --num-mappers 1 \
  --fields-terminated-by ',' \
  --delete-target-dir

sqoop import \
  -D mapreduce.framework.name=local \
  --connect 'jdbc:postgresql://13.42.152.118:5432/testdb' \
  --username admin --password admin123 \
  --table fact_station_lines \
  --target-dir /tmp/yamini/tfl_project1/fact_station_lines \
  --num-mappers 1 \
  --fields-terminated-by ',' \
  --delete-target-dir

sqoop import \
  -D mapreduce.framework.name=local \
  --connect 'jdbc:postgresql://13.42.152.118:5432/testdb' \
  --username admin --password admin123 \
  --table fact_passenger_entry_exit \
  --target-dir /tmp/yamini/tfl_project1/fact_passenger_entry_exit \
  --num-mappers 1 \
  --fields-terminated-by ',' \
  --delete-target-dir
