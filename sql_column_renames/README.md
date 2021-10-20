# Convert column names based on rearchitecting sheet

## Overview:

1. Need to provide a mapping sheet from which column mappings could be derived.
2. SQL file that requires conversion

### Parameters

| Switch | Description |
|--------|-------------|
| -i | Input SQL file that needs to be converted
| -m | Mapping sheet in CSV format

### Output

1. sqlfile.out : Output of the conversion
2. sqlfile.error : Errors found in the mapping sheet if it is not conforming to the assumed format

```python

python3 mapping.py -m rearchitect-sheet.csv -i 1.sql

```