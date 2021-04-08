echo "Enter file: "  
read file

echo "Enter string to insert: "
read string_to_insert

echo "Enter line number: "
read line_number

i=1

while read line; do
	if [[ $(($i%$line_number)) == "0" ]]; then 
		sed -i -e "$i s/^/$string_to_insert/" $file; 
	fi
	((i=i+1))
done < $file 
