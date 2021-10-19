import codecs
import json
class Mapping:
    def __init__(self, prev_name, new_name, duplicate_name_found, tables):
        self.prev_name = prev_name
        self.new_name = new_name
        self.duplicate_name_found = duplicate_name_found
        self.tables = tables

# import pandas as pd
# df = pd.read_csv('rearchitect-sheet.csv',encoding='ISO-8859-1', low_memory=False)
# df = df[df['column_name'].notna()]
# df = df[df['first_legacy_col_map'].notna()]
# final_columns = ['column_name', 'first_legacy_col_map']
# df.drop(columns=[col for col in df if col not in final_columns],inplace=True)
# df[['system', 'schema','table', 'column']]=df['first_legacy_col_map'].str.split('.',expand=True).iloc[:,[0,1,2,3]]
# print(df[df['column_name'].duplicated() == True].iloc[:,[0,5]])

# print(df)

# df=df.groupby(['column'], as_index = False).agg({'column_name': ','.join})
# df[['column','column_name']].drop_duplicates()
# #df2 = df[['column', 'column_name']].groupby(['column'])['column_name'].transform(lambda x: ','.join(x))
# print(df)

# #df2[['column','text','column_name']].drop_duplicates()
# df.to_csv('out.out',index=False)

"""
{
    prev_name: "address_id",
    new_name: "addressess_guid",
    duplicate_name_found: False
    tables: [
        {
            table_name: "NETEZZA.ANALYTICS_TB.ADDRESS_HOME_STORE_MASTER_ST_PROD[XXXX]"
            new_col_name: "addressess_guid"
        },
        {
            table_name: "NETEZZA.ANALYTICS_TB.ADDRESS_HOME_STORE_MASTER_CF[XXXX]"
            new_col_name: "addressess_guid"
        },
    ]
}
"""
tables = ["NETEZZA.ANALYTICS_TB.ADDRESS_HOME_STORE_MASTER_ST_PROD[XXXX]",
        "NETEZZA.ANALYTICS_TB.ADDRESS_HOME_STORE_MASTER_CF[XXXX]"]
m = Mapping("address_id", "address_guid", False, tables)
j = json.loads(m)
print(json.dumps(m.__dict__))
print(j['prev_name'])
json
exit()

with codecs.open('rearchitect-sheet.csv', 'r', encoding='utf-8', errors='ignore') as infile:
    counter = 0
    lines = infile.readlines()
    for line in lines:
        cols = line.split(',')
        if (len(cols)<=5):
            break
        new_name = cols[1]
        prev_full_name = cols[3]
        prev_col_name = prev_full_name.split('.')
        if (len(prev_col_name)<4):
            continue
        prev_col_name = prev_col_name[len(prev_col_name) - 1]
        if(new_name == prev_col_name):
            continue
        print(prev_full_name, ': ', new_name, '->',prev_col_name )
        counter += 1
        # if counter > 10:
        #     break;

infile.close()

