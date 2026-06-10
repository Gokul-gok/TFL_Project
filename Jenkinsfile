pipeline {
    agent any

    environment {
        // ── Remote Server ──────────────────────────
        REMOTE_HOST     = '13.41.167.97'
        REMOTE_USER     = 'consultant'
        REMOTE_PASSWORD = 'WelcomeItc@2026'

        // ── PostgreSQL ─────────────────────────────
        PG_HOST         = '13.42.152.118'
        PG_PORT         = '5432'
        PG_DB           = 'testdb'
        PG_USER         = 'admin'
        PG_PASSWORD     = 'admin123'
        PG_SCHEMA       = 'aparna'

        // ── HDFS ───────────────────────────────────
        HDFS_BASE       = '/tmp/gokul/tfl_proj/raw_incremental_load'

        // ── Hive ───────────────────────────────────
        HIVE_DB         = 'tfl_db'
        HIVE_HOST       = 'ip-172-31-12-74.eu-west-2.compute.internal'
        HIVE_PORT       = '10000'

        // ── Script path on remote ──────────────────
        REMOTE_SCRIPT   = '/home/consultant/sqoop_load.sh'
    }

    stages {

        stage('Checkout') {
            steps {
                echo '========================================='
                echo 'Stage 1: Checkout Source Code'
                echo '========================================='
                checkout scm
            }
        }

        stage('Verify Remote Connection') {
            steps {
                echo '========================================='
                echo 'Stage 2: Verify SSH Connection to Remote'
                echo '========================================='
                sh '''
                    sshpass -p "${REMOTE_PASSWORD}" ssh -o StrictHostKeyChecking=no \
                        ${REMOTE_USER}@${REMOTE_HOST} \
                        "echo '✓ SSH connection successful' && hostname && whoami"
                '''
            }
        }

        stage('Verify HDFS Access') {
            steps {
                echo '========================================='
                echo 'Stage 3: Verify HDFS Access'
                echo '========================================='
                sh '''
                    sshpass -p "${REMOTE_PASSWORD}" ssh -o StrictHostKeyChecking=no \
                        ${REMOTE_USER}@${REMOTE_HOST} \
                        "hdfs dfs -ls /tmp/gokul/tfl_proj/ || echo 'HDFS path not yet created'"
                '''
            }
        }

        stage('Copy Script to Remote') {
            steps {
                echo '========================================='
                echo 'Stage 4: Copy Incremental Load Script'
                echo '========================================='
                sh '''
                    sshpass -p "${REMOTE_PASSWORD}" scp -o StrictHostKeyChecking=no \
                        src/sqoop_import.sh \
                        ${REMOTE_USER}@${REMOTE_HOST}:/home/${REMOTE_USER}/sqoop_import.sh
                '''
                sh '''
                    sshpass -p "${REMOTE_PASSWORD}" ssh -o StrictHostKeyChecking=no \
                        ${REMOTE_USER}@${REMOTE_HOST} \
                        "chmod +x /home/${REMOTE_USER}/sqoop_import.sh && echo '✓ Script copied and made executable'"
                '''
            }
        }

        stage('Check Control Table') {
            steps {
                echo '========================================='
                echo 'Stage 5: Check Sqoop Control Table'
                echo '========================================='
                sh '''
                    sshpass -p "${REMOTE_PASSWORD}" ssh -o StrictHostKeyChecking=no \
                        ${REMOTE_USER}@${REMOTE_HOST} \
                        "PGPASSWORD=${PG_PASSWORD} psql -h ${PG_HOST} -p ${PG_PORT} -U ${PG_USER} -d ${PG_DB} -c \\"
                            SELECT table_name, last_value, last_row_count, last_run_time, status
                            FROM ${PG_SCHEMA}.sqoop_control
                            ORDER BY table_name;
                        \\""
                '''
            }
        }

        stage('Run Incremental Load') {
            steps {
                echo '========================================='
                echo 'Stage 6: Run Sqoop Incremental Load'
                echo '========================================='
                sh '''
                    sshpass -p "${REMOTE_PASSWORD}" ssh -o StrictHostKeyChecking=no \
                        ${REMOTE_USER}@${REMOTE_HOST} \
                        "export PG_HOST=${PG_HOST}
                         export PG_PORT=${PG_PORT}
                         export PG_DB=${PG_DB}
                         export PG_USER=${PG_USER}
                         export PG_PASSWORD=${PG_PASSWORD}
                         export PG_SCHEMA=${PG_SCHEMA}
                         export HDFS_BASE=${HDFS_BASE}
                         export HIVE_DB=${HIVE_DB}
                         bash /home/${REMOTE_USER}/sqoop_import.sh"
                '''
            }
        }

        stage('Verify HDFS Output') {
            steps {
                echo '========================================='
                echo 'Stage 7: Verify HDFS Output'
                echo '========================================='
                sh '''
                    sshpass -p "${REMOTE_PASSWORD}" ssh -o StrictHostKeyChecking=no \
                        ${REMOTE_USER}@${REMOTE_HOST} \
                        "echo '--- HDFS Directory Listing ---' && \
                         hdfs dfs -ls ${HDFS_BASE} || echo 'No data in HDFS (all tables had NO_NEW_DATA)'"
                '''
            }
        }

        stage('Final Control Table Status') {
            steps {
                echo '========================================='
                echo 'Stage 8: Final Control Table Status'
                echo '========================================='
                sh '''
                    sshpass -p "${REMOTE_PASSWORD}" ssh -o StrictHostKeyChecking=no \
                        ${REMOTE_USER}@${REMOTE_HOST} \
                        "PGPASSWORD=${PG_PASSWORD} psql -h ${PG_HOST} -p ${PG_PORT} -U ${PG_USER} -d ${PG_DB} -c \\"
                            SELECT table_name, last_value, last_row_count, last_run_time, status
                            FROM ${PG_SCHEMA}.sqoop_control
                            ORDER BY table_name;
                        \\""
                '''
            }
        }
    }

    post {
        success {
            echo '============================================='
            echo 'SQOOP INCREMENTAL LOAD COMPLETED SUCCESSFULLY'
            echo '============================================='
        }
        failure {
            echo '============================================='
            echo 'SQOOP INCREMENTAL LOAD FAILED — CHECK LOGS'
            echo '============================================='
        }
        always {
            echo 'Pipeline finished. Check Stage logs for details.'
        }
    }
}
