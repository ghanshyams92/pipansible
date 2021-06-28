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
        container('ansible-molecule') {
        sh """
           molecule init role -d docker $ROLE_NAME
           mv main.yml $ROLE_NAME/tasks/main.yml
           mkdir  $ROLE_NAME/molecule/default/tests/
           mv test_default.py $ROLE_NAME/molecule/default/tests/test_default.py
           mv molecule.yml $ROLE_NAME/molecule/default/molecule.yml
           mv index.html.j2 $ROLE_NAME/templates/index.html.j2
           mv vars_main.yml $ROLE_NAME/vars/main.yml
           cd $ROLE_NAME/
           rm -rf meta/main.yml
           #molecule test --all
           ansible-lint .
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
    stage ('Configure Target Resource') {
      steps {
        container('ansible-molecule') {
        sh 'ansible-playbook testplay.yaml'
        }
      }
    }       
  } // close stages
}   // close pipeline
