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
        GIT_CONFIG = 'git config --global --add safe.directory'
    }

    parameters {
        choice(choices: ["Haproxy","Keepalived"], description: 'Choose Role', name: 'role')
        choice(choices: ["bvp"], description: 'Choose Project', name: 'project')
        choice(choices: ["install", "clear"], description: 'Choose Action', name: 'action')
    }

    stages {
        // stage ('Clone or Pull Project') {
        //     steps {
        //          script {
        //             echo "------------ CLONE OR PULL CODE ------------"
        //             def workspace = "/var/lib/jenkins/workspace/Ansible-Playbook-Execution" 
        //             def gitDir = "${workspace}/${GIT_DIR}"
                    
        //             if (fileExists(gitDir)) {
        //                 echo "Git repository exists. Pulling changes..."
        //                 echo "------------ PULL CODE ------------"
        //                 sh "cd ${workspace}/${GIT_DIR} && git config --global --add safe.directory ${workspace}/${GIT_DIR} && git pull"
        //                 // /var/lib/jenkins/workspace/Ansible-Playbook-Execution/
        //             } else {
        //                 echo "------------ CLONE PROJECT ------------"
        //                 echo "Git repository does not exist. Cloning..."
        //             }
        //             echo "------------- DONE -------------"
        //         }
        //     }
        // }

        stage('Choose Ansible Roles') {
            when { expression { params.role != null && params.role != '' && params.action != ''}}
            steps {
               script {
                    echo "------------ CHECKOUT ANSIBLE ROLES ------------"
                    sh 'pwd'
                    sh 'ls -la'
                    // checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: env.PLAYBOOK_REPO]]])
                    sshagent(credentials: ['ansible-server-ssh']) {
                        sh """
                        ssh -o StrictHostKeyChecking=no ${ANSIBLE_SERVER} "cd ${ANSIBLE_DIR} && ${GIT_CONFIG} ${ANSIBLE_DIR} && git pull"
                        """
                    }
                    
                    echo "------------- DONE -------------"
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                script {
                    def inventoryFile = "${ANSIBLE_DIR}/${params.role.toLowerCase()}/inventory/inventory.yml"
                    def playbookFile = "${ANSIBLE_DIR}/${params.role.toLowerCase()}/${params.role.toLowerCase()}-playbook.yml"
                    if (params.action == 'clear') {
                        playbookFile = "${ANSIBLE_DIR}/clear-playbook.yml"
                    }
                    echo "Running playbook for role: ${params.role}, project: ${params.project}, action: ${params.action}"
                    
                    sshagent(credentials: ['ansible-server-ssh']) {
                        sh """
                        ssh -o StrictHostKeyChecking=no ${ANSIBLE_SERVER} "cd ${ANSIBLE_DIR}/${params.role.toLowerCase()} && ansible-playbook -i ${inventoryFile} ${playbookFile} --extra-vars 'project=${params.project} role=${params.role}'"
                        """
                    }
                }
            }
        }
        // stage('Run HAProxy Playbook') {
        //     when {
        //         allOf {
        //             expression { params.role == 'Haproxy' }
        //             expression { params.project == 'bvp' }
        //         }
        //     }
        //     steps {
        //         sshagent(credentials: ['ansible-server-ssh']) {
        //             sh """
        //             ssh -o StrictHostKeyChecking=no ${ANSIBLE_SERVER} 'cd ${ANSIBLE_DIR}/haproxy && ansible-playbook -i ${INVENTORY_HAPROXY_FILE} haproxy-playbook.yml --extra-vars "project=${params.project}"'
        //             """
        //         }
        //     }
        // }

        // stage('Run Keepalived Playbook') {
        //     when {
        //         allOf {
        //             expression { params.role == 'Keepalived' }
        //             expression { params.project == 'bvp' }
        //         }
        //     }
        //     steps {
        //         sshagent(credentials: ['ansible-server-ssh']) {
        //             sh """
        //             ssh -o StrictHostKeyChecking=no ${ANSIBLE_SERVER} 'cd ${ANSIBLE_DIR}/keepalived && ansible-playbook -i ${INVENTORY_KEEPALIVED_FILE} keepalived-playbook.yml --extra-vars "project=${params.project}"'
        //             """
        //         }
        //     }
        // }
    }
}

