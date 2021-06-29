import sys

# Dictionary with domain (key) and list of TEs containing that domain (value)
DOMAINS = {}

for line in sys.stdin:
    lst = line.split()
    # ...etc