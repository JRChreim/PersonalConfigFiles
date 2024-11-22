#!/bin/bash

echo "########################################"
echo "Starting $0 at $(date)"
echo "Current working directory is $(pwd)"
echo "########################################"

# Default values for the variables
ToEArr=('5')
ToRArr=('pT')
FoldArr=(00E-00)
DiscrArr=(9600)
SF='/p/work/jrchreim/simulations/PhaseChange/3D/BubbleDynamics/WeakCollapse/'
Acc=ONRDC48542612
ToS='pre_process simulation post_process'
eng='batch'
part='debug'
tasks=192
comp='carpenter'
MFCF='/p/home/jrchreim/MFC-JRChreim/'

# Overriding defaults with user inputs
ToEArr=(${ToEArrInput:-${ToEArr[@]}})
ToRArr=(${ToRArrInput:-${ToRArr[@]}})
FoldArr=(${FoldArrInput:-${FoldArr[@]}})
DiscrArr=(${DiscrArrInput:-${DiscrArr[@]}})
SF=${SFInput:-$SF}
Acc=${AccInput:-$Acc}
ToS=${ToSInput:-$ToS}
eng=${engInput:-$eng}
part=${partInput:-$part}
tasks=${tasksInput:-$tasks}
comp=${compInput:-$comp}
MFCF=${MFCFInput:-$MFCF}

# Determine walltime based on ToS
if [[ $ToS == "post_process" ]]; then
    walltime=00:20:00
elif [[ $ToS == "pre_process" ]]; then
    walltime=00:20:00
else
    walltime=01:00:00
fi

# Navigate to MFC folder
cd $MFCF

# Loop through all combinations of input arrays
for ToE in "${ToEArr[@]}"; do
	for ToR in "${ToRArr[@]}"; do
	    for f in "${FoldArr[@]}"; do
			for N in "${DiscrArr[@]}"; do

				# Determine the number of nodes based on N
				case $N in
					600) nodes=2 ;;
					2400 | 3600) nodes=6 ;;
					4800) nodes=8 ;;
					6000) nodes=10 ;;
					9600) nodes=20 ;;
					*) echo "Unknown value for N: $N"; exit 1 ;;
				esac

				FoldVar="$SF$ToE""Eqn/KM$ToR""Eq/C0$f/N$N/"

				# Input file name
				IF="KM$ToR""C0$f""N$N"
				./mfc.sh run "$FoldVar""$IF.py" -c $comp -a $Acc -e $eng -p $part -N $nodes -n $tasks -t $ToS -w $walltime -# $IF
			done
	    done
	done
done

echo "########################################"
echo "$0 finished with exit code $? at: $(date)"
echo "########################################"
