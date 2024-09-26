import os
import chardet

def detect_encoding(file_path):
    with open(file_path, 'rb') as f:
        result = chardet.detect(f.read())
    return result['encoding']

def merge_sv_files(file_list_path, output_file):
    with open(output_file, 'w', encoding='utf-8') as outfile:
        with open(file_list_path, 'r', encoding='utf-8') as file_list:
            for line in file_list:
                # Split the line by double quotes and filter out empty strings
                file_paths = [path.strip() for path in line.split('"') if path.strip()]
                for file_path in file_paths:
                    print(file_path)
                    if os.path.exists(file_path) and file_path.endswith('.sv'):
                        encoding = detect_encoding(file_path)
                        with open(file_path, 'r', encoding=encoding) as infile:
                            outfile.write(f"// {file_path}\n")
                            outfile.write(infile.read())
                            outfile.write("\n\n")

if __name__ == "__main__":
    file_list_path = 'file_list.txt'
    output_filename = 'merged_systemverilog.sv'
    merge_sv_files(file_list_path, output_filename)
    print(f"Selected SystemVerilog files have been merged into {output_filename}")
