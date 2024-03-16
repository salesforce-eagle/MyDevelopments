set -o errexit

if [ $# -lt 1 ]
then
    echo Usage: createScratch.sh alias
    exit
fi

# create scratch org
sfdx force:org:create -s -f config/project-scratch-def.json -d 30 -a $1;

# push the code
sfdx force:source:push;