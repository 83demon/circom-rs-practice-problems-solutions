#!/bin/bash

# Exit immediately if any command fails
set -e

# Determine the absolute path to the project root (one level up from this script)
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")

# Move to project root so paths like build/ and inputs/ work correctly
cd "$PROJECT_ROOT"

# Check if the user provided an input path
if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_circom_file>"
    echo "Example: $0 circuits/multiplier.circom"
    exit 1
fi

CIRCOM_PATH="$1"

# Verify the circuit file exists
if [ ! -f "$CIRCOM_PATH" ]; then
    echo "Error: Circuit file '$CIRCOM_PATH' not found."
    exit 1
fi

# Extract the filename without the path and extension
BASENAME=$(basename "$CIRCOM_PATH")
FILENAME="${BASENAME%.*}"

# Define standard paths
BUILD_DIR="build/$FILENAME"
LOG_FILE="$BUILD_DIR/execution.log"
INPUT_JSON="inputs/$FILENAME.json"
PTAU_FILE="pot12_final.ptau"

# Pre-execution checks
if [ ! -f "$INPUT_JSON" ]; then
    echo "Error: Input file '$INPUT_JSON' not found. Please create it before running."
    exit 1
fi

if [ ! -f "$PTAU_FILE" ]; then
    echo "Error: Powers of Tau file '$PTAU_FILE' not found in the current directory."
    exit 1
fi

echo "=> Preparing build directory: $BUILD_DIR"

if [ -d "$BUILD_DIR" ]; then
    echo "   Found existing directory, wiping..."
    rm -r "$BUILD_DIR"
fi

mkdir -p "$BUILD_DIR"

# Initialize the log file
touch "$LOG_FILE"
echo "=> Standard execution logs will be written to $LOG_FILE"

echo "=> 1/7 Compiling circuit..."
circom "$CIRCOM_PATH" --r1cs --wasm -o "$BUILD_DIR" >> "$LOG_FILE" 2>&1

echo "=> 2/7 Generating witness..."
node "$BUILD_DIR/${FILENAME}_js/generate_witness.js" \
     "$BUILD_DIR/${FILENAME}_js/${FILENAME}.wasm" \
     "$INPUT_JSON" \
     "$BUILD_DIR/witness.wtns" >> "$LOG_FILE" 2>&1

echo "=> 3/7 Running groth16 setup..."
snarkjs groth16 setup "$BUILD_DIR/${FILENAME}.r1cs" "$PTAU_FILE" "$BUILD_DIR/${FILENAME}_0000.zkey" >> "$LOG_FILE" 2>&1

echo "=> 4/7 Contributing to phase 2 (Interactive)..."
# We use 'tee -a' here so the prompt for random entropy is visible to you in the terminal,
# but the output is still accurately recorded in the log file.
snarkjs zkey contribute "$BUILD_DIR/${FILENAME}_0000.zkey" "$BUILD_DIR/${FILENAME}_0001.zkey" \
    --name="1st Contributor Name" -v 2>&1 | tee -a "$LOG_FILE"

echo "=> 5/7 Exporting verification key..."
snarkjs zkey export verificationkey "$BUILD_DIR/${FILENAME}_0001.zkey" "$BUILD_DIR/verification_key.json" >> "$LOG_FILE" 2>&1

echo "=> 6/7 Generating proof..."
snarkjs groth16 prove "$BUILD_DIR/${FILENAME}_0001.zkey" "$BUILD_DIR/witness.wtns" "$BUILD_DIR/proof.json" "$BUILD_DIR/public.json" >> "$LOG_FILE" 2>&1

echo "=> 7/7 Verifying proof (Output routed to terminal only)..."
# This is the final command; per your instructions, we do not log this output.
snarkjs groth16 verify "$BUILD_DIR/verification_key.json" "$BUILD_DIR/public.json" "$BUILD_DIR/proof.json"

echo "=> Process Complete!"
