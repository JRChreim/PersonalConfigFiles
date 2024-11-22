#!/bin/bash

# commands before exercution
clear

echo "########################################"
echo "Starting $0 at $(date)"
echo "Current working directory is $(pwd)"
echo "########################################"

## auxiliary functions ##

# Function to check for errors in the output file
check_simulation_errors() {
    local output_file="$1"  # The file to check (e.g., $IF.out)
    
    # Search for "ICFL" or "NAN" in the file
    if grep -qE "ICFL|NAN" "$output_file"; then
        echo "Error: Simulation failed. Found 'ICFL' or 'NAN' in $output_file."
        return 1  # Exit with a general failure code
    fi

    # If no errors are found
    echo "No errors detected in $output_file. Simulation can be submitted"
    return 0
}

# Function to get the highest number in the folder
get_highest_number() {
    local folder="$1"  # The first argument is the folder name
    local highest_number=0  # Default value

    if [ -d "$folder" ]; then
        # Get the list of files with numbers, sort them, and find the highest
        local files=($(ls "$folder" | grep -oE '[0-9]+' | sort -n))
        if [ ${#files[@]} -gt 0 ]; then
            highest_number="${files[-1]}"  # Assign the highest number if found
        fi
    fi

    echo "$highest_number"  # Return the highest number
}


# Function to check if a simulation is running using qstat
is_simulation_running() {
    local simulation_name=$1  # First argument: the simulation name to match
    local user_name=$USER     # Current user

    # Get the filtered list of jobs
    running_jobs=$(qstat -f | grep -E "Job_Name|Job Id|Job_Owner" | sed -E 's/(Job_Owner = [^@]+).*/\1/' | awk -v sim_name="$simulation_name" -v user="$user_name" '
    BEGIN {
        job_id = ""
        job_name = ""
        job_owner = ""
    }
    /Job Id/ {job_id = $3}
    /Job_Name/ {job_name = $3}
    /Job_Owner/ {job_owner = $3}
    {
        # If job_name matches simulation_name and job_owner matches user, print job details
        if (job_name == sim_name && job_owner ~ user) {
            print "Job_Id:", job_id, "Job_Name:", job_name, "Job_Owner:", job_owner
        }
    }')

    # If running_jobs is not empty, return success; otherwise, return failure
    [ -n "$running_jobs" ] && return 0 || return 1
}

# get maximum number of time-steps from input file
get_max_number() {
    max_number=$(python3 -c "
import sys
sys.path.insert(0, '.')
config = __import__('$(basename "$IF.py" .py)')
print(config.Nt)
" 2>/dev/null | tail -n 1)

    echo "$max_number"
}


# File Configuration
ToE='5'
ToR='pT'
C0=00E-00
N=9600
SF='/p/work/jrchreim/simulations/PhaseChange/3D/BubbleDynamics/WeakCollapse/'
AF='/p/home/jrchreim/AuxiliaryFiles/'

FoldVar="$SF$ToE""Eqn/KM$ToR""Eq/C0$C0/N$N/"
IF=KM$ToR"C0"$C0"N"$N

cd $FoldVar

# Attempt to get the max_number
max_number=$(get_max_number)

# Check if the max_number is empty (indicating an error)
if [ -z "$max_number" ]; then
    # If empty, attempt to fix the issue by setting 't_step_start' to a default value
    echo "Error encountered, modifying 't_step_start' in $FoldVar$IF.py so this information can be retrieved"

    # Use sed to set 't_step_start' to a default value (0) in case it's empty
    sed -i "s/'t_step_start' : ,/'t_step_start' : 0,/" "$FoldVar$IF.py"

    # Retry obtaining max_number
    max_number=$(get_max_number)

    # Check if we still couldn't get the value
    if [ -z "$max_number" ]; then
        echo "Error: Unable to retrieve max_number even after modifying the file."
        exit 1
    fi
fi

TSF=$(grep "'parallel_io'" $IF.py | awk -F':' '{print $2}' | tr -d ' ,')
TPPS=$(grep "'format'" $IF.py | awk -F':' '{print $2}' | tr -d ' ,')

# folder where simulation files are located
if [ $TSF = "T" ]; then
    SimFold=$FoldVar"restart_data/" 
else
    SimFold=$FoldVar"restart_data/"
fi

# folder where post_process files are located
if [ $TPPS -eq 1 ]; then
    PostFold=$FoldVar"silo_hdf5/root/"
else
    PostFold=$FoldVar"binary/root/"
fi

echo "Starting main logic"

cd $AF

## Main logic ##
if [ ! -d "$SimFold" ]; then
    
    # Folder does not exist: pre_process and start simulation

    echo "Folder $SimFold does not exist. Creating first input file, submitting pre_process, simulation, and post_process."

    cd $AF    
    
    ./EditMFCInputs.sh
    
    ./SubmitInputs.sh

    # now, making sure the simulation runs until it finishes
    highest_number=$(get_highest_number "$SimFold")

    while [ "$highest_number" -ne "$max_number" ]; do

        # Check if a simulation is already running
        if is_simulation_running "$IF"; then
            
            # Check every 60 seconds
            while is_simulation_running "$IF"; do
            
                echo "Simulation $IF is already running. Waiting for it to finish..."

                sleep 60  
            
            done
            
        fi  

        # if the simulation is not running, we submit it
        echo "Simulation $IF is not running. Checking for errors in the output file..."  
        
        check_simulation_errors "$IF.out"

        if [ $? -ne 0 ]; then
            echo "Stopping the script due to errors. Check your simulation parameters. Exiting..."
            exit 1  # Exit the main script
        else

            highest_number=$(get_highest_number "$SimFold")
            
            if [ "$highest_number" -ne "$max_number" ]; then 
                
                ReplaceInput="t_step_start:$highest_number" ./EditMFCInputs.sh

                echo "Submitting simulation..."

                ToSInput="simulation" ./SubmitInputs.sh

            fi
        fi
    done
else
    # if the simulation is not running, we submit it
    echo "Folder $FoldVar exists. Checking for errors in the output file..."  
    
    check_simulation_errors "$IF.out"

    if [ $? -ne 0 ]; then
        echo "Stopping the script due to errors. Check your simulation parameters. Exiting..."
        exit 1  # Exit the main script
    else
    
        echo "Checking post_process contents..."
        
        highest_number=$(get_highest_number "$PostFold")

        # checking if post_process is complete
        if [ "$highest_number" -eq "$max_number" ]; then
            
            echo "post_process complete. Finishing script"

        # if not, check if the simulation is complete
        else

            echo "post_process not complete. Cheking simulation contents..."

            highest_number=$(get_highest_number "$SimFold")

            # checking if the simulation is complete
            if [ "$highest_number" -eq "$max_number" ]; then

                echo "Simulation is complete. Submitting post_process"

                highest_number=$(get_highest_number "$PostFold")

                ReplaceInput="t_step_start:$highest_number" ./EditMFCInputs.sh
        
                # if yes, submit post_process
                ToSInput="post_process" ./SubmitInputs.sh

            # if not, submit simulation. This is where the loop enters
            else

                echo "Simulation not complete. It stopped at $highest_number, which is ~ $(awk "BEGIN {print $highest_number / $max_number}") of the total simulation."
                
                # enter a while loop to ensure the full simulation is running
                while [ "$highest_number" -ne "$max_number" ]; do

                    # Check if a simulation is already running
                    if is_simulation_running "$IF"; then
                        
                        # Check every 60 seconds
                        while is_simulation_running "$IF"; do
                        
                            echo "Simulation $IF is already running. Waiting for it to finish..."
                            
                            sleep 60  
                        
                        done
                        
                    fi  

                    # if the simulation is not running, we submit it
                    echo "Simulation $IF is not running. Checking for errors in the output file..."  
        
                    check_simulation_errors "$IF.out"

                    if [ $? -ne 0 ]; then
                        echo "Stopping the script due to errors. Check your simulation parameters. Exiting..."
                        exit 1  # Exit the main script
                    else

                        highest_number=$(get_highest_number "$SimFold")
                        
                        if [ "$highest_number" -ne "$max_number" ]; then 
                            
                            ReplaceInput="t_step_start:$highest_number" ./EditMFCInputs.sh

                            echo "Submitting simulation..."

                            ToSInput="simulation" ./SubmitInputs.sh

                        fi
                    fi
                done

                # after finishing the simulation, submit the post_process
                highest_number=$(get_highest_number "$PostFold")

                ReplaceInput="t_step_start:$highest_number" ./EditMFCInputs.sh

                ToSInput="post_process" ./SubmitInputs.sh

            fi
        fi
    fi
fi

echo "########################################"
echo "$0 finished with exit code $? at: $(date)"
echo "########################################"