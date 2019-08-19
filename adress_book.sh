#!/bin/bash
read -p "Create new data file [Y/N] ?" resp
if [[ $resp == "Y" ]];
then
	rm data.txt
fi
if [ -f data.txt ];
then
	file="data.txt"
else
	touch data.txt
	printf "Name \t \t Team \t Batting Average\n" >> data.txt;
fi
add_player()
{
 name=$1
 team=$2
 batting=$3
 if [[ "$(grep -c "$name" data.txt)" -gt 0 ]];
 then
	read -p "User already exists. Update data? [Y/N] : " res
	if [[ $res == "Y" ]];
	then	
		echo "Updating existing data..";
		sed -i /$name/d data.txt;
		printf "$name \t \t $team \t $batting\n" >> data.txt;
		echo "Existing data updated for $name.";
	fi
 else
 	printf "$name \t \t $team \t $batting\n" >> data.txt;
 fi
}
search()
{
key=$1
if [[ "$(grep -c "$key" data.txt)" -gt 0 ]]
then
	grep "$key" data.txt
	read -p "Remove info from data Y/N?" response
	if [[ $response == "Y" ]];
	then
		sed -i /$key/d data.txt
	fi
else
	echo "NO SUCH DATA"
fi
}
scrape()
{
	rm data.txt
	touch data.txt
	printf "Name \t \t Team \t Batting Average\n" >> data.txt;
	wget -qO- "http://stats.espncricinfo.com/ci/engine/records/averages/batting.html?class=2;current=2;id=6;type=team" | sed -e 's/<[^>]*>//g' > downloaded_file.txt
	sed -i '/^$/d' 'downloaded_file.txt'
	sed -n '309,+507p'  downloaded_file.txt > downloaded_file2.txt
	file='downloaded_file2.txt'
	while IFS= read -r line
	do
		name=$(echo $line)
		team="India"
		i="0"
		while [ $i -lt 7 ]
		do
			read -r line
			i=$[$i+1]
		done
		batting=$line
		add_player "$name" $team $batting
		i="0"
		while [ $i -lt 9 ]
		do
			read -r line
			i=$[$i+1]
		done
	done < "$file"
}
echo "For adding player press 1";
echo "For searching press 2";
echo "For scrape press 3";
echo "For displaying complete data press 4";
read var;
if [ $var -eq 1 ];
then
	echo "Add players data.."
	read -p "Name : " name
	read -p "Team : " team
	read -p "Batting average : " batting
	add_player "$name" "$team" "$batting"
fi
if [ $var -eq 2 ];
then
	read -p "Enter search key : " key
	search "$key"
fi
if [ $var -eq 3 ];
then
	scrape
fi
if [ $var -eq 4 ];
then
	cat data.txt;
fi