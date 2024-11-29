#!/bin/bash

# Prompt the user for the number of cores to use
read -p "Enter the number of cores you want to use for building the crypto daemon: " cores

# Check if the input is a valid positive integer
if [[ "$cores" =~ ^[0-9]+$ && "$cores" -gt 0 ]]; then
    # Construct and display the make command
    make_command="make -j$cores"
    echo "Your make command is: $make_command"

    # Run the install_db4.sh script from the contrib directory and capture its output
    db4_output=$(./contrib/install_db4.sh `pwd`)

    # Extract the BDB_PREFIX value from the output
    BDB_PREFIX=$(echo "$db4_output" | grep -oP "export BDB_PREFIX='.*?'" | cut -d"'" -f2)

    # Check if BDB_PREFIX was successfully extracted
    if [[ -z "$BDB_PREFIX" ]]; then
        echo "Failed to extract BDB_PREFIX from install_db4.sh output."
        exit 1
    fi

    # Print the extracted BDB_PREFIX (for debugging purposes)
    echo "BDB_PREFIX extracted: $BDB_PREFIX"

    # Run the workflow commands
    echo "Running ./autogen.sh..."
    ./autogen.sh

    echo "Running ./configure with BDB settings..."
    ./configure BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_CFLAGS="-I${BDB_PREFIX}/include"

    echo "Running make command with $cores cores..."
    eval "$make_command"
else
    echo "Invalid input. Please enter a positive integer."
fi
