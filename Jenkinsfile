pipeline {
    agent any

    environment {
        HAPROXY_PLAYBOOK_REPO = 'https://github.com/elvizhuy/haproxy-playbook-repo.git'
        KEEPALIVED_PLAYBOOK_REPO = 'https://github.com/elvizhuy/keepalived-playbook-repo.git'
        INVENTORY_FILE = 'inventory.ini'
    }

    stages {
        stage('Checkout HAProxy Playbook') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: env.HAPROXY_PLAYBOOK_REPO]]])
            }
        }

        stage('Run HAProxy Playbook') {
            steps {
                sh '''
                ansible-playbook -i $INVENTORY_FILE haproxy-playbook.yml
                '''
            }
        }

        stage('Checkout Keepalived Playbook') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: env.KEEPALIVED_PLAYBOOK_REPO]]])
            }
        }

        stage('Run Keepalived Playbook') {
            steps {
                sh '''
                ansible-playbook -i $INVENTORY_FILE keepalived-playbook.yml
                '''
            }
        }
    }
}
