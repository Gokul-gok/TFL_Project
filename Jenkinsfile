pipeline {
    agent any

    environment {
        JDBC_URL     = 'jdbc:postgresql://13.42.152.118:5432/testdb'
        DB_USER      = 'admin'
        DB_PASS      = 'admin123'
        HDFS_BASE    = '/tmp/yamini/tfl_project1'
        HIVE_DB      = 'yamini_tfl_proj'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Sqoop Import') {
            steps {
                echo 'Running Sqoop imports from PostgreSQL to HDFS...'
                sh 'chmod +x src/sqoop_import.sh'
                sh 'src/sqoop_import.sh'
            }
        }

        stage('Create Hive Tables') {
            steps {
                echo 'Creating Hive external tables...'
                sh 'hive -f src/hive_table.sql'
            }
        }

        stage('Verify Tables') {
            steps {
                echo 'Verifying Hive tables...'
                sh '''
                    hive -e "USE yamini_tfl_proj; SHOW TABLES;"
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
