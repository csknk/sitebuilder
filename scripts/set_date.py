#!/usr/bin/env python3
import sys, datetime
from parse_yaml import get_data, set_data

def set_date(file):
    """If the YAML frontmatter of the markdown file does not have a "date" field set,
    set it to the current date. The date associated with the file is thereby associated with
    the date on which it was first processed.

    It the "date" metadata value is set, this function does nothing.
    """
    if not bool(get_data(file, ["date"])):
        today = datetime.date.today()
        set_data(file, "date", today.strftime("%B %d, %Y"))

if __name__ == '__main__':
    set_date(sys.argv[1])

