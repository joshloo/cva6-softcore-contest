
import os

# Function to process each line and amend "a", newline, string, newline "b"
def process_line(line):
    if line.strip() == "":
        return ""
    return f"  <file encryption=\"0\" type=\"verilog\" path=\"../../../../{line.strip()}\" /> \n"

# Function to find the file by traversing up the directory tree
def find_file(filename, max_levels=4):
    current_dir = os.path.abspath('.')
    for _ in range(max_levels):
        potential_path = os.path.join(current_dir, filename)
        if os.path.isfile(potential_path):
            return potential_path
        current_dir = os.path.dirname(current_dir)
    return None

# Find the Flist.ariane file
file_path = find_file('Flist.ariane')

if file_path:
    # Read the content of the input file
    with open(file_path, 'r') as infile:
        lines = infile.readlines()

    # Process each line (ignoring the first 20 lines) and write to the output file
    output_file_path = os.path.join(os.path.dirname(__file__), 'output.txt')
    with open(output_file_path, 'w') as outfile:
        for line in lines[20:]:
            processed_line = process_line(line)
            if processed_line:
                outfile.write(process_line(line))

    print("Processing complete. Check the output.txt file for results.")
else:
    print("Flist.ariane file not found within the specified directory levels.")
