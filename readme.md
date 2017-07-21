# Cài đặt Hadoop Cluster

### I. Cài đặt Hadoop
1. [Chuẩn bị](http://)
	* Lấy danh sách server:
		```
		45.77.42.244			(master)
		45.77.47.218			(slave1)
		45.77.46.85			(slave2)
		45.77.43.168			(slave3)
		```  

	* Sửa file `/etc/hosts` trên **master**
		```
		45.77.42.244			hadoop-master
		45.77.47.218			hadoop-slave1
		45.77.46.85			hadoop-slave2
		45.77.43.168			hadoop-slave3
		```

	* Sửa file `/etc/hosts` trên **slave**
		```
		45.77.42.244			hadoop-master
		45.77.47.218			hadoop-slave1
		```
		> Sửa tương tự với tất cả các **slave** khác trong hệ thống  

	* Mở firewall để **masters** và **slaves** có thể kết nối trực tiếp với nhau
		```
		firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="45.77.47.218" accept'
		firewall-cmd --reload
		```

	* Tạo tài khoản **hadoop** và phân quyền su(nếu cần)
		```Bash
		useradd hadoop // -> tạo tài khoản
		passwd hadoop // -> đổi mật khẩu cho tài khoản
		usermod -aG wheel hadoop // -> phân quyền su cho hadoop trên centos 7
		```

2. [Cài đặt Java](http://)  
	* Cài đặt java với quyền root của hệ thống
		```
		yum install -y java-1.8.0-openjdk-devel-debug.x86_64
		```
		*Lưu ý: JAVA_HOME sẽ được cài đặt ở các bước sau*  

3. [Cài đặt Hadoop](http://)  
Bước này được thực hiện trên tất cả các nodes trong cluster.
	* Tải hadoop(phiên bản hiện tại 2.8.0)
		```
		wget http://mirrors.viethosting.com/apache/hadoop/common/hadoop-2.8.1/hadoop-2.8.1.tar.gz
		```

	* Giải nén `hadoop-2.8.1.tar.gz`
		```
		tar -xvf hadoop-2.8.1.tar.gz
		mv ./hadoop-2.8.1 /opt/hadoop
		chown -R hadoop:hadoop /opt/hadoop
		```

	* Đăng nhập với tài khoản hadoop
		```
		su - hadoop
		```

	* Cài đặt biến môi trường. Sửa file `.bash_profile` của tài khoản hadoop
		```
		nano .bash_profile

		```

		Thêm vào cuối file
		```
		## JAVA env variables
		export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.131-3.b12.el7_3.x86_64/jre/
		export PATH=$PATH:$JAVA_HOME/bin
		export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar

		## HADOOP env variables
		export HADOOP_HOME=/opt/hadoop
		export HADOOP_COMMON_HOME=$HADOOP_HOME
		export HADOOP_HDFS_HOME=$HADOOP_HOME
		export HADOOP_MAPRED_HOME=$HADOOP_HOME
		export HADOOP_YARN_HOME=$HADOOP_HOME
		export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"
		export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
		export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
		```

		Lưu file và apply `.bash_profile`
		```
		source .bash_profile
		```

		Kiểm tra phiên bản Hadoop
		```
		hadoop version
		```

		*Lưu ý: JAVA_HOME có thể thay đổi theo phiên bản java được cài đặt. Nếu chạy `hadoop version` nhận được kết quả như dưới đây nghĩa là quá trình cài đặt hadoop trên máy đã hành công: *
		```
		[hadoop@hadoop-master ~]$ hadoop version
		Hadoop 2.8.0
		Subversion https://git-wip-us.apache.org/repos/asf/hadoop.git -r 91f2b7a13d1e97be65db92ddabc627cc29ac0009
		Compiled by jdu on 2017-03-17T04:12Z
		Compiled with protoc 2.5.0
		From source with checksum 60125541c2b3e266cbf3becc5bda666
		This command was run using /opt/hadoop/share/hadoop/common/hadoop-common-2.8.0.jar
		```
4. [Khởi tạo ssh key cho tất cả các nodes trên **master**](http://)  
	* Generate ssh key
		```
		ssh-keygen -t rsa
		```

	* Copy ssh key của **slaves** cho **master**(run on master)
		```
		ssh-copy-ip hadoop-slave1 -> nhập password cho tài khoản hadoop trên hadoop-slave1
		ssh-copy-ip hadoop-slave2 -> nhập password cho tài khoản hadoop trên hadoop-slave2
		ssh-copy-ip hadoop-slave3 -> nhập password cho tài khoản hadoop trên hadoop-slave3
		```

5. [Cấu hình chung Hadoop trên cả **master** và **slaves**](http://)  
	* `core-site.xml`(HADOOP_HOME/etc/hadoop/core-site.xml)  
		> Chứa thông tin chung cấu hình cho **hadoop slaves** bao gồm:
		> - Thông tin cổng mà hadoop sử dụng
		> - Cấp phát bộ nhớ
		> - Cấp phát dung lượng
		> - Thiết lập cấu hình tối đa cho việc đọc/ghi dữ liệu của **hadoop slaves**

		Thêm thông tin sau vào trong thẻ `configuration` của `core-site.xml`
		```HTML
		<property>
		  <name>fs.defaultFS</name>
		  <value>hdfs://hadoop-master:9000/</value>
		</property>

		<property>
		  <name>dfs.permissions</name>
		  <value>false</value>
		</property>
		```

	* `hdfs-site.xml`(HADOOP_HOME/etc/hadoop/hdfs-site.xml)
		> Chứa thông tin về cấu hình hdfs của **hadoop slave** bao gồm:
		> - Nơi chứa dữ liệu của NameNode
		> - Nơi chứa dữ liệu của DataNode
		> - Số bản sao lưu dữ liệu trong hdfs
		> - ...

		Thêm thông tin sau vào `configuration` của `hdfs-site.xml`
		```XML
		<property>
		  <name>dfs.data.dir</name>
		  <value>/opt/hadoop/hadoop/dfs/name/data</value>
		  <final>true</final>
		</property>

		<property>
		  <name>dfs.name.dir</name>
		  <value>/opt/hadoop/hadoop/dfs/name</value>
		  <final>true</final>
		</property>

		<property>
		  <name>dfs.replication</name>
		  <value>3</value>
		</property>
		```

	* `mapred-site.xml`(HADOOP_HOME/etc/hadoop/mapred-site.xml)
		> Chứa thông tin cấu hình mapreduce framework

		Thêm thông tin sau vào thẻ `configuration` của `mapred-site.xml`
		```XML
		<property>
		  <name>mapreduce.framework.name</name>
		  <value>yarn</value>
		</property>
		```

	* `yarn-site.xml`(HADOOP_HOME/etc/hadoop/yarn-site.xml)
		> Chứa thông tin cấu hình Yarn

		Thêm thông tin sau vào thẻ `configuration` của `yarn-site.xml`
		```XML
		<property>
		  <name>yarn.nodemanager.aux-services</name>
		  <value>mapreduce_shuffle</value>
		</property>

		<property>
		  <name>yarn.resourcemanager.hostname</name>
		  <value>hadoop-master</value>
		</property>
		```

	* `hadoop-env.sh`(HADOOP_HOME/etc/hadoop/hadoop-env.sh)
		> Chứa thông tin về các biến môi trường của Hadoop

		Thêm thông tin sau vào cuối file
		```
		export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.131-3.b12.el7_3.x86_64/jre/
		```

6. [Cấu hình Hadoop NameNode(master)](http://)
	* `masters`(HADOOP_HOME/etc/hadoop/masters)
		> Chứa danh sách các NameNode

		Chỉnh sửa file `masters` như sau:
		```
		hadoop-master
		```

		*Nếu không tìm thấy file `masters` trong thư mục HADOOP_HOME/etc/hadoop/masters thì có thể tự tạo file*

	* `slaves`(HADOOP_HOME/etc/hadoop/slaves)
		> Chứa danh sách các NameNode

		Chỉnh sửa file `slaves` như sau:
		```
		hadoop-slave1
		hadoop-slave2
		hadoop-slave3
		```

8. [Khởi động Hadoop](http://)
	* Khởi động hdfs, yarn bằng một câu lệnh:
	```
	/opt/hadoop/sbin/start-all.sh
	```

	Nếu đã thêm /opt/hadoop/sbin thì chỉ cần `start-all.sh`

	* Kiểm tra các ứng dụng đang chạy
	```
	jps
	```

### II. Các cổng được Hadoop sử dụng và Hadoop WebUI

| Dịch vụ  | Port  | Chức năng  | 
|---|---|---|
| Hadoop NameNode WebUI | 50070  | Thông tin chung của cluster: số lượng DataNode, trạng thái data node,...  |
| Hadoop DataNode WebUI  | 50090  | Thông tin tổng quan của DataNode  |
| Resource Manager WebUI  | 8088  |  Thông tin về các ứng dụng chạy MapReduce, Queue, Schedule,... Ngoài ra còn một số thông tin về chiếm dụng hiệu năng của các ứng dụng, trạng thái của các Nodes,... |
| MapReduce JobHistory Server | 19888 | Theo dõi và xem logs thông tin của một ứng dụng MapReduce |

### III. Cấu hình Hadoop cluster nâng cao

Thông tin về những parameters để cấu hình sâu hơn vào trong hệ thống Hadoop/HDFS có thể tham khảo thêm ở đường lịnk sau:
[https://hadoop.apache.org/docs/r0.23.11/hadoop-project-dist/hadoop-common/ClusterSetup.html](https://hadoop.apache.org/docs/r0.23.11/hadoop-project-dist/hadoop-common/ClusterSetup.html)
