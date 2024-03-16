if [ $# -lt 2 ]
then
    echo Usage: createPkgOrgDep.sh packageName versionNumber ie 1.1.0.1
    exit
fi
echo creating package: $1
sfdx force:package:version:create --package $1 --installation-key Sscdre1p --wait 10 -n $2

# version uses this format 1.1.0.1