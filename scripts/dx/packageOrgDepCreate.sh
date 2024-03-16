if [ $# -lt 1 ]
then
    echo Usage: createPkgOrgDep.sh packageName
    exit
fi
echo creating package: $1
sfdx force:package:create -t Unlocked -r force-app -n $1 --orgdependent