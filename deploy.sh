echo -e "$BASTION_KEY" > ~/.ssh/id_rsa
echo -e "Host *\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
chmod 600 ~/.ssh/id_rsa
eval `ssh-agent -s`
ssh-add ~/.ssh/id_rsa
ssh $BASTION_ACCOUNT@$BASTION_IP -i ~/.ssh/id_rsa 'bash -s' < remote.sh
