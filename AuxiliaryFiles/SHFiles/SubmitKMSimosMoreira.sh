#!/bin/bash

echo "########################################"
echo "Starting at `date`"
echo "Current working directory is `pwd`"
echo "########################################"


TypeOfEqArr=('5Eqn')
FolderArr=(453 473 489 503 523 543 563 573)

SF='/disk/simulations/PhaseChange/Publication/N-Dodecane/pTg/'

MFCFOLDER='/home/user/Documents/GitHub/MFC-JRChreim/'

ToS="post_process"
NameOut=$(echo $ToS | tr -d ' ')
comp=delta
nodes=1
tasks=6

cd $MFCFOLDER

# The @ symbol in the square brackets indicates that you are looping through all of the elements in the array. If you were to leave that out, only the first string in the array would be printed.
for ToE in ${TypeOfEqArr[@]}; do
	for f in ${FolderArr[@]}; do

		IF=T$f""KAbgrall

		FoldVar1=$SF""$ToE"/"$IF"/"

		./mfc.sh run $FoldVar1""$IF.py -j $tasks -N $nodes -n $tasks -t $ToS -# $IF$NameOut
	done
done
echo "########################################"
echo "Starting at `date`"
echo "########################################"
