# Open the file in read mode with UTF-8 encoding
with open('lattice_ariane.sv', 'r', encoding='utf-8') as file:
    # Read the contents of the file
    file_contents = file.read()

# Replace the target string
file_contents = file_contents.replace("unsigned'", "$unsigned")

# Open the file in write mode with UTF-8 encoding to save the changes
with open('lattice_ariane.sv', 'w', encoding='utf-8') as file:
    # Write the modified contents back to the file
    file.write(file_contents)

print("Replacement complete!")
