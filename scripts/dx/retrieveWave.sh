if [ $# -lt 1 ]
then
    echo Usage: retrieveWave.sh org alias
    exit
fi
sfdx force:source:retrieve -u $1 -m "WaveApplication, WaveDashboard, WaveDataflow, WaveDataset, WaveLens, WaveRecipe, WaveTemplateBundle, WaveXmd"