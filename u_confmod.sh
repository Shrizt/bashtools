#!/bin/bash
#modify config file settings, make .bak before
#usefull to make pre-defined massive config file adjustments described in input chg_file
#by Unc 2023-07

#sample chg_file:
# Define the parameters and values to look up and set and to_disable (#comment)
### parameters=("PermitRootLogin" "Port" "PrintMotd" "newParam")
### values=("no" "3322" "yes" "new")
### to_disable=("newParam")

# Define the filename of the SSH server configuration file
### config_file="/etc/ssh/sshd_config"


# Check if the external configuration file is provided as a command-line parameter
if [ $# -ne 1 ]; then
    echo "config file modder by Unc"
    echo "Usage: $0 <chg_file>"
    echo "The <chg_file> should contain the following arrays:"
    echo "parameters=(\"PermitRootLogin\" \"Port\")"
    echo "values=(\"no\" \"3322\")"
    echo "to_disable=(\"PasswordAuthentication\")"
    echo "and target filename config_file=./file.conf"
    exit 1
fi

# Read the external configuration file
config_file="$1"
source "$config_file"

# Create a backup copy of the original file
cp -f "$config_file" "$config_file.bak"

# Function to modify the SSH server configuration file
u_modify_file() {
    # Loop through the parameters and values
    for ((i=0; i<${#parameters[@]}; i++)); do
        parameter="${parameters[$i]}"
        value="${values[$i]}"
        
        # Check if the parameter exists in the file
        if grep -q "^#*$parameter" "$config_file"; then
            # If it exists, replace the value
	    echo "Replace parameter $parameter=$value"
            sed -i "s/^#*$parameter.*/$parameter $value/" "$config_file"
        else
            # If it doesn't exist, add the parameter with the value
	    echo "Add new parameter $parameter=$value"
            echo "$parameter $value" >> "$config_file"
        fi
    done

    # Loop through the parameters to disable
    for parameter in "${to_disable[@]}"; do
        # Check if the parameter exists in the file
        if grep -q "^$parameter" "$config_file"; then
            # If it exists, comment the line
            echo "parameter $parameter comment/disable(#)"
	    sed -i "s/^$parameter/#$parameter/" "$config_file"
	    
	else
	    echo "to_disable $parameter not found"
        fi
    done
}

u_modify_file

echo "script finished"
