
current_path=`pwd`
jar_list=$current_path/jar.list
java_list=$current_path/java.list

if [ -d $current_path/build.cnf ];then
    touch $current_path/build.cnf
    echo "repo=" >> build.cnf
    echo "project_location=" >> build.cnf
    echo "tomcat_home=" >> build.cnf
    echo "publish_location=" >> build.cnf
fi

if [ -d $jar_list ];then
    touch $jar_list
fi
if [ -d $java_list ];then
    touch $java_list
fi

# read build.cnf
source ./build.cnf


#repo="/Users/yang/.m2/repository"
#project_location="/Users/yang/Documents/workspace/kidpay"
#source="/Users/yang/Documents/workspace/kidpay/src/main/java"
#jar_list="/Users/yang/build/jar.list"
#tomcat_home="/Users/yang/Desktop/env/apache-tomcat-6.0.41"


if [ -z $repo ];then
    read -p '请输入maven库地址' repo
fi
if [ -z $project_location ];then
    read -p "请输入项目地址" project_location
fi
if [ -z $tomcat_home ];then
    read -p "请输入tomcat主目录" tomcat_home
fi


#if [ -z $ ];then
#fi


source="$project_location/src/main/java"
find $repo -name '*.jar' > $jar_list
find $source -name '*.java' > $java_list
# get jar str a.jar:b.jar:
mkdir lib

for line in `cat $jar_list`
do
    jar_list_str=$jar_list_str$line:

    # copy jstl*.jar
    if [[ $line =~ "jstl"  ]]; then  cp $line lib/; fi
    # not copy *servlet*.jar
    if [[ $line =~ "jetty"  ]]; then  continue; fi
    if [[ $line =~ "javax.el"  ]]; then  continue; fi
    if [[ $line =~ "maven"  ]]; then  continue; fi
    if [[ $line =~ "servlet"  ]];
      then  continue;
    fi
    cp $line lib/ ; 
done

rm -rf webapp

# 无效
# cp -f $repo/**/*.jar  lib/
# javac  -cp $jar_list_str$tomcat_home/lib/servlet-api.jar: -sourcepath $source -d . @$java_list


cp -rf $project_location/src/main/webapp .

# use eclipse compiled class
cp -rf  $project_location/target/classes webapp/WEB-INF/classes



# mv com webapp/WEB-INF/classes/
mv lib webapp/WEB-INF/

scp -r webapp/* $server:$publish_location/

ssh $server /var/shell/restart.sh
