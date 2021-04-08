echo "Enter file: "  
read file

echo "Enter your regular expression: "
read regular_expression

echo "Enter replacement string: "
read replacement_string

return_string=""

while read line; do
	return_string="${return_string} ${line//$regular_expression/$replacement_string}"
done < $file 

echo $return_string