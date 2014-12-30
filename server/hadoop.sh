################################################################################
# hadoop.sh 
#
# a non-interactive shell script to set up an ubuntu single-node hadoop cluster 
# from a fresh ubuntu install
#
# This script was generating using some combination of the following URLs:
# http://askubuntu.com/questions/144433/how-to-install-hadoop
# http://www.bogotobogo.com/Hadoop/BigData_hadoop_Install_on_ubuntu_single_node_cluster.php
# http://www.michael-noll.com/tutorials/running-hadoop-on-ubuntu-linux-single-node-cluster
#
# This is intended to be run as root.
#
# params: 
# 	$_HOSTNAME: the hostname to use for this new server
#
################################################################################

# hadoop requires hostname resolve to something or it errors
echo $_HOSTNAME > /etc/hostname
hostname $_HOSTNAME

# new hadoop user/group
addgroup hadoop  
adduser --disabled-password --ingroup hadoop --gecos "" hduser 
usermod -aG sudo hduser

# add ssh keys and authorized keys under root and copy them to hduser
# TODO: this should be fixed by just generating them under hduser
# but I haven't tested that yet so starting this off with working version
# and I can switch to the right way when I get a chance to test it again
ssh-keygen -b 2048 -t rsa -f $HOME/.ssh/id_rsa -q -N ""
cat .ssh/id_rsa.pub >> .ssh/authorized_keys
mkdir /home/hduser/.ssh 
cp -R ~/.ssh/* /home/hduser/.ssh/ && chown -R hduser:hadoop /home/hduser
echo "test user with: ssh hduser@localhost"

# disable ipv6: http://www.michael-noll.com/tutorials/running-hadoop-on-ubuntu-linux-single-node-cluster/#disabling-ipv6
echo "#disable ipv6  
net.ipv6.conf.all.disable_ipv6 = 1  
net.ipv6.conf.default.disable_ipv6 = 1   
net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p
echo "confirming ipv6 disabled: " && cat /proc/sys/net/ipv6/conf/all/disable_ipv6 

# install necassary tools Note: git, tree, curl, etc. may not be necessary
# but they're part of my standard install so I have them in here.
add-apt-repository -y ppa:hadoop-ubuntu/stable
apt-get update && sudo apt-get upgrade 
apt-get install -q -y ssh tree git curl vim g++ make default-jdk hadoop

# add some useful env vars
# Note: I'm getting a $HADOOP_HOME is deprecated message on this version. This tut:
# http://www.bogotobogo.com/Hadoop/BigData_hadoop_Install_on_ubuntu_single_node_cluster.php
# iss using HADOOP_INSTALL, but I haven't tested that yet so leaving this 
# script in its working form for now until I can test the fix.
echo '
#HADOOP VARIABLES START
export JAVA_HOME=/usr/lib/jvm/default-java
export HADOOP_HOME=/usr/lib/hadoop
export PATH=$PATH:$HADOOP_HOME/bin
export PATH=$PATH:$HADOOP_HOME/sbin
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib"
#HADOOP VARIABLES END
' >> /home/hduser/.bashrc

# begin conf updates with telling hadoop about JAVA_HOME
sed -e "s/^# export JAVA_HOME=.*$/export JAVA_HOME=\/usr\/lib\/jvm\/default-java/g" /etc/hadoop/conf.empty/hadoop-env.sh > /etc/hadoop/conf.empty/hadoop-env.sh.tmp && mv /etc/hadoop/conf.empty/hadoop-env.sh.tmp /etc/hadoop/conf.empty/hadoop-env.sh

# the default confs here were all essentially empty, so I am just blitzing them
#
# they shipped with the usualy <?xml-...> declarations at the top but for some
# reason hadoop realy did't like that when I tried to run format so I stripped 
# them off  
# 
# this first conf is for general hadoop config
echo '
<!-- Put site-specific property overrides in this file. -->

<configuration>
 <property>
  <name>hadoop.tmp.dir</name>
  <value>/home/hduser/tmp</value>
  <description>A base for other temporary directories.</description>
 </property>

 <property>
  <name>fs.default.name</name>
  <value>hdfs://localhost:54310</value>
  <description>The name of the default file system.  A URI whose
  scheme and authority determine the FileSystem implementation.  The
  uri"s scheme determines the config property (fs.SCHEME.impl) naming
  the FileSystem implementation class.  The uri"s authority is used to
  determine the host, port, etc. for a filesystem.</description>
 </property>
</configuration>
' > /etc/hadoop/conf/core-site.xml

# this conf is for things specific to the dfs
echo '
<!-- Put site-specific property overrides in this file. -->

<configuration>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
    <description>Default block replication.
    The actual number of replications can be specified when the file is created.
    The default is used if replication is not specified in create time.
    </description>
  </property>
</configuration>
' > /etc/hadoop/conf/hdfs-site.xml

# and this is specific to map reduce
echo '
<!-- Put site-specific property overrides in this file. -->

<configuration>
  <property>
    <name>mapred.job.tracker</name>
    <value>localhost:54311</value>
    <description>The host and port that the MapReduce job tracker runs
    at.  If "local", then jobs are run in-process as a single map
    and reduce task.
    </description>
  </property>
</configuration>
' > /etc/hadoop/conf/mapred-site.xml

# add the tmp dir referenced in the conf files earlier and make sure we own it
mkdir /home/hduser/tmp
chown hduser:hadoop /home/hduser/tmp

#spit out some helpful commands for the user
echo "format fs: hadoop namenode -format"
echo "run: start-all.sh"
echo "verify: jps"

# and send them over to the new hd user to take it for a spin
su - hduser




















