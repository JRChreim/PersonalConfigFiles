#!/bin/bash

TypeOfEqArr=('5Eqn' '6Eqn')
FolderArr=(453 473 489 503 523 543 563 573)
pArr=(1.5E+05 2.2E+05 3.0E+05 3.9E+05 5.0E+05 7.5E+05 11E+05 13E+05)

# The @ symbol in the square brackets indicates that you are looping through all of the elements in the array. If you were to leave that out, only the first string in the array would be printed.
for ToE in ${TypeOfEqArr[@]}; do

	BF='/disk/simulations/PhaseChange/Publication/N-Dodecane/pTg/'
	RF=$BF""$ToE'/'

        if [[ $ToE == '5Eqn' ]]; then
                RelMod=2
        elif [[ $ToE == '6Eqn' ]]; then
                RelMod=3
        fi

	for f in ${!FolderArr[@]}; do

		FoldVar=$RF"T"${FolderArr[$f]}"KAbgrall"/

		if [ ! -d $FoldVar ]; then
			mkdir -p $FoldVar
		else
			echo "Directory "$FoldVar" already exists."
		fi

		IF="T"${FolderArr[$f]}"KAbgrall".py

		cp $BF""BaseFile.py $FoldVar""$IF

		# this command change a specific variable value in the input file
		sed -i "s/\('model_eqns'\s*:\s*\)[^,]*/\1"$RelMod"/" $FoldVar""$IF
		sed -i 's/T = .*/T = '${FolderArr[$f]}.15'/' $FoldVar""$IF
		sed -i 's/p02 = .*/p02 = '${pArr[$f]}'/' $FoldVar""$IF
	done
done
