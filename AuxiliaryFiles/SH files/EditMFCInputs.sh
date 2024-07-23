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


RF='/scratch/bbua/jrchreim/simulations/PhaseChange/3D/BubbleCollapse/'

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

			FoldVar1=$RF"KM"$ToE"Eq/"C0$f"/"N$N"/"

			if [ ! -d $FoldVar1 ]; then
				mkdir -p $FoldVar1
			else
				echo "Directory "$FoldVar1" already exists."
			fi

			IF=KM$ToE"C0"$f"N"$N.py
			cp $RF""BaseFileIMR.py $FoldVar1""$IF

			# this command change a specific variable value in the input file
			sed -i "s/\('relax_model'\s*:\s*\)[^,]*/\1"$RelMod"/" $FoldVar1""$IF
			sed -i "s/\('ptgalpha_eps'\s*:\s*\)[^,]*/\1"$ptgalpha_eps"/" $FoldVar1""$IF
			sed -i 's/awv2 = .*/awv2 = '$f'/' $FoldVar1""$IF
			sed -i 's/Nx = .*/Nx = '$N'/' $FoldVar1""$IF
			sed -i 's/Ny = .*/Ny = '$N'/' $FoldVar1""$IF
			sed -i 's/Nz = .*/Nz = '$N'/' $FoldVar1""$IF
		done
	done
done
