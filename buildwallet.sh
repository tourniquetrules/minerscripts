#!/bin/bash

# Exit on error
set -e

# Get the current directory name
DIR_NAME=$(basename "$PWD")
export BDB_PREFIX="/home/tourniquetruels/${DIR_NAME}/db4"

# Display the export for confirmation
echo "BDB_PREFIX set to: $BDB_PREFIX"

# Run autogen.sh
echo "Running ./autogen.sh..."
./autogen.sh
echo "autogen.sh completed."

# Run Berkeley DB installer
echo "Running ./contrib/install_db4.sh..."
./contrib/install_db4.sh "$(pwd)"
echo "install_db4.sh completed."

# Run configure with BDB flags
echo "Running ./configure with BDB flags..."
./configure BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_CFLAGS="-I${BDB_PREFIX}/include"
echo "configure completed."

# Build with make
echo "Running make -j16..."
make -j16
echo "Build completed successfully."
