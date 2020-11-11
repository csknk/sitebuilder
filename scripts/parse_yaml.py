#!/usr/bin/env python3
import sys, os, yaml

def get_data(filename, key_list, **kwargs):
    """Return a value from a YAML object.
        Parameter:
            filename (str): Either a YAML file or file with YAML frontmatter
            key_list (list of str): List of key(s) to access value in hierarchically descending order
        Returns:
            data (str): The required YAML value
    """
    if not key_list:
        return
    project_dir = os.path.realpath('.')
    filepath = os.path.join(project_dir, filename)
    with open(filepath, "r") as f:
        data = next(yaml.load_all(f, Loader=yaml.FullLoader))
        for key in key_list: data = data.get(key)
        if not data:
            return
    if kwargs.get("return_type") == "stdout":
        # Output to stdout is necessary if setting a shell variable in the Makefile
        print(data)
    else:
        return data

def set_data(filename, key, value):
    """Set YAML value in frontmatter
        Parameter:
            filename (str): A file with YAML frontmatter
            key (str): The key to set
            value (str): The value
        Returns void.
    """
    project_dir = os.path.realpath('.')
    filepath = os.path.join(project_dir, filename)
    start_content = 0
    content = ""
    
    # Load frontmatter, set the required key, save into a string
    with open(filepath, "r") as f:
        data = next(yaml.load_all(f, Loader=yaml.FullLoader))
        data[key] = value
    data_string = "---\n{}---\n".format(yaml.dump(data))
    
    # Read the file content not including the Frontmatter block
    with open(filepath, "r") as f:
        for line in f:
            if line == "---\n":
                start_content += 1
                continue
            if start_content == 2:
                content += line

    # Write the new Frontmatter block, followed by the file contents
    with open(filepath, "w") as f:
        f.write(data_string)
        f.write(content)

if __name__ == '__main__':
    get_data(sys.argv[1], sys.argv[2:], return_type="stdout")
