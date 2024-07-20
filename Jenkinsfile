pipeline {
    agent any

    environment {
        ANSIBLE_DIR = '/etc/ansible/Ansible_Roles'
        GIT_USER = 'elvizhuy'
        GIT_DIR = 'Ansible_Roles'
        PLAYBOOK_REPO = 'https://github.com/${GIT_USER}/${GIT_DIR}.git'
        INVENTORY_HAPROXY_FILE = "${ANISBLE_DIR}/haproxy/inventory/inventory.yml"
        INVENTORY_KEEPALIVED_FILE = "${ANISBLE_DIR}/keepalived/inventory/inventory.yml"
        ANSIBLE_SERVER = 'isofh@10.0.50.30'
    }

    stages {
        stage ('Clone or Pull Project') {
            steps {
                 script {
                    echo "------------ CLONE OR PULL CODE ------------"
                    def workspace = "/var/lib/jenkins/workspace/Ansible-Playbook-Execution/" 
                    def gitDir = "${workspace}/${GIT_DIR}"
                    
                    if (fileExists(gitDir)) {
                        echo "Git repository exists. Pulling changes..."
                        echo "------------ PULL CODE ------------"
                        sh "cd ${workspace}/${GIT_DIR} && git config --global --add safe.directory ${workspace}/${GIT_DIR} && git pull"
                        // /var/lib/jenkins/workspace/Ansible-Playbook-Execution/
                    } else {
                        echo "------------ CLONE PROJECT ------------"
                        echo "Git repository does not exist. Cloning..."
                    }
                    echo "------------- DONE -------------"
                }
            }
        }

        stage('Checkout Ansible Roles') {
            steps {
                pwd()
                sh 'ls -la'
                // checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: env.PLAYBOOK_REPO]]])
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

