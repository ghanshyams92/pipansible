pipeline {
agent {
        kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: test-odu
spec:
  securityContext:
    runAsUser: 10000
    runAsGroup: 10000
  containers:
  - name: jnlp
    image: 'jenkins/jnlp-slave:4.3-4-alpine'
    args: ['\$(JENKINS_SECRET)', '\$(JENKINS_NAME)']
  - name: yair
    image: us.icr.io/dc-tools/security/yair:1
    command:
    - cat
    tty: true
    imagePullPolicy: Always
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug-1534f90c9330d40486136b2997e7972a79a69baf
    imagePullPolicy: Always
    command:
    - cat
    tty: true   
    securityContext: # https://github.com/GoogleContainerTools/kaniko/issues/681
      runAsUser: 0
      runAsGroup: 0
  - name: openshift-cli
    image: openshift/origin-cli:v3.11.0
    command:
    - cat
    tty: true
    securityContext: # https://github.com/GoogleContainerTools/kaniko/issues/681
      runAsUser: 0
      runAsGroup: 0
  - name: ansible-molecule
    image: quay.io/ansible/toolset
    command:
    - cat
    tty: true
    securityContext: # https://github.com/GoogleContainerTools/kaniko/issues/681
      runAsUser: 0
      runAsGroup: 0
  - name: terraform-cli
    image: gsaini05/terraform-az-go:0.15
    command:
    - cat
    tty: true
    securityContext: # https://github.com/GoogleContainerTools/kaniko/issues/681
      runAsUser: 0
      runAsGroup: 0
  volumes:
  - name: regsecret
    projected:
      sources:
      - secret:
          name: regsecret
          items:
            - key: .dockerconfigjson
              path: config.json
  imagePullSecrets:
  - name: oduregsecret
  - name: regsecret
"""
        }
    }
    environment {
      ROLE_NAME="ansibleapache"
    }
 stages {
    stage ('Unit Test') {
      steps {
        container('ansible-molecule') {
        sh '''
          docker -v
          python -V
          ansible --version
          molecule --version
          ansible-lint .
        '''
      }
    }
  }

    stage ('Integration test (Molecule (preview))') {
      steps {
        container('ansible-molecule') {
        sh """
           molecule init role -d docker $ROLE_NAME
           molecule init role -d azure $ROLE_NAME
           mv examples/molecule/rhel8/create.yml $ROLE_NAME/molecule/default/create.yml
           mv examples/molecule/rhel8/molecule.yml $ROLE_NAME/molecule/default/molecule.yml destroy.yml
           mv examples/molecule/rhel8/destroy.yml $ROLE_NAME/molecule/default/destroy.yml
           mv examples/molecule/rhel8/prepare.yml $ROLE_NAME/molecule/default/prepare.yml
           cd $ROLE_NAME/
           #molecule test --all
           """
      }
    }
   }
    stage ('SonarQube Scan') {
      steps {
        container('ansible-molecule') {
        sh """
           apt-get update
           apt-get install wget -y
           apt-get install unzip -y
           wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.2.2472-linux.zip
           unzip sonar-scanner-cli-4.6.2.2472-linux.zip
           mkdir /opt/sonar
           mv sonar-scanner-4.6.2.2472-linux /opt/sonar/
           export PATH=$PATH:/opt/sonar/sonar-scanner-4.6.2.2472-linux/bin
           mv sonarconf /opt/sonar/sonar-scanner-4.6.2.2472-linux/conf/sonar-scanner.properties
           cd $ROLE_NAME
           sonar-scanner
           """
        }
      }
    }  
      stage('Approval: Confirm/Abort') {
        steps {
          script {
            def userInput = input(id: 'confirm', message: 'Apply Ansible?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply Ansible', name: 'confirm'] ])
          }
        }
      }
    stage ('Configure/Deploy Resource') {
      steps {
        container('ansible-molecule') {
        sh 'ansible-playbook testplay.yaml'
        }
      }
    }       
  } // close stages
}   // close pipeline
