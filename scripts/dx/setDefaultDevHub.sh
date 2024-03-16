if [ $# -lt 1 ]
then
    echo Usage: setDefaultDevHub.sh alias
    exit
fi

sfdx force:config:set defaultdevhubusername=$1
