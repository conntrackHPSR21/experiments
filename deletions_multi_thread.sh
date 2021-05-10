#!/bin/bash


source common.sh
mkdir -p npf_graphs

REPO=fastclick-conntrack

BASE="npf_graphs/kth_deletions_multi_thread/"

~/npf/npf-compare.py \
    "${REPO}+MANAGER=FlowIPManagerIMP_TW:Cuckoo (Per-Core) + Timer wheel" \
    "${REPO}+MANAGER=FlowIPManagerIMP_lazy:Cuckoo (Per-Core) + Lazy" \
    "${REPO}+MANAGER=FlowIPManagerMP_TW,LF=1:Cuckoo LF + Timer wheel" \
    "${REPO}+MANAGER=FlowIPManagerMP_lazy,ALWAYS_RECYCLE=1,LF=1:Cuckoo LF + Lazy" \
    $COMMON_OPTS \
    --result-path ${BASE}/npf_results/ \
    --graph-filename $BASE \
    --tags lb_high etherfix parallel mindump perfCACHE cpuload legborder impcounters tstats gentstats newgen \
    --variables "LB_CORES=[1-${MAXLB}]"  CAPACITY=16000000 GENLIMIT=300000000 "TIMEOUT=5" TIMING=false RECYCLE_INTERVAL=0.001 \
    --tags promisc tstats caida16 long lb_capa --config "graph_color={2,2,3,3}" "gtaph_lines={-,:,-,:}" var_lim={THROUGHPUT:0-100} \
    --graph-size 5 3.2 \
    --config TSTATS_T=0.5 TIMES=2 IGNORE=2 --no-graph-time $@

