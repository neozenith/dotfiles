#! /usr/bin/env python

import sys
import re
from pprint import pformat

def group_by(regex):
  pattern = re.compile(regex)
  count = 0
  categories = {}

  for line in sys.stdin:
    count = count + 1
    result = pattern.search(line)
    if result:
      key = result.group(0)
      if key not in categories:
        categories[key] = 0

      categories[key] = categories[key] + 1

  sys.stdout.write(pformat(categories))
  sys.stdout.write(f"\nTOTAL: {count}\n")

if __name__ == "__main__":
  if len(sys.argv) >= 2:
    group_by(sys.argv[1])
  else:
    print(f"""
    {sys.argv[0]} expects 1 argument.

    USAGE: python {sys.argv[0]} REGEX_PATTERN

    REGEX_PATTERN - any valid regex pattern that re.compile understands
    """)
