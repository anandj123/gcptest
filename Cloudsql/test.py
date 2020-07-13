import pymysql
import datetime
import time

connection = pymysql.connect(host='127.0.0.1',
                             user='root',
                             password='root',
                             db='test')
with connection:
    cursor = connection.cursor()     # get the cursor
    cursor.execute("USE test") # select the database
    cursor.execute("SHOW TABLES")
    print(cursor.fetchall())
    cursor.execute("select * from test;")
    rows = cursor.fetchall()
    for row in rows:
        print("{0} {1} {2} {4} {5}".format(row[0], row[1], row[2], row[3], row[4], row[5]))
    
    for i in range(1):    
        millis = int(round(time.time() * 1000))
        cursor.execute("INSERT INTO `test` (`title`, `description`,`email`,`date`) VALUES (%s, %s, %s, %s)", (millis,'test run for multi region','webmaster@python.org', datetime.datetime.utcnow()))
        print(millis, id(millis))
    
    