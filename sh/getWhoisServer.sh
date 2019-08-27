#!/bin/bash
# Author: deepwidth
# Website: https://zkk.me
# E-mail: zhang.kangkang[at]outlook.com

declare -i i=1

#生成记录和必要文件
curl -s https://www.iana.org/domains/root/db > file.txt

#从网站中提取URL
cat file.txt | grep -o "/domains/root/db/[a-z]*\.html" | sed 's/\/domains/https:\/\/www.iana.org\/domains/g' >> links.txt

linenum=$(cat links.txt | wc -l)

while [ $i -le $linenum ]
do
	link=$(cat links.txt | sed -n "${i},${i}p")
	top=$(echo $link | sed "s/^https:\/\/www.iana.org\/domains\/root\/db\//'/g" | sed "s/\.html/'/g")
	server=$(curl -s $link | grep "<b>WHOIS Server:</b>" | sed "s/^        <b>WHOIS Server:<\/b> //g")
	echo "${top} => '${server}'," >> res.txt
	echo $i / $linenum
	i+=1
done

rm -f file.txt
rm -f links.txt
