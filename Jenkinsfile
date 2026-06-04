pipeline {
    agent any

    environment {
        JDBC_URL  = 'jdbc:postgresql://13.42.152.118:5432/testdb'
        DB_USER   = 'admin'
        DB_PASS   = 'admin123'
        HDFS_BASE = '/tmp/yamini/tfl_project1'
        HIVE_DB   = 'yamini_tfl_proj'
        PATH      = "/usr/lib/sqoop/bin:/usr/bin/sqoop:/opt/sqoop/bin:/usr/hdp/current/sqoop-client/bin:/usr/lib/hive/bin:/opt/hive/bin:/usr/hdp/current/hive-client/bin:${env.PATH}"
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
                    SQOOP_BIN=$(which sqoop 2>/dev/null || find /usr /opt /usr/hdp -name sqoop -type f 2>/dev/null | head -1)
                    if [ -z "$SQOOP_BIN" ]; then
                        echo "ERROR: sqoop not found on this node."
                        exit 1
                    fi
                    echo "Found sqoop at: $SQOOP_BIN"

                    HIVE_BIN=$(which hive 2>/dev/null || find /usr /opt /usr/hdp -name hive -type f 2>/dev/null | head -1)
                    if [ -z "$HIVE_BIN" ]; then
                        echo "ERROR: hive not found on this node."
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
                    SQOOP_BIN=$(which sqoop 2>/dev/null || find /usr /opt /usr/hdp -name sqoop -type f 2>/dev/null | head -1)
                    chmod +x src/sqoop_import.sh
                    sed -i "s|sqoop import|$SQOOP_BIN import|g" src/sqoop_import.sh
                    bash src/sqoop_import.sh
                '''
            }
        }

        stage('Create Hive Tables') {
            steps {
                echo 'Creating Hive external tables...'
                sh '''
                    HIVE_BIN=$(which hive 2>/dev/null || find /usr /opt /usr/hdp -name hive -type f 2>/dev/null | head -1)
                    $HIVE_BIN -f src/hive_table.sql
                '''
            }
        }

        stage('Verify Tables') {
            steps {
                echo 'Verifying Hive tables...'
                sh '''
                    HIVE_BIN=$(which hive 2>/dev/null || find /usr /opt /usr/hdp -name hive -type f 2>/dev/null | head -1)
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
