nohup mvn clean compile exec:java -Dexec.args="test1.data" > nohup1.out 2>&1 &
nohup mvn clean compile exec:java -Dexec.args="test2.data" > nohup2.out 2>&1 &
nohup mvn clean compile exec:java -Dexec.args="test3.data" > nohup3.out 2>&1 &
nohup mvn clean compile exec:java -Dexec.args="test4.data" > nohup4.out 2>&1 &
nohup mvn clean compile exec:java -Dexec.args="test5.data" > nohup5.out 2>&1 &
nohup mvn clean compile exec:java -Dexec.args="testL.data" > nohup1.out 2>&1 &
