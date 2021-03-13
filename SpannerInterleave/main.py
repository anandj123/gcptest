import sys
from google.cloud import spanner
import time
import random
import string

def query_a(instance_id, database_id, query):
    spanner_client = spanner.Client()
    instance = spanner_client.instance(instance_id)
    database = instance.database(database_id)
    with database.snapshot() as snapshot:
        results = snapshot.execute_sql(
            query,
            params={"lastName": "last " + str(1)},
            param_types={"lastName": spanner.param_types.STRING},
        )

    t_start = time.time()
    print("Query (Non-primary key): Iteration Time (seconds)")
    print("--------------------------------------------------")
    for i in range(100):
        i_start = time.time()
        
        with database.snapshot() as snapshot:
            r = random.randrange(1000000)
            results = snapshot.execute_sql(
                query,
                params={"lastName": "last " + str(r)},
                param_types={"lastName": spanner.param_types.STRING},
            )

        #for row in results:
        #    print(u"SingerId: {}, FirstName: {}, LastName: {}".format(*row))
        #print("%s" % (time.time() - i_start))
    
    print("Total Time (seconds) : %s \n" % (time.time() - t_start))
    

def query_b(instance_id, database_id, query):
    spanner_client = spanner.Client()
    instance = spanner_client.instance(instance_id)
    database = instance.database(database_id)
    with database.snapshot() as snapshot:
        results = snapshot.execute_sql(
            query,
            params={"SingerId": 1},
            param_types={"SingerId": spanner.param_types.INT64},
        )

    t_start = time.time()
    print("Query (primary key): Iteration Time (seconds)")
    print("----------------------------------------------")
    for i in range(100):
        i_start = time.time()
        
        with database.snapshot() as snapshot:
            r = random.randrange(1000000)
            results = snapshot.execute_sql(
                query,
                params={"SingerId": r},
                param_types={"SingerId": spanner.param_types.INT64},
            )

        #for row in results:
        #    print(u"SingerId: {}, FirstName: {}, LastName: {}".format(*row))
        #print("%s" % (time.time() - i_start))
    
    print("Total Time (seconds) : %s \n" % (time.time() - t_start))

def insert_data(instance_id, database_id,num_batches):
    """Inserts sample data into the given database.

    The database and table must already exist and can be created using
    `create_database`.
    """
    spanner_client = spanner.Client()
    instance = spanner_client.instance(instance_id)
    database = instance.database(database_id)

    with database.batch() as batch:
        remaining_singers = spanner.KeySet(all_=True)
        batch.delete("Singers", remaining_singers)
        batch.delete("Albums", remaining_singers)
        print('Truncatd Singers and Album tables.')
            
    for j in range(int(num_batches)):
        batchsize = 1000
        with database.batch() as batch:
            data = []
            for i in range(batchsize):
                k = j*batchsize + i
                data.append((k,u'first ' + str(k) , u'last '+ str(k) ))
            #print(data)
            try:            
                batch.insert(
                    table="Singers",
                    columns=("SingerId", "FirstName", "LastName"),
                    values=data,
                )
            except:
                print("Exception occured")

            data = []
            for i in range(batchsize):
                k = j*batchsize + i
                title = ''.join(random.choice(string.ascii_lowercase) for i in range(4000))
                data.append((k,k, title))
            try:
                batch.insert(
                    table="Albums",
                    columns=("SingerId", "AlbumId", "AlbumTitle"),
                    values=data,
                )
            except:
                print("Exception occured")

    
            #batch.commit()
        print("Inserted batch : " + str(j))

def insert_data2(instance_id, database_id,num_batches):
    """Inserts sample data into the given database.

    The database and table must already exist and can be created using
    `create_database`.
    """
    spanner_client = spanner.Client()
    instance = spanner_client.instance(instance_id)
    database = instance.database(database_id)

    with database.batch() as batch:
        remaining_singers = spanner.KeySet(all_=True)
        batch.delete("Singers2", remaining_singers)
        batch.delete("Albums2", remaining_singers)
        print('Truncatd Singers2 and Album2 tables.')
            
    for j in range(int(num_batches)):
        batchsize = 1000
        with database.batch() as batch:
            data = []
            for i in range(batchsize):
                k = j*batchsize + i
                data.append((k,u'first ' + str(k) , u'last '+ str(k) ))
            #print(data)
            try:
                batch.insert(
                    table="Singers2",
                    columns=("SingerId", "FirstName", "LastName"),
                    values=data,
                )
            except:
                print("Exception occured")


            data = []
            for i in range(batchsize):
                k = j*batchsize + i
                title = ''.join(random.choice(string.ascii_lowercase) for i in range(4000))
                data.append((k,k, title))
            try:
                batch.insert(
                    table="Albums2",
                    columns=("SingerId", "AlbumId", "AlbumTitle"),
                    values=data,
                )
            except:
                print("Exception occured")

            #batch.commit()
        print("Inserted batch : " + str(j))

if __name__ == '__main__':
    # TODO: 
    # To call the program 
    # gcloud auth application-default login
    # python3 main.py test-1 test
    #insert_data(*sys.argv[1:])
    #insert_data2(*sys.argv[1:])

    # TODO:
    # To alter the database to use the optimizer_version=2 use the following
    '''
     gcloud spanner databases ddl update test --instance=test-1 --ddl='ALTER DATABASE test SET OPTIONS ( optimizer_version = 2 )'

    '''
    query_a(*sys.argv[1:],"SELECT AlbumTitle FROM Singers inner join Album using(SingerId) WHERE LastName = @lastName")
    query_a(*sys.argv[1:],"SELECT AlbumTitle FROM Singers2 inner join Album2 using(SingerId) WHERE LastName = @lastName")
    query_b(*sys.argv[1:],"SELECT AlbumTitle FROM Singers inner join Album using(SingerId) WHERE SingerId = @SingerId")
    query_b(*sys.argv[1:],"SELECT AlbumTitle FROM Singers2 inner join Album2 using(SingerId) WHERE SingerId = @SingerId")

    query_b(*sys.argv[1:],"SELECT s.FirstName, s.LastName, array(SELECT a1.AlbumTitle FROM Singers s1 JOIN Albums a1 ON s1.SingerId = a1.SingerId WHERE s.SingerId = s1.SingerId) FROM Singers s WHERE EXISTS(SELECT a2.AlbumTitle FROM Albums a2 WHERE a2.SingerId = s.SingerId) AND s.SingerId = @SingerId")

    query_b(*sys.argv[1:],"SELECT s.FirstName, s.LastName, array(SELECT a1.AlbumTitle FROM Singers2 s1 JOIN Albums2 a1 ON s1.SingerId = a1.SingerId WHERE s.SingerId = s1.SingerId) FROM Singers2 s WHERE EXISTS(SELECT a2.AlbumTitle FROM Albums2 a2 WHERE a2.SingerId = s.SingerId) AND s.SingerId = @SingerId")

