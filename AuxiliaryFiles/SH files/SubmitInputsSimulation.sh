#!/bin/sh

echo "########################################"
echo "Starting at `date`"
echo "Current working directory is `pwd`"
echo "########################################"

# FolderArray=(1E-01 1E-02 1E-04 1E-06 1E-08 1E-10 1E-12 1E-14 1E-16 1E-18)
FolderArray=(1E-10)

RF='/ocean/projects/phy230019p/jrchreim/'

#SF=$RF'simulations/PhaseChange/1D/ShockTube/SimoesMoreira/SensibilityTests/'
SF=$RF'simulations/PhaseChange/2D/WaterCylinder/'

MFCFOLDER=$RF'MFC-JRChreim/'

cd $MFCFOLDER

ToS="simulation"

# loading the CPU (c) for Bridges2 (b). Modify according to your convenience
source ./mfc.sh load <<< $'b\nc'

# The @ symbol in the square brackets indicates that you are looping through all of the elements in the array. If you were to leave that out, only the first string in the array would be printed.
for f in ${FolderArray[@]}; do

	# Load any modules you might need then call your program here
	# ./mfc.sh run $SF"eps"$f"/STWCyleps$f.py" -e batch -p RM -N 4 -n 128 -t simulation -w 48:00:00 -b mpirun -# EPS$f
	./mfc.sh run $SF"eps"$f"/STWCyleps$f.py" -e batch -p RM -N 14 -n 128 -t $ToS -w 48:00:00 -b mpirun -# EPS$f$ToS

done

echo "########################################"
echo "Program finished with exit code $? at: `date`"
echo "########################################"
