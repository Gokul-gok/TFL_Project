pipeline {
agent any

    
environment {
    REMOTE_HOST     = '13.41.167.97'
    REMOTE_USER     = 'consultant'
    REMOTE_PASSWORD = 'WelcomeItc@2026'

    PG_HOST         = '13.42.152.118'
    PG_PORT         = '5432'
    PG_DB           = 'testdb'
    PG_USER         = 'admin'
    PG_PASSWORD     = 'admin123'
    PG_SCHEMA       = 'aparna'

    HDFS_DIR        = '/tmp/tfl_project/hadoop/incremental_load'
}

stages {

    stage('Checkout') {
        steps {
            checkout scm
        }
    }

    stage('Prepare HDFS Directory') {
        steps {
            sh '''
                sshpass -p "${REMOTE_PASSWORD}" ssh -o StrictHostKeyChecking=no \
                ${REMOTE_USER}@${REMOTE_HOST} \
                "hdfs dfs -mkdir -p ${HDFS_DIR}"
            '''
        }
    }

    stage('Copy Incremental Script') {
        steps {
            sh '''
                sshpass -p "${REMOTE_PASSWORD}" scp -o StrictHostKeyChecking=no \
                src/sqoop_incremental_import.sh \
                ${REMOTE_USER}@${REMOTE_HOST}:/home/${REMOTE_USER}/
            '''
        }
    }

    stage('Run Incremental Import') {
        steps {
            sh '''
                sshpass -p "${REMOTE_PASSWORD}" ssh -o StrictHostKeyChecking=no \
                ${REMOTE_USER}@${REMOTE_HOST} \
                "export PGPASSWORD=${PG_PASSWORD};
                 PG_HOST=${PG_HOST}
                 PG_PORT=${PG_PORT}
                 PG_DB=${PG_DB}
                 PG_USER=${PG_USER}
                 PG_PASSWORD=${PG_PASSWORD}
                 PG_SCHEMA=${PG_SCHEMA}
                 HDFS_DIR=${HDFS_DIR}
                 bash /home/${REMOTE_USER}/sqoop_import.sh"
            '''
        }
    }

    stage('Verify HDFS Output') {
        steps {
            sh '''
                sshpass -p "${REMOTE_PASSWORD}" ssh -o StrictHostKeyChecking=no \
                ${REMOTE_USER}@${REMOTE_HOST} \
                "hdfs dfs -ls ${HDFS_DIR}"
            '''
        }
    }

}

post {

    success {
        echo 'SQOOP INCREMENTAL LOAD COMPLETED SUCCESSFULLY'
    }

    failure {
        echo 'SQOOP INCREMENTAL LOAD FAILED'
    }
}

}
