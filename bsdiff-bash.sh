#!/usr/bin/env bash
root=`pwd`
dest=$root/dest
echo $dest
if [[ -e $dest ]];then
	echo 'already exist dest dir,delete...'
	rm -r $dest
	echo 'delete success!'
else
	echo "not exist!"
fi
mkdir $dest
echo 'create dest dir success!'


function log_green(){
	echo -e "\033[32m $1\033[0m"
}

function log_yellow(){
	echo -e "\033[33m $1\033[0m"
}

function log_blue() {
	echo -e "\033[34m LOG:$1\033[0m"
}

function log_red() {
	echo -e "\033[31m ERROT:$1\033[0m"
}

# 遍历新版本目录中的文件，与旧版对应的文件进行比较
function read(){
	for file in `ls $2`; do
		if [[ -d $root/$2/$file ]]; then
			if [[ -e $root/$1/file ]]; then
				#该目录在旧版本不存在，直接复制该目录到目标文件夹
				# todo
				echo 'todo...'
			else
				#继续循环查找文件
				read $1/$file $2/$file
			fi
		else 
			#比较文件
			log_yellow $root/$1/$file
			log_green $root/$2/$file
			compareFile $1 $2 $file
			if [[ $? -gt 0 ]]; then
				#文件不同，执行diff命令
				log_red 'DIFFERENT EXECUTE bsdiff...'
				bsDiff $1 $2 $file
			fi
		fi
	done
}

function compareFile(){
	result=`diff $root/$1/$file $root/$2/$file`
	return ${#result}
}


# 执行bsdiff $3:filename
function bsDiff() {
	log_blue "bsDiff()入参1:"$1
	log_blue "bsDiff()入参2:"$2
	log_blue "bsDiff()入参3:"$3

	if [[ -e $dest/$2 ]]; then
		echo "存在dir:"$dest/$2
	else
		mkdir -p $dest/$2
	fi

	# bsdiff oldfile newfile patchfile
	bsdiff $root/$1/$file $root/$2/$file $dest/$2/$3.diff
}

# $1:旧版本目录 $2:新版本目录
read $1 $2
