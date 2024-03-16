set -o errexit

if [ $# -lt 1 ]
then
    echo Usage: xOpen.sh alias
    exit
fi

# create scratch org
sfdx force:org:open -u $1
