#!/bin/sh

echo "########################################"
echo "Starting at `date`"
echo "Current working directory is `pwd`"
echo "########################################"

# simulation set up.
#TypeOfEqArr=('p')
#FolderArr=(7E-02 40E-02 87E-02)
#DiscrArr=(1200 2400 3600 6000)

TypeOfEqArr=('pTg')
FolderArr=(1E-00)
DiscrArr=(9600)

RF='/scratch/bbua/jrchreim/'

SF=$RF'simulations/PhaseChange/3D/BubbleCollapse/'

MFCFOLDER=$RF'MFC-GPU/'

ToS="post_process"
#ToS="simulation"
NameOut=$(echo $ToS | tr -d ' ')
eng="batch"
comp=delta

if [[ $ToS == "simulation" ]]; then
	walltime=48:00:00
else
	walltime=12:00:00
fi

cd $MFCFOLDER

# loading the CPU (c) for Bridges2 (b). Modify according to your convenience
# source ./mfc.sh load <<< $'d\ng'

# The @ symbol in the square brackets indicates that you are looping through all of the elements in the array. If you were to leave that out, only the first string in the array would be printed.
for ToE in ${TypeOfEqArr[@]}; do
	for f in ${FolderArr[@]}; do
		for N in ${DiscrArr[@]}; do

			FoldVar1=$SF"KM"$ToE"Eq/"C0$f"/"N$N"/"

                        # input file name
#                        IF=KM$ToE"C0"$f"N"$N""Restart
			IF=KM$ToE"C0"$f"N"$N
			if [[ $ToS == "simulation" ]]; then
				if [[ $N == 1200 ]]; then
					nodes=1
				elif [[ $N == 2400 ]]; then
					nodes=1
				elif [[ $N == 3600 ]]; then
					nodes=1
				elif [[ $N == 4800 ]]; then
					nodes=1
				elif [[ $N == 6000 ]]; then
					nodes=1
				elif [[ $N == 9600 ]]; then
					nodes=4
				fi
				account=bbua-delta-gpu
				tasks=4
				part=gpuA100x4
				./mfc.sh run $FoldVar1""$IF.py -c $comp -a $account -e $eng -p $part -N $nodes -n $tasks -t $ToS -w $walltime -# $IF$NameOut
			else
				if [[ $N == 1200 ]]; then
					nodes=1
				elif [[ $N == 2400 ]]; then
					nodes=2
				elif [[ $N == 3600 ]]; then
					nodes=3
				elif [[ $N == 4800 ]]; then
					nodes=5
				elif [[ $N == 6000 ]]; then
					nodes=5
				elif [[ $N == 9600 ]]; then
					nodes=8
				fi
				account=bbua-delta-cpu
				tasks=128
				part=cpu
				./mfc.sh run $FoldVar1""$IF.py -c $comp -a $account -e $eng -p $part -N $nodes -n $tasks -t $ToS -w $walltime -# $IF$NameOut
			fi

		done
	done
done


echo "########################################"
echo "Program finished with exit code $? at: `date`"
echo "########################################"
