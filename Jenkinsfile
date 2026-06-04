pipeline {
    agent any

    environment {
        JDBC_URL  = 'jdbc:postgresql://13.42.152.118:5432/testdb'
        DB_USER   = 'admin'
        DB_PASS   = 'admin123'
        HDFS_BASE = '/tmp/yamini/tfl_project1'
        HIVE_DB   = 'yamini_tfl_proj'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Validate Tools') {
            steps {
                echo 'Checking Sqoop and Hive installations...'
                sh '''
                    echo "=== PATH ==="
                    echo $PATH

                    echo "=== Searching for sqoop ==="
                    SQOOP_BIN=""
                    if [ -n "$SQOOP_HOME" ] && [ -f "$SQOOP_HOME/bin/sqoop" ]; then
                        SQOOP_BIN="$SQOOP_HOME/bin/sqoop"
                    else
                        SQOOP_BIN=$(which sqoop 2>/dev/null || \
                            find /usr/lib/sqoop/bin /usr/local/sqoop/bin /opt/sqoop/bin 2>/dev/null -name sqoop -type f | head -1 || \
                            find /usr/hdp -name sqoop -type f 2>/dev/null | head -1 || \
                            find /opt /usr/local -name sqoop -type f 2>/dev/null | head -1 || \
                            echo "")
                    fi

                    if [ -z "$SQOOP_BIN" ]; then
                        echo "ERROR: sqoop not found. Listing candidate directories:"
                        ls /usr/lib/ 2>/dev/null | grep -i sqoop || echo "nothing in /usr/lib"
                        ls /usr/hdp/ 2>/dev/null || echo "no /usr/hdp"
                        ls /opt/ 2>/dev/null | grep -i sqoop || echo "nothing in /opt"
                        ls /usr/local/ 2>/dev/null | grep -i sqoop || echo "nothing in /usr/local"
                        exit 1
                    fi
                    echo "Found sqoop at: $SQOOP_BIN"

                    echo "=== Searching for hive ==="
                    HIVE_BIN=""
                    if [ -n "$HIVE_HOME" ] && [ -f "$HIVE_HOME/bin/hive" ]; then
                        HIVE_BIN="$HIVE_HOME/bin/hive"
                    else
                        HIVE_BIN=$(which hive 2>/dev/null || \
                            find /usr/lib/hive/bin /usr/local/hive/bin /opt/hive/bin 2>/dev/null -name hive -type f | head -1 || \
                            find /usr/hdp -name hive -type f 2>/dev/null | head -1 || \
                            find /opt /usr/local -name hive -type f 2>/dev/null | head -1 || \
                            echo "")
                    fi

                    if [ -z "$HIVE_BIN" ]; then
                        echo "ERROR: hive not found. Listing candidate directories:"
                        ls /usr/lib/ 2>/dev/null | grep -i hive || echo "nothing in /usr/lib"
                        ls /usr/hdp/ 2>/dev/null || echo "no /usr/hdp"
                        ls /opt/ 2>/dev/null | grep -i hive || echo "nothing in /opt"
                        exit 1
                    fi
                    echo "Found hive at: $HIVE_BIN"
                '''
            }
        }

        stage('Sqoop Import') {
            steps {
                echo 'Running Sqoop imports from PostgreSQL to HDFS...'
                sh '''
                    if [ -n "$SQOOP_HOME" ] && [ -f "$SQOOP_HOME/bin/sqoop" ]; then
                        SQOOP_BIN="$SQOOP_HOME/bin/sqoop"
                    else
                        SQOOP_BIN=$(which sqoop 2>/dev/null || \
                            find /usr/lib/sqoop/bin /usr/local/sqoop/bin /opt/sqoop/bin 2>/dev/null -name sqoop -type f | head -1 || \
                            find /usr/hdp -name sqoop -type f 2>/dev/null | head -1 || \
                            find /opt /usr/local -name sqoop -type f 2>/dev/null | head -1)
                    fi

                    chmod +x src/sqoop_import.sh

                    $SQOOP_BIN import \
                      -D mapreduce.framework.name=local \
                      --connect "${JDBC_URL}" \
                      --username "${DB_USER}" --password "${DB_PASS}" \
                      --table dim_date \
                      --target-dir ${HDFS_BASE}/dim_date \
                      --num-mappers 1 --fields-terminated-by ',' --delete-target-dir

                    $SQOOP_BIN import \
                      -D mapreduce.framework.name=local \
                      --connect "${JDBC_URL}" \
                      --username "${DB_USER}" --password "${DB_PASS}" \
                      --table dim_stations \
                      --target-dir ${HDFS_BASE}/dim_stations \
                      --num-mappers 1 --fields-terminated-by ',' --delete-target-dir

                    $SQOOP_BIN import \
                      -D mapreduce.framework.name=local \
                      --connect "${JDBC_URL}" \
                      --username "${DB_USER}" --password "${DB_PASS}" \
                      --table dim_networks \
                      --target-dir ${HDFS_BASE}/dim_networks \
                      --num-mappers 1 --fields-terminated-by ',' --delete-target-dir

                    $SQOOP_BIN import \
                      -D mapreduce.framework.name=local \
                      --connect "${JDBC_URL}" \
                      --username "${DB_USER}" --password "${DB_PASS}" \
                      --table dim_lines \
                      --target-dir ${HDFS_BASE}/dim_lines \
                      --num-mappers 1 --fields-terminated-by ',' --delete-target-dir

                    $SQOOP_BIN import \
                      -D mapreduce.framework.name=local \
                      --connect "${JDBC_URL}" \
                      --username "${DB_USER}" --password "${DB_PASS}" \
                      --table fact_station_lines \
                      --target-dir ${HDFS_BASE}/fact_station_lines \
                      --num-mappers 1 --fields-terminated-by ',' --delete-target-dir

                    $SQOOP_BIN import \
                      -D mapreduce.framework.name=local \
                      --connect "${JDBC_URL}" \
                      --username "${DB_USER}" --password "${DB_PASS}" \
                      --table fact_passenger_entry_exit \
                      --target-dir ${HDFS_BASE}/fact_passenger_entry_exit \
                      --num-mappers 1 --fields-terminated-by ',' --delete-target-dir
                '''
            }
        }

        stage('Create Hive Tables') {
            steps {
                echo 'Creating Hive external tables...'
                sh '''
                    if [ -n "$HIVE_HOME" ] && [ -f "$HIVE_HOME/bin/hive" ]; then
                        HIVE_BIN="$HIVE_HOME/bin/hive"
                    else
                        HIVE_BIN=$(which hive 2>/dev/null || \
                            find /usr/lib/hive/bin /usr/local/hive/bin /opt/hive/bin 2>/dev/null -name hive -type f | head -1 || \
                            find /usr/hdp -name hive -type f 2>/dev/null | head -1 || \
                            find /opt /usr/local -name hive -type f 2>/dev/null | head -1)
                    fi
                    $HIVE_BIN -f src/hive_table.sql
                '''
            }
        }

        stage('Verify Tables') {
            steps {
                echo 'Verifying Hive tables...'
                sh '''
                    if [ -n "$HIVE_HOME" ] && [ -f "$HIVE_HOME/bin/hive" ]; then
                        HIVE_BIN="$HIVE_HOME/bin/hive"
                    else
                        HIVE_BIN=$(which hive 2>/dev/null || \
                            find /usr/lib/hive/bin /usr/local/hive/bin /opt/hive/bin 2>/dev/null -name hive -type f | head -1 || \
                            find /usr/hdp -name hive -type f 2>/dev/null | head -1 || \
                            find /opt /usr/local -name hive -type f 2>/dev/null | head -1)
                    fi
                    $HIVE_BIN -e "USE yamini_tfl_proj; SHOW TABLES;"
                '''
            }
        }
    }

    post {
        success {
            echo 'TFL pipeline completed successfully.'
        }
        failure {
            echo 'TFL pipeline failed. Check logs above.'
        }
    }
}
