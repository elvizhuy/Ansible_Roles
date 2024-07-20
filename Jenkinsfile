pipeline {
    agent any

    environment {
        ANSIBLE_DIR = '/etc/ansible/Ansible_Roles'
        GIT_USER = 'elvizhuy'
        PLAYBOOK_REPO = 'https://github.com/${GIT_USER}/${ANSIBLE_DIR}.git'
        INVENTORY_HAPROXY_FILE = "${ANISBLE_DIR}/haproxy/inventory/inventory.yml"
        INVENTORY_KEEPALIVED_FILE = "${ANISBLE_DIR}/keepalived/inventory/inventory.yml"
        ANSIBLE_SERVER = 'isofh@10.0.50.30'
    }

    stages {
        stage('Checkout Ansible Roles') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: env.PLAYBOOK_REPO]]])
            }
        }

        stage('Run HAProxy Playbook') {
            steps {
                sshagent(credentials: ['ansible-server-ssh']) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ${ANSIBLE_SERVER} 'cd ${ANSIBLE_DIR}/haproxy && ansible-playbook -i ${INVENTORY_HAPROXY_FILE} haproxy-playbook.yml'
                    """
                }
            }
        }

        stage('Run Keepalived Playbook') {
            steps {
                sshagent(credentials: ['ansible-server-ssh']) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ${ANSIBLE_SERVER} 'cd ${ANSIBLE_DIR}/keepalived && ansible-playbook -i ${INVENTORY_KEEPALIVED_FILE} keepalived-playbook.yml'
                    """
                }
            }
        }
    }
}

