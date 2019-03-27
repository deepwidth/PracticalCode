#!/bin/bash
#ss.sh [URL] [num]
#[URL]:所欲爬取的起始网页
#[num]:所要爬取的总页面数。

#dir图片存放目录
dir="./"

#所欲爬取的URL后缀数组
domain=(
".html"
".net"
".org"
".me"
".io"
".cn"
".com"
)

#所欲下载文件格式数组
format=(
"jpg"
"png"
"jpeg"
"mp3"
"mp4"
)

#创建当天的文件夹
time=$(date | cut -d ' ' -f 2,3,6)
time=$(echo ${time// /-})
mkdir ${dir}${time}

#删除之前留下的links列表和文件任务列表
rm -f links.txt
rm -f j.txt

#声明一些变量
declare -i sum=1
declare -i k=0
declare -i i=1
declare -i len=0
declare -i number=0
declare -i percent=0

echo -e "\033[45;37m $1 is processing... \033[0m"
#生成记录和必要文件
curl -s $1 > file.txt
echo -e "$1" >> record.txt
echo "" >> jrecord.txt

#从网站中提取文件链接
for var in ${format[@]}
do
	cat file.txt | grep -o "https*://[^(\"|=)]*\.${var}" >> j.txt
done

#开始下载图片链接列表中的文件
linenum=$(cat j.txt | wc -l)
echo -e "\033[42;37m ${linenum} files founded! \033[0m"
while [ $i -le $linenum ]
do
	link=$(cat /root/spider/j.txt | sed -n "${i},${i}p")
	percent+=1
    	name=$(echo ${link##*/})    #获取此一条图片链接中文件的名字
	k=$(cat jrecord.txt | grep -c ${name})  #检查这个文件是否在下载记录中
        if [ $k -gt 0 ]; then
		i+=1
		echo -e "\033[43;37m ${link} has been downloaded!---${sum}/$2\033[0m"
		continue
	fi
	echo -e "${link}" >> jrecord.txt
	wget --tries=1 -P ${dir}${time}/ ${link} && number+=1   #下载这个文件并存在当天的文件夹中
	echo -e "\033[44;37m ${percent}/${linenum} have been finished!---${sum}/$2\033[0m"
	i+=1
done

#从网站中提取其他的URL
for var in ${domain[@]}
do
        cat file.txt | grep -o "https*://[^(\"|=)]*${var}" >> links.txt
done

while [ $sum -lt $2 ]
do
	golink=$(sed -n '1,1p' links.txt)
	sed -i '1d' links.txt
	url=$(echo ${golink#*//})
	k=$(cat record.txt | grep -c ${url})
	if [ $k -gt 0 ]; then
		continue
	fi
	echo -e "\033[45;37m ${golink} is processing... \033[0m"
	curl -s ${golink} > file.txt
	rm -f j.txt
	for var in ${format[@]}
	do
        	cat file.txt | grep -o "https*://[^(\"|=)]*\.${var}" >> j.txt
	done
	echo -e "${url}" >> record.txt
	for var in ${domain[@]}
	do
	cat file.txt | grep -o "https*://[^(\"|=)]*${var}" >> links.txt
	done
	
	i=1
	linenum=$(cat j.txt | wc -l)
	echo -e "\033[42;37m ${linenum} files founded! \033[0m"
	percent=0
	while [ $i -le $linenum ]
	do
		link=$(cat /root/spider/j.txt | sed -n "${i},${i}p")
		percent+=1
		name=$(echo ${link##*/})
        	k=$(cat jrecord.txt | grep -c ${name})
        	if [ $k -gt 0 ]; then
                	i+=1
			echo -e "\033[43;37m ${link} has been downloaded!---${sum}/$2\033[0m"
                	continue;
        	fi
		wget --tries=1 -P ${dir}${time}/ ${link} && number+=1
		echo -e "${link}" >> jrecord.txt
		echo -e "\033[44;37m ${percent}/${linenum} have been finished!---${sum}/$2\033[0m"
		i+=1
	done
	
	sum+=1
	echo $sum >> log.txt
done 

echo -e "\033[42;37m ${sum} pages have been checked! \033[0m"
echo -e "\033[42;37m ${number} files have been downloaded in total! \033[0m"
