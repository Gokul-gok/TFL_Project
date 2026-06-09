#!/bin/bash

echo "========================================="
echo "Starting Sqoop Incremental Load"
echo "========================================="

PG_CONN="jdbc:postgresql://${PG_HOST}:${PG_PORT}/${PG_DB}"

TABLES=(
"dim_networks_inc_load"
"dim_lines_inc_load"
"dim_stations_inc_load"
"fact_station_lines_inc_load"
"dim_date_inc_load"
"fact_passenger_entry_exit_inc_load"
)

for TABLE in "${TABLES[@]}"
do

```
echo "-----------------------------------------"
echo "Processing table: ${TABLE}"
echo "-----------------------------------------"

# Find primary key column
PK_COLUMN=$(psql \
    -h "${PG_HOST}" \
    -U "${PG_USER}" \
    -d "${PG_DB}" \
    -t -c "
    SELECT a.attname
    FROM pg_index i
    JOIN pg_attribute a
    ON a.attrelid = i.indrelid
    AND a.attnum = ANY(i.indkey)
    WHERE i.indrelid = '${PG_SCHEMA}.${TABLE}'::regclass
    AND i.indisprimary;" | xargs)

echo "Primary Key Column: ${PK_COLUMN}"

# Get max primary key value
LAST_VALUE=$(psql \
    -h "${PG_HOST}" \
    -U "${PG_USER}" \
    -d "${PG_DB}" \
    -t -c "
    SELECT MAX(${PK_COLUMN})
    FROM ${PG_SCHEMA}.${TABLE};" | xargs)

echo "Last Value: ${LAST_VALUE}"

sqoop import \
    --connect "${PG_CONN}" \
    --username "${PG_USER}" \
    --password "${PG_PASSWORD}" \
    --table "${PG_SCHEMA}.${TABLE}" \
    --target-dir "${HDFS_DIR}/${TABLE}" \
    --incremental append \
    --check-column "${PK_COLUMN}" \
    --last-value "${LAST_VALUE}" \
    --as-parquetfile \
    --num-mappers 1

if [ $? -ne 0 ]; then
    echo "❌ Incremental load failed for ${TABLE}"
    exit 1
else
    echo "✅ Incremental load completed for ${TABLE}"
fi
```

done

echo "========================================="
echo "Incremental Load Completed Successfully"
echo "========================================="
