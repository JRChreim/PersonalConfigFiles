\#!/bin/sh

TypeOfEqArr=('p' 'pT' 'pTg')
FolderArr=(7E-02 40E-02 87E-02)
DiscrArr=(1200 2400 3600 4800 6000)

RF='/ocean/projects/phy230019p/jrchreim/simulations/PhaseChange/3D/BubbleCollapse/'
LF='restart_data/'

# frequency of saves for simulations
SF=400

# The @ symbol in the square brackets indicates that you are looping through all of the elements in the array. If you were to leave that out, only the first string in the array would be printed.
for ToE in ${TypeOfEqArr[@]}; do

	if [[ $ToE == 'p' ]]; then
		RelMod=4
		ptgalpha_eps=1.0E-5
	elif [[ $ToE == 'pT' ]]; then
		RelMod=5
		ptgalpha_eps=1.0E-5
	elif [[ $ToE == 'pTg' ]]; then
		RelMod=6
		ptgalpha_eps=1.0E-2
	fi

	for f in ${FolderArr[@]}; do
		for N in ${DiscrArr[@]}; do

			# simulation foldes
			FoldVar1=$RF"KM"$ToE"Eq/"C0$f"/"N$N"/"

			# Luster files folder
			RestFold=$FoldVar1$LF

			if [ ! -d $RestFold ]; then
				echo "Directory "$RestFold" does not exists"
			else
				# entering the luster files folder so that the lastest save can be found
				cd $RestFold

				# Iterate over each file matching the pattern
				max_number=0

				for file in lustre_*.dat; do
				    # Extract the number from the filename
				    number=$(echo "$file" | grep -oE '[0-9]+')

				    # Check if the extracted number is greater than the current maximum
				    if ((number > max_number)); then
				        max_number=$number
				    fi
				done

				# input file name
				IF=KM$ToE"C0"$f"N"$N""Restart.py

				echo $max_number/$SF

				# copying base file to specific input file
				cp $RF""BaseFileIMRRestart.py $FoldVar1$IF

				# this command change a specific variable value in the input file
				sed -i "s/\('relax_model'\s*:\s*\)[^,]*/\1"$RelMod"/" $FoldVar1""$IF
				sed -i "s/\('t_step_start'\s*:\s*\)[^,]*/\1"$max_number"/" $FoldVar1""$IF
				sed -i "s/\('ptgalpha_eps'\s*:\s*\)[^,]*/\1"$ptgalpha_eps"/" $FoldVar1""$IF
				sed -i 's/C0 = .*/C0 = '$f'/' $FoldVar1""$IF
				sed -i 's/Nx = .*/Nx = '$N'/' $FoldVar1""$IF
				sed -i 's/Ny = .*/Ny = '$N'/' $FoldVar1""$IF
				sed -i 's/Nz = .*/Nz = '$N'/' $FoldVar1""$IF
			fi
		done
	done
done

