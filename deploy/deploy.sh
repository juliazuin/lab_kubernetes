#!/bin/bash

ANSIBLE_OUT=$(ansible-playbook -i ~/projetos/lab_kubernetes/deploy/ansible/hosts ~/projetos/lab_kubernetes/deploy/ansible/deployar.yml -u ubuntu --private-key ~/.ssh/id_rsa)
echo $ANSIBLE_OUT

MYSQL_POD_NAME=$(echo $ANSIBLE_OUT | grep -oE "(mysql-.*? )" )

cat <<EOF > restore-dump-mysql.yml
- hosts: all
  become: yes
  tasks:
    - name: "Create dabatase"
      shell: echo "create database SpringWebYoutubeTest;"| kubectl exec -it $MYSQL_POD_NAME --tty -- mysql -uroot -ppassword_mysql 
    
    - name: "Restore dump"
      shell: cat /root/k8s-deploy/1.2-dump-mysql.sql  | kubectl exec -it $MYSQL_POD_NAME --tty -- mysql -uroot -ppassword_mysql SpringWebYoutubeTest
EOF

ansible-playbook -i ~/projetos/lab_kubernetes/deploy/ansible/hosts ~/projetos/lab_kubernetes/deploy/ansible/dump_mysql.yml -u ubuntu --private-key ~/.ssh/id_rsa