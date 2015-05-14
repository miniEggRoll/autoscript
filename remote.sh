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
rm -rf travis-gce
