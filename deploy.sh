echo -e "Host *\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config

echo -e "$BASTION_KEY" > ~/.ssh/id_rsa_gce
echo -e "$GIT_KEY" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa_gce 
chmod 600 ~/.ssh/id_rsa

eval `ssh-agent -s`
ssh-add ~/.ssh/id_rsa

ssh $BASTION_ACCOUNT@$BASTION_IP -A -i ~/.ssh/id_rsa_gce 'bash -s' < remote.sh
