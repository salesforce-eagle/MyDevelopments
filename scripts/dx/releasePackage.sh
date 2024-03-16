if [ $# -lt 1 ]
then
    echo Usage: releasePck.sh packageId ie ea@0.1.0-2
    exit
fi
echo releasing package: $1
sfdx force:package:version:promote --package $1
sfdx force:package:version:report --package  $1