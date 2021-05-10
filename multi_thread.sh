#!/bin/bash

# CALL as
# NRUNS=3 multi_thread.sh --no-build
# NRUNS is default 1

source common.sh
mkdir -p npf_graph

REPO=fastclick-conntrack-light

CORESTICKS="1"
for ((i=2; i<=$MAXLB;i++)); do
    CORESTICKS=$CORESTICKS"+$i"
done


for size in 8000000;
do

    BASE="npf_graphs/kth_multi_thread_${size}/"

    ~/npf/npf-compare.py \
	"${REPO}+MANAGER=FlowIPManagerMP,LF=1:Cuckoo LF" \
	"${REPO}+MANAGER=FlowIPManagerMP,LF=0:Cuckoo LB" \
	"${REPO}+MANAGER=FlowIPManagerHMP:Chaining MP" \
	"${REPO}+MANAGER=FlowIPManagerMutex:Cuckoo Mutex" \
	"${REPO}+MANAGER=FlowIPManagerSpinlock:Cuckoo Spinlock" \
	$COMMON_OPTS \
	--result-path ${BASE}/npf_results/ \
	--graph-filename $BASE/single/ \
	--config "graph_color={4,2,3,2,2}" "var_lim={THROUGHPUT:0-100}" \
	"legend_loc=outer lower center" "graph_fillstyle=none" legend_ncol=3 \
	var_ticks={LB_CORES:$CORESTICKS} \
	--tags lb_high etherfix parallel mindump cpuload impcounters gentstats perfCACHE newgen \
	--no-graph-time \
	--graph-size 4.5 3 \
	--variables "LB_CORES=[1-${MAXLB}]" CAPACITY=${size} \
	trace=/mnt/traces/kth/morning/summaries/morning-16 \
	TSTATS_T=0.5 TIMES=1 IGNORE=2


    ~/npf/npf-compare.py \
	"${REPO}+MANAGER=FlowIPManager_CuckooPPIMP:Cuckoo++" \
	"${REPO}+MANAGER=FlowIPManagerHS_IMP:HopScotch" \
	"${REPO}+MANAGER=FlowIPManager_RobinMapIMP:RobinMap" \
	"${REPO}+MANAGER=FlowIPManagerIMP:Cuckoo" \
	"${REPO}+MANAGER=FlowIPManagerHIMP:Chaining (FC)" \
	"${REPO}+MANAGER=FlowIPManager_CPPIMP:Chaining (STL)" \
	$COMMON_OPTS \
	--result-path ${BASE}/npf_results/ \
	--graph-filename $BASE/imp/ \
	--config "graph_color={1,2,3,4,5,6}"  "var_lim={THROUGHPUT:0-100}" "var_ticks={THROUGHPUT:0+20+40+60+80+100}" "graph_fillstyle=none" \
	"legend_loc=lower right"  legend_ncol=1 \
	var_ticks={LB_CORES:$CORESTICKS} \
	--tags lb_high etherfix parallel mindump cpuload impcounters gentstats perfCACHE newgen legborder\
	--no-graph-time \
	--graph-size 4.5 3 \
	--variables "LB_CORES=[1-${MAXLB}]" CAPACITY=${size} \
	trace=/mnt/traces/kth/morning/summaries/morning-16 \
	TSTATS_T=0.5 TIMES=1 IGNORE=2
done
