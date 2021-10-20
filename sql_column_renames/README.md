# Convert column names based on rearchitecting sheet

## Overview:

While converting an EDW system from Teradata or other on-premise system, usually the names of the tables and columns are renamed to better suit Bigquery environment. This tool provides a way to change these based on a mapping sheet.

## Requirements:

1. Python 3.x
2. Mapping sheet in CSV format
3. SQL file to convert

Currently the format for the mapping sheet assumes the following format:

1. Mapping sheets needs to be in [CSV](https://en.wikipedia.org/wiki/Comma-separated_values) format
2. At least 5 columns are assumed in the mapping sheet.
3. Second column is the "NEW" column name in Bigquery
4. Fourth column has the EDW column name.
5. EDW column name is assumed to be of format: `SYSTEM_NAME.SCHEMA_NAME.TABLE_NAME.COLUMN_NAME`

###Example:
An example mapping sheet would look like the following:

|col1|col2|col3|col4|col5|
|----|----|----|----|----|
NOT_USED|`new_column_name`|NOT_USED|`SYSTEM_NAME.SCHEMA_NAME.TABLE_NAME.COLUMN_NAME`| NOT_USED|



### Parameters

| Switch | Description |
|--------|-------------|
| -i | Input SQL file that needs to be converted
| -m | Mapping sheet in CSV format

### Output

1. `sqlfile`.out : Output of the conversion
2. `sqlfile`.error : Errors found in the mapping sheet if it is not conforming to the assumed format

### Execute

Use python 3.x to execute the script that will convert the input `SQLFILE` to `SQLFILE.out` based on mapping sheet provided.

```python

python3 mapping.py -m rearchitect-sheet.csv -i 1.sql

```