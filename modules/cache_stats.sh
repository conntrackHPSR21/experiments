#! /bin/bash

FILE=$1

kill_current_running_perfs () {
    perf_pids="$(ps -A | grep perf | awk '{print $1}')"
    for pid in $perf_pids; do
        kill -9 $pid
    done
}

calculate_and_print_stats () {
    cat $FILE
    load_misses=$(perl -pe 's/(?<=\d),(?=\d)//g' $FILE | awk '$3 == "LLC-load-misses" {print $2}')
    count=0
    total_misses=0

    for miss in $load_misses; do
        num=$(echo $miss | tr -dc '0-9')
        count=`expr $count + 1`
        total_misses=`expr $total_misses + $num`
    done
    echo "RESULT-TOTAL-LLC-MISSES $total_misses"

    ############################################

    loads=$(perl -pe 's/(?<=\d),(?=\d)//g' $FILE | awk '$3 == "LLC-loads" {print $2}')
    total_loads=0

    for load in $loads; do
        num=$(echo $load | tr -dc '0-9')
        total_loads=`expr $total_loads + $num`
    done
    echo "RESULT-TOTAL-LLC-LOADS $total_loads"

    ############################################

    l1loads=$(perl -pe 's/(?<=\d),(?=\d)//g' $FILE | awk '$3 == "L1-dcache-loads" {print $2}')
    total_l1loads=0

    for l1load in $l1loads; do
        num=$(echo $l1load | tr -dc '0-9')
        total_l1loads=`expr $total_l1loads + $num`
    done
    echo "RESULT-TOTAL-L1-LOADS $total_l1loads"

    ###########################################

    l1load_misses=$(perl -pe 's/(?<=\d),(?=\d)//g' $FILE | awk '$3 == "L1-dcache-load-misses" {print $2}')
    total_l1misses=0

    for l1miss in $l1load_misses; do
        num=$(echo $l1miss | tr -dc '0-9')
        total_l1misses=`expr $total_l1misses + $num`
    done
    echo "RESULT-TOTAL-L1-MISSES $total_l1misses"

    ###########################################

    l1missratio=`echo $total_l1misses / $total_l1loads | bc -l`
    echo "RESULT-L1_MISS_RATIO $l1missratio"

    llcmissratio=`echo $total_misses / $total_loads | bc -l`
    echo "RESULT-LLC_MISS_RATIO $llcmissratio"

    
    ############# TIME STATISTICS

    #perl -pe 's/(?<=\d),(?=\d)//g' $FILE | awk '$3 == "LLC-load-misses" {printf "%i-RESULT-LLC_MISSES %s\n",$1,$2}'
    #perl -pe 's/(?<=\d),(?=\d)//g' $FILE | awk '$3 == "L1-dcache-load-misses" {printf "%i-RESULT-L1_MISSES %s\n",$1,$2}'
    perl -pe 's/(?<=\d),(?=\d)//g' $FILE | awk '$3 == "L1-dcache-loads" {printf "PERF-%i-RESULT-L1_LOADS %s\n",$1,$2}'
    perl -pe 's/(?<=\d),(?=\d)//g' $FILE | awk '$3 == "LLC-loads" {printf "PERF-%i-RESULT-LLC_LOADS %s\n",$1,$2}'
    TIMES=($(perl -pe 's/(?<=\d),(?=\d)//g' $FILE | awk '$3 == "LLC-loads" {print $1 }') )
    LLC_LOADS=($(perl -pe 's/(?<=\d),(?=\d)//g' $FILE | awk '$3 == "LLC-loads" {print $2}') )
    LLC_MISSES=($(perl -pe 's/(?<=\d),(?=\d)//g' $FILE | awk '$3 == "LLC-load-misses" {print $2}') )
    L1_LOADS=($(perl -pe 's/(?<=\d),(?=\d)//g' $FILE | awk '$3 == "L1-dcache-loads" {print $2}') )
    L1_MISSES=($(perl -pe 's/(?<=\d),(?=\d)//g' $FILE | awk '$3 == "L1-dcache-load-misses" {print $2}') )
    for i in "${!TIMES[@]}"; do
	LLC_RATIO=`echo ${LLC_MISSES[$i]} / ${LLC_LOADS[$i]} | bc -l`
	L1_RATIO=`echo ${L1_MISSES[$i]} / ${L1_LOADS[$i]} | bc -l`
	echo "PERF-$i-RESULT-LLC_MISS_RATIO "$LLC_RATIO
	echo "PERF-$i-RESULT-L1_MISS_RATIO "$L1_RATIO
    done
    

}

if test -f "$FILE"; then
    echo "starting cache analyze!"
    kill_current_running_perfs
    calculate_and_print_stats
    #rm -rf $FILE
fi

exit 0
