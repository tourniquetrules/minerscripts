#!/bin/bash

# Prompt the user for the number of cores to use
read -p "Enter the number of cores you want to use for building the crypto daemon: " cores
chmod +x /contrib/install_db4.sh
./contrib/install_db4.sh `pwd`
export BDB_PREFIX='/root/medusa/Blockchain/db4'
# Check if the input is a valid positive integer
if [[ "$cores" =~ ^[0-9]+$ && "$cores" -gt 0 ]]; then
    # Construct and display the make command
    make_command="make -j$cores"
    echo "Your make command is: $make_command"
    
    # Run the workflow commands
    echo "Running ./autogen.sh..."
    ./autogen.sh

    echo "Running ./configure..."
    ./configure BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_MMCAGS="-I${BDB_PREFIX}/include"

    echo "Running make command with $cores cores..."
    eval "$make_command"
else
    echo "Invalid input. Please enter a positive integer."
fi

