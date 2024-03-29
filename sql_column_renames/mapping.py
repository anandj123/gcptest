# Copyright 2021 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#            http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import tokenize
import codecs
import json
import csv
import sys, getopt

def main(argv):

    mappingfile = ''
    sqlfile = ''
    try:
        opts, args = getopt.getopt(argv,"hm:i:",["mfile=","ifile="])
    except getopt.GetoptError:
        print('mappping.py -m <mappingfile> -i <sqlfile>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print('mapping.py -m <mappingfile> -i <sqlfile>')
            sys.exit()
        elif opt in ("-m", "--mfile"):
            mappingfile = arg
        elif opt in ("-i", "--ifile"):
            sqlfile = arg
    print('Mapping file is:', mappingfile)
    print('SQL file is:', sqlfile)

    col_mapping_dictionary = {}
    #errors = [""]
    errorcount = 0
    skip_header = True
    mapped_column_count = 0
    with open(sqlfile+'.error', 'w') as o:
        # Input file has some codec issues so ignoring those records with potential issues
        with codecs.open(mappingfile, 'r', encoding='utf-8', errors='ignore') as infile:
            csv_reader = csv.reader(infile)

            for cols in csv_reader:
                if (skip_header):
                    skip_header = False
                    continue

                if (cols[0] == ''): # Blank records in csv is skipped
                    continue
                # if ('analytical' in cols[0] or 'operational' in cols[0].lower()): # Analytical mappings are skipped (new tables in Bigquery)
                #     continue

                # If we don't have enough columns in input file it is invalid record skip
                if (len(cols)<=5): 
                    o.write('Invalid record format: [' + ','.join(cols) + ']\n')
                    #errors.append( )
                    errorcount += 1
                    continue

                new_name = cols[1] # mapped new column name in Bigquerry

                # previous column name in format: 
                #   TERADATA.POS_MCF_TB.EC_CARRIER_SHP_TRK_DLVRY_DTL.TRK_SCAN_CITY_CD
                prev_full_name = cols[3] 

                prev_col_name = prev_full_name.split('.')
                if (len(prev_col_name)<4): # Invalid format skip it
                    o.writelines('Invalid column format: [' + ','.join(cols) + ']\n')
                    errorcount += 1
                    continue

                # Extract the DW column name as the last value in the split array
                prev_col_name = prev_col_name[len(prev_col_name) - 1]

                # If both are same then skip it
                if(new_name == prev_col_name):
                    continue
                
                # If we have a column with same name in mapping dictionary we have a duplicate mapping
                if (prev_col_name in col_mapping_dictionary ):

                    (dictionary_name, 
                    dictionary_full_name, 
                    dictionary_duplicate_count) = col_mapping_dictionary[prev_col_name] 
                    
                    if (dictionary_name != new_name):
                        col_mapping_dictionary[prev_col_name] = (
                                new_name, 
                                dictionary_full_name + '\n' + 
                                '{:80s} -> {:30s}'.format(prev_full_name, new_name), 
                                dictionary_duplicate_count+1)
                else:
                    col_mapping_dictionary[prev_col_name] = (new_name, '{:80s} -> {:30s}'.format(prev_full_name, new_name),1)
        infile.close()

    print('Number of error records: ', errorcount)

    columns_replaced = 0
    # Create output token buffer for printing the output file
    tokensout = []

    # Open the input sql file and tokenize it to read each token
    with tokenize.open(sqlfile) as f:
        tokens = tokenize.generate_tokens(f.readline)
        for token in tokens:
            # If token type is not NAME then we can skip processing it and just add it to our output list
            if (token.type != tokenize.NAME):
                tokensout.append(token)
                continue

            if (token.string in col_mapping_dictionary):
                (new_name, prev_name, duplicate_count) = col_mapping_dictionary[token.string] 
                columns_replaced += 1
                # If we found duplicate column name mapping add WARNING comment before the mapping column
                if (duplicate_count > 1):
                    t = tokenize.TokenInfo(tokenize.NAME,  
                                '\n\n/*******************************************************************************************************************\n' +
                                'WARNING DUPLICATE COLUMN NAME FOUND: (' + 
                                token.string + ')\n\n' + 
                                prev_name  + 
                                '\n*********************************************************************************************************************/\n', 
                                token.start, 
                                token.end, 
                                token.line)

                    tokensout.append(t)
                    (sline, scol) = token.end
                    t = tokenize.TokenInfo(tokenize.NAME,  new_name , (sline, scol+1) , token.end , token.line)
                    tokensout.append(t)
                else:
                    t = tokenize.TokenInfo(tokenize.NAME,  new_name , token.start , token.end , token.line)
                    tokensout.append(t)

                #print('Token replaced for : ', token.string)
            else:
                tokensout.append(token) # If no mapping found then just keep the same column name
    print('Number of columns replaced: ', columns_replaced)

    with open(sqlfile+'.out', 'w') as o:
        o.write(tokenize.untokenize(tokensout))

            
if __name__ == "__main__":
       main(sys.argv[1:])

