git clone git@github.com:minieggroll/travis-gce
cd travis-gce/jobs
for VARIABLE in `find . -maxdepth 1 -mindepth 1 -type d \! -exec test -e '{}/report.log' \; -print`
do
    cd $VARIABLE
    sh start.sh > report.log
    cd ..
done
cd ..
touch .git/config
git config --local user.name "travis-aftersuccess"
git add .
git commit -m 'auto exec' 
git push
cd ..
sudo rm -rf travis-gce
docker ps -a | grep Exited | awk '{print $1}' | xargs docker rm
docker images | grep none | awk '{print $3}' | xargs docker rmi
