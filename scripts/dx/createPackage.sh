
echo creating package: $1
#sfdx force:package:create -t Unlocked -r $1 -n $2 --orgdependent
sfdx force:package:create -t Unlocked -r foundation-code                    -n code                 --orgdependent
sfdx force:package:create -t Unlocked -r foundation-objs                    -n objs                 --orgdependent
sfdx force:package:create -t Unlocked -r foundation-functional              -n functional           --orgdependent
sfdx force:package:create -t Unlocked -r foundation-process                 -n process              --orgdependent
sfdx force:package:create -t Unlocked -r foundation-exceptionHandling       -n exceptionHandling    --orgdependent
sfdx force:package:create -t Unlocked -r foundation-label                   -n label                --orgdependent
# Future Implementation
sfdx force:package:create -t Unlocked -r ea                                 -n ea                   --orgdependent
sfdx force:package:create -t Unlocked -r foundation-batchFailureFramework   -n batch                --orgdependent
