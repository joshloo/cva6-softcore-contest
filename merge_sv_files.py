import os
import chardet

def detect_encoding(file_path):
    with open(file_path, 'rb') as f:
        result = chardet.detect(f.read())
    return result['encoding']

def merge_sv_files(input_dirs, output_file):
    with open(output_file, 'w', encoding='utf-8') as outfile:
        for input_dir in input_dirs:
            for root, _, files in os.walk(input_dir):
                for filename in files:
                    if filename.endswith('.sv'):
                        print(filename)
                        file_path = os.path.join(root, filename)
                        encoding = detect_encoding(file_path)
                        with open(file_path, 'r', encoding=encoding) as infile:
                            outfile.write(f"// {file_path}\n")
                            outfile.write(infile.read())
                            outfile.write("\n\n")

if __name__ == "__main__":
    input_directories = ['core', 'corev_apu']
    output_filename = 'merged_systemverilog.sv'
    merge_sv_files(input_directories, output_filename)
    print(f"All SystemVerilog files have been merged into {output_filename}")
