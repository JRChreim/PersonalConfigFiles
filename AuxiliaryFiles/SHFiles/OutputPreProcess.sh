#!/bin/sh

#TypeOfEqArr=('p')
#FolderArr=(7E-02 40E-02 87E-02)
#DiscrArr=(1200 2400 3600 4800 6000 9600)

#TypeOfEqArr=('pTg')
#FolderArr=(7E-02 40E-02 87E-02)
#DiscrArr=(9600)

TypeOfEqArr=('p' 'pT' 'pTg')
FolderArr=(0E-02 1E-00)
DiscrArr=(1200 2400 3600 4800 6000 9600)

# what to display
WTD="simulation"
WTD=""

RF='/scratch/bbua/jrchreim/simulations/PhaseChange/3D/BubbleCollapse/'

# The @ symbol in the square brackets indicates that you are looping through all of the elements in the array. If you were to leave that out, only the first string in the array would be printed.
clear
for ToE in ${TypeOfEqArr[@]}; do
	for f in ${FolderArr[@]}; do
		for N in ${DiscrArr[@]}; do

			FoldVar1=$RF"KM"$ToE"Eq/"C0$f"/"N$N"/"

			if [ ! -d $FoldVar1 ]; then
				echo "no output to display"
			else
				ls $FoldVar1*$WTD.out
			fi
		done
	done
done
