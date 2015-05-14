# travis-gce
auto exec jobs/*/start.sh on merge

## environment setting in travis
- GIT_KEY
- BASTION_KEY
- BASTION_ACCOUNT
- BASTION_IP

private key need double excape, that is
- replace space with '\\x20'
- replace new line with '\\n'
