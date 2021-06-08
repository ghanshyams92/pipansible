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

 stages {

    stage ('Display versions') {
      steps {
        container('ansible-molecule') {
        sh '''
          docker -v
          python -V
          ansible --version
          molecule --version
        '''
      }
    }
  }

    stage ('Molecule test') {
      steps {
        checkout([$class: 'GitSCM', branches: [[name: 'master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'github', url: 'https://github.com/ghanshyams92/pipansible.git']]])
         
        container('ansible-molecule') {
        sh """
           sleep 2
           pwd
           whoami
           molecule init role -d docker ansible-apache
           mv main.yml ansible-apache/tasks/main.yml
           mkdir  ansible-apache/molecule/default/tests/
           mv test_default.py ansible-apache/molecule/default/tests/test_default.py
           mv molecule.yml ansible-apache/molecule/default/molecule.yml
           mv index.html.j2 ansible-apache/templates/index.html.j2
           mv vars_main.yml ansible-apache/vars/main.yml
           cd ansible-apache/
           molecule test --all
           """
      }
    }
   }
    stage ('Security Smell') {
      steps {
        container('ansible-molecule') {
        sh 'echo "EXPLORING Security smell"'
        }
      }
    }        
  } // close stages
}   // close pipeline
