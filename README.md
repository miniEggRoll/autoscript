# travis-gce
Auto exec jobs/*/start.sh on merge

## environment setting in travis
- GIT_KEY
- BASTION_KEY
- BASTION_ACCOUNT
- BASTION_IP

## report.log
Report.log is generated for each job after execution. Only jobs without report.log will be exec.

## environment variables
All env var in stats.sh should have 'LC_' prefix like 'LC_MYSQL_HOST' and be saved in travis environment variable

## private key
Need double excape, that is
- replace space with '\\x20'
- replace new line with '\\n'

## notice
- Remember to remove every file execpt which are to be tracked in git.
