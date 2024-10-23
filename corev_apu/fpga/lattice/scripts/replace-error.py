import re

# Function to concatenate multi-line $error statements
def concatenate_errors(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        lines = file.readlines()

    concatenated_lines = []
    error_buffer = []

    for line in lines:
        if "$error" in line:
            error_buffer.append(line.rstrip())
            if line.rstrip().endswith(";"):
                concatenated_lines.append(" ".join(error_buffer))
                error_buffer = []
        else:
            if error_buffer:
                error_buffer.append(line.rstrip())
                if line.rstrip().endswith(";"):
                    concatenated_lines.append(" ".join(error_buffer))
                    error_buffer = []
            else:
                concatenated_lines.append(line.rstrip())

    # Write the concatenated lines back to the file
    with open(file_path, 'w', encoding='utf-8') as file:
        for line in concatenated_lines:
            file.write(line + '\n')

    print("Concatenation complete!")

# Replace 'lattice_ariane.sv' with your file path
concatenate_errors('lattice_ariane.sv')
