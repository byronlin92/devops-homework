echo "Enter host name: "  
read host 
echo "Enter port (e.g. 5000) or a port range (e.g. 5000-5200)"  
read port

res=$(nc -v -z $host $port)
echo $res