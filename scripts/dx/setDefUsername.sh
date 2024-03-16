if [ $# -lt 1 ]
then
    echo Usage: setDefUsername.sh username
    exit
fi
sfdx config:set defaultusername=$1