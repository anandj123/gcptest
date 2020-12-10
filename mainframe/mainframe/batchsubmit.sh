#submit job for generating Terabyte test data

nohup time mvn clean compile exec:java -Dexec.args="generate 8000000000 testTB.db" > nohup_TB_Gen.out 2>&1 &

mvn clean compile exec:java -Dexec.args="generate 10000000 testS.db" > nohup_S_Gen.out

#run the process program
nohup mvn clean compile exec:java -Dexec.args="process testTB.db query.json" > nohup_TB_PROC1.out 2>&1 &

#change priority of the job
sudo renice -19 24182

#set java memory options
export MAVEN_OPTS="-Xms16384m -Xmx16384m"

# format and mount the nvme ssd drives
sudo apt update && sudo apt install mdadm --no-install-recommends

# use mdadm to create a mount volume
sudo mdadm --create /dev/md0 --level=0 --raid-devices=24 \
/dev/nvme0n1 /dev/nvme0n2 /dev/nvme0n3 /dev/nvme0n4 \
/dev/nvme0n5 /dev/nvme0n6 /dev/nvme0n7 /dev/nvme0n8 \
/dev/nvme0n9 /dev/nvme0n10 /dev/nvme0n11 /dev/nvme0n12 \
/dev/nvme0n13 /dev/nvme0n14 /dev/nvme0n15 /dev/nvme0n16 \
/dev/nvme0n17 /dev/nvme0n18 /dev/nvme0n19 /dev/nvme0n20 \
/dev/nvme0n21 /dev/nvme0n22 /dev/nvme0n23 /dev/nvme0n24 

#format the volume
sudo mkfs.ext4 -F /dev/md0 -E lazy_itable_init=0,lazy_journal_init=0,discard

#mount it to a directory
sudo mkdir -p /mnt/disks/mfpoc
sudo mount /dev/md0 /mnt/disks/mfpoc

#make it read and writeable
sudo chmod a+w /mnt/disks/mfpoc

#install google stackdriver agent
curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh
sudo bash add-monitoring-agent-repo.sh
sudo apt-get update

sudo apt-cache madison stackdriver-agent
sudo apt-get install stackdriver-agent

sudo service stackdriver-agent start

sudo service stackdriver-agent status

sudo grep collectd /var/log/{syslog,messages} | tail


# disk performance
dd if=/dev/zero of=/mnt/disks/mfpoc/test.out bs=64k count=1000k; rm -f /mnt/disks/mfpoc/test.out

#see disk performance
sudo hdparm -Tt /dev/md0



#check which devices are available
lsblk

#output of lsblk command
nvme0n1  259:0    0  375G  0 disk 
nvme0n16 259:15   0  375G  0 disk 
nvme0n24 259:23   0  375G  0 disk 
nvme0n14 259:13   0  375G  0 disk 
nvme0n8  259:7    0  375G  0 disk 
nvme0n22 259:21   0  375G  0 disk 
nvme0n12 259:11   0  375G  0 disk 
nvme0n6  259:5    0  375G  0 disk 
nvme0n20 259:19   0  375G  0 disk 
nvme0n10 259:9    0  375G  0 disk 
nvme0n4  259:3    0  375G  0 disk 
nvme0n19 259:18   0  375G  0 disk 
nvme0n2  259:1    0  375G  0 disk 
nvme0n17 259:16   0  375G  0 disk 
nvme0n15 259:14   0  375G  0 disk 
nvme0n9  259:8    0  375G  0 disk 
nvme0n23 259:22   0  375G  0 disk 
nvme0n13 259:12   0  375G  0 disk 
nvme0n7  259:6    0  375G  0 disk 
sda        8:0    0   50G  0 disk 
├─sda14    8:14   0    4M  0 part 
├─sda15    8:15   0  106M  0 part /boot/efi
└─sda1     8:1    0 49.9G  0 part /
nvme0n21 259:20   0  375G  0 disk 
nvme0n11 259:10   0  375G  0 disk 
nvme0n5  259:4    0  375G  0 disk 
nvme0n3  259:2    0  375G  0 disk 
nvme0n18 259:17   0  375G  0 disk 