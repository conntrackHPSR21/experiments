#!/bin/bash

source common.sh
mkdir -p npf_graphs

BASE="npf_graphs/kth_deletions_single_thread/"

~/npf/npf-compare.py \
    "fastclick-conntrack+MANAGER=Forwarder:Baseline" \
    "fastclick-conntrack+MANAGER=FlowIPManagerIMP_lazy:Lazy" \
    "fastclick-conntrack+MANAGER=FlowIPManagerIMP_TW:Timer wheel" \
    "fastclick-conntrack+MANAGER=FlowIPManagerIMP:Scanning" \
    $COMMON_OPTS \
    --result-path ${BASE}/npf_results/ \
    --graph-filename $BASE \
    --tags lb_high etherfix parallel perfCACHE cpuload impcounters gentstats newgen \
    --variables LB_CORES=1 "CAPACITY=4000000"  \
    --variables TIMEOUT=5 "LB_CORES=1" GEN_DUMP=0 ITERATION_TIME=0.1 LIMIT=50000000 LIMIT_TIME=20 GEN_MULTI_TRACE=4 SAMPLE=1 TIMING=true "RECYCLE_INTERVAL={0.001:1000Hz,0.01:100Hz,0.1:10Hz,1:1Hz}" \
    --config var_log={DROPPEDPC} var_format={DROPPEDPC:%d} var_lim={DROPPEDPC:0-5} var_ticks={DROPPEDPC:0+1+2+5}\
    --tags promisc tstats kth8 timing \
    TSTATS_T=0.5 TIMES=2 IGNORE=2 --graph-size 5 3 $@

