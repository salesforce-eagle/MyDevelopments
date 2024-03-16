if [ $# -lt 1 ]
then
    echo Usage: createPkgOrgDep.sh packageName
    exit
fi
echo creating package: $1
sfdx force:package:version:create --package $1 --installation-key Sscdre1p --wait 10