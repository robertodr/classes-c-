#! /bin/bash
# Script for which build and runs all test

RED='\033[0;31m' # Red
BB='\033[0;34m'  # Blue
NC='\033[0m' # No Color
BG='\033[0;32m' # Green

error() { >&2 echo -e "${RED}$1${NC}"; }
showinfo() { echo -e "${BG}$1${NC}"; }
workingprocess() { echo -e "${BB}$1${NC}"; }
allert () { echo -e "${RED}$1${NC}"; }

# Building project
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Debug ..
make -j8
# Checks if last comand didn't output 0
# $? checks what last command outputed
# If output is 0 then command is succesfuly executed
# If command fails it outputs number between 0 to 255
if [ $? -ne 0 ]; then
    error "Error: there are compile errors!"
	# Terminate script and outputs 3
    exit 3
fi

showinfo "Running tests ..."
make -j8 Polynomial_coverage
../bin/tests
if [ $? -ne 0 ]; then
    error "Error: there are failed tests!"
    exit 4
fi

# Checks coding style
# Coding style is addopted by google c++ standarts
# find finds all files that ends with cpp or hpp extenstion
# xarg executes every output from find
cd ..
find -regex '\./\(src\|test\)\/.*\.\(cpp\|hpp\)' | xargs -n 1  -P 8 python2 cpplint.py --filter=-legal,-whitespace/tab

if [ $? -ne 0 ]; then
    error "Error: Failed style check!"
    exit 5
fi


workingprocess "All tests compile and pass."

# Cleaning build directory
#cd ../
#rm -rf build/
