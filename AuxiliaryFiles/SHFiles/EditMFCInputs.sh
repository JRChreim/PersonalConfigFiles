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

# Overriding defaults with user inputs
ToEArr=(${ToEArrInput:-${ToEArr[@]}})
ToRArr=(${ToRArrInput:-${ToRArr[@]}})
FoldArr=(${FoldArrInput:-${FoldArr[@]}})
DiscrArr=(${DiscrArrInput:-${DiscrArr[@]}})
SF=${SFInput:-$SF}
ReplaceInput=${ReplaceInput:-""}  # Default to an empty string if not provided
# Example: ReplaceInput="relax_model:4 ptgalpha_eps:1.0E-5 C0:00E-00 Nx:9600 Ny:9600 Nz:9600"

# Parse replacements into an array
IFS=' ' read -r -a Replacements <<< "$ReplaceInput"

# The @ symbol in the square brackets indicates that you are looping through all of the elements in the array. If you were to leave that out, only the first string in the array would be printed.
for ToE in "${ToEArr[@]}"; do
	for ToR in ${ToRArr[@]}; do

	    if [[ $ToR == 'p' ]]; then
			RelMod=4
			ptgalpha_eps=1.0E-5
	    elif [[ $ToR == 'pT' ]]; then
			RelMod=5
			ptgalpha_eps=1.0E-5
	    elif [[ $ToR == 'pTg' ]]; then
			RelMod=6
			ptgalpha_eps=1.0E-2
	    fi

	    for f in ${FoldArr[@]}; do
			for N in ${DiscrArr[@]}; do
				FoldVar="$SF$ToE""Eqn/KM$ToR""Eq/C0$f/N$N/"

				if [ ! -d $FoldVar ]; then
					mkdir -p $FoldVar
				else
					echo "Directory "$FoldVar" already exists."
				fi

				IF=KM$ToR"C0"$f"N"$N
				cp $SF$ToE"Eqn/BaseFileIMR.py" $FoldVar""$IF.py

				if [ -n "$ReplaceInput" ]; then  # Only proceed if ReplaceInput is not empty
					for replace_pair in $ReplaceInput; do
						key=${replace_pair%%:*}  # Extract the key (before the colon)
						value=${replace_pair##*:}  # Extract the value (after the colon)

						# Replace the value with the new value from ReplaceInput, keeping the comma
						sed -i "s/\('$key'\s*:\s*\)[^,]*\s*,/\1$value,/" "$FoldVar$IF.py"
					done
				fi

				# Add predefined replacements (optional)
				sed -i 's/C0 = .*/C0 = '$f'/' $FoldVar""$IF.py
				sed -i 's/Nx = .*/Nx = '$N'/' $FoldVar""$IF.py
				sed -i 's/Ny = .*/Ny = '$N'/' $FoldVar""$IF.py
				sed -i 's/Nz = .*/Nz = '$N'/' $FoldVar""$IF.py

			done
	    done
	done
done

echo "########################################"
echo "$0 finished with exit code $? at: $(date)"
echo "########################################"
