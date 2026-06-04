pipeline {
    agent any

    environment {
        JDBC_URL    = 'jdbc:postgresql://13.42.152.118:5432/testdb'
        DB_USER     = 'admin'
        DB_PASS     = 'admin123'
        HDFS_BASE   = '/tmp/yamini/tfl_project1'
        HIVE_DB     = 'yamini_tfl_proj'
        HADOOP_NODE = '13.41.167.97'
        SSH_USER    = 'ec2-user'
        SSH_KEY     = '/var/lib/jenkins/test_key.pem'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Sqoop Import') {
            steps {
                echo 'Running Sqoop imports on Hadoop node via SSH...'
                sh """
                    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${SSH_USER}@${HADOOP_NODE} bash << 'ENDSSH'
sqoop import -D mapreduce.framework.name=local \\
  --connect 'jdbc:postgresql://13.42.152.118:5432/testdb' \\
  --username admin --password admin123 \\
  --table dim_date \\
  --target-dir /tmp/yamini/tfl_project1/dim_date \\
  --num-mappers 1 --fields-terminated-by ',' --delete-target-dir

sqoop import -D mapreduce.framework.name=local \\
  --connect 'jdbc:postgresql://13.42.152.118:5432/testdb' \\
  --username admin --password admin123 \\
  --table dim_stations \\
  --target-dir /tmp/yamini/tfl_project1/dim_stations \\
  --num-mappers 1 --fields-terminated-by ',' --delete-target-dir

sqoop import -D mapreduce.framework.name=local \\
  --connect 'jdbc:postgresql://13.42.152.118:5432/testdb' \\
  --username admin --password admin123 \\
  --table dim_networks \\
  --target-dir /tmp/yamini/tfl_project1/dim_networks \\
  --num-mappers 1 --fields-terminated-by ',' --delete-target-dir

sqoop import -D mapreduce.framework.name=local \\
  --connect 'jdbc:postgresql://13.42.152.118:5432/testdb' \\
  --username admin --password admin123 \\
  --table dim_lines \\
  --target-dir /tmp/yamini/tfl_project1/dim_lines \\
  --num-mappers 1 --fields-terminated-by ',' --delete-target-dir

sqoop import -D mapreduce.framework.name=local \\
  --connect 'jdbc:postgresql://13.42.152.118:5432/testdb' \\
  --username admin --password admin123 \\
  --table fact_station_lines \\
  --target-dir /tmp/yamini/tfl_project1/fact_station_lines \\
  --num-mappers 1 --fields-terminated-by ',' --delete-target-dir

sqoop import -D mapreduce.framework.name=local \\
  --connect 'jdbc:postgresql://13.42.152.118:5432/testdb' \\
  --username admin --password admin123 \\
  --table fact_passenger_entry_exit \\
  --target-dir /tmp/yamini/tfl_project1/fact_passenger_entry_exit \\
  --num-mappers 1 --fields-terminated-by ',' --delete-target-dir
ENDSSH
                """
            }
        }

        stage('Create Hive Tables') {
            steps {
                echo 'Creating Hive external tables on Hadoop node via SSH...'
                sh """
                    scp -i ${SSH_KEY} -o StrictHostKeyChecking=no src/hive_table.sql ${SSH_USER}@${HADOOP_NODE}:/tmp/hive_table.sql
                    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${SSH_USER}@${HADOOP_NODE} 'hive -f /tmp/hive_table.sql'
                """
            }
        }

        stage('Verify Tables') {
            steps {
                echo 'Verifying Hive tables on Hadoop node...'
                sh """
                    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${SSH_USER}@${HADOOP_NODE} 'hive -e "USE yamini_tfl_proj; SHOW TABLES;"'
                """
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
