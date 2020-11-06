#!/usr/bin/env python3
import sys, os, yaml

def main(filename, key_list):
    """Return a value from a YAML object.
        Parameter:
            filename (str): Either a YAML file or file with YAML frontmatter
            key_list (list of str): List of key(s) to access value in hierarchically descending order
        Returns:
            data (str): The required YAML value
    """
    project_dir = os.path.realpath('.')
    filepath = os.path.join(project_dir, filename)
    with open(filepath, "r") as f:
        data = next(yaml.load_all(f, Loader=yaml.FullLoader))
        for key in key_list: data = data[key]
    print(data)

if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2:])
