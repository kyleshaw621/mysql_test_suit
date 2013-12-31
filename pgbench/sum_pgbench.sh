#!/bin/bash
#!/bin/bash -aux
repeat=5

all_transaction=0
tmp_file=/tmp/pg_output
sum_include=0
sum_exclude=0
test_time=0

##restart postgresql server
if [ -e "./res_pgbench.sh" ];then
	./res_pgbench.sh
fi

for((i=1;i<=$repeat;i++))
do
	echo "==== No.$i ===="
	sleep 1
	./pgbench.sh > $tmp_file
	#cat $tmp_file
	temp_sum_include=`cat $tmp_file | grep "including connections establishing" | awk '{print $3}' | tr [:cntrl:] " "`
	echo "temp_sum_include = $temp_sum_include"
	temp_sum_exclude=`cat $tmp_file | grep "excluding connections establishing" | awk '{print $3}' | tr [:cntrl:] " "`
	echo "temp_sum_exclude = $temp_sum_exclude"
	test_time=`cat $tmp_file | grep "duration" | awk '{print $2}'`
	temp_all_trans=`cat $tmp_file | grep "number of transactions actually processed" | awk '{print $NF}' | tr [:cntrl:] " "`
	#echo "temp_all_trans = $temp_all_trans"
	all_transaction=$(echo $all_transaction + $temp_all_trans | bc)
	sum_include=$(echo $sum_include + $temp_sum_include | bc)
	sum_exclude=$(echo $sum_exclude + $temp_sum_exclude | bc)
	#echo "$sum_exclude $sum_include"
done

echo "test time = $test_time"
#echo "all transaction = $all_transaction"
average_trans=$(echo $all_transaction / $repeat | bc)
average_include=$(echo "scale=6;$sum_include / $repeat" | bc)
average_exclude=$(echo "scale=6;$sum_exclude / $repeat" | bc)
echo "average transactions = $average_trans" 
echo "tps(include) = $average_include" 
echo "tps(exclude) = $average_exclude"
