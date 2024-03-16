    read -p 'Package Id: ' pckgid
    read -sp 'Org alias: ' orgid

    read -p "Do you want to install this package in "$orgid" Org?" yn
    case $yn in
        [Yy]* ) sfdx force:package:install -p $pckgid -u $orgid -a package -k Sscdre1p; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer y or n.";;
    esac