#!/bin/bash

# CALL as
# NRUNS=3 single_thread.sh --no-build
# NRUNS is default 1


source common.sh
mkdir -p npf_graphs


REPO=fastclick-conntrack

size=4000000

BASE="npf_graphs/kth_single_thread_${size}/"
# Throughput single
~/npf/npf-compare.py \
    "${REPO}+MANAGER=FlowIPManagerIMP:Cuckoo" \
    "${REPO}+MANAGER=FlowIPManager_CuckooPPIMP:Cuckoo++" \
    "${REPO}+MANAGER=FlowIPManagerHS_IMP:HopScotch" \
    "${REPO}+MANAGER=FlowIPManager_RobinMapIMP:RobinMap" \
    "${REPO}+MANAGER=FlowIPManagerH:Chaining (FC)" \
    "${REPO}+MANAGER=FlowIPManager_CPPIMP:Chaining (STL)" \
    $COMMON_OPTS \
    --result-path ${BASE}/npf_results/ \
    --graph-filename $BASE \
    --tags lb_high etherfix impcounters parallel cpuload gen_nolat \
    --no-graph-time \
    --config "graph_color={1,2,3,4,5,6}" "graph_show_values=2" graph_show_xlabel=0 \
    "graph_tick_params={direction:in,which:both,axis:both,grid_linestyle:dotted,labelbottom:true,bottom:true,top:true,right:true,left:true,grid_color:#444444}" \
    "var_grid={THROUGHPUT}" "legend_loc=outer upper center" "legend_bbox={0,1,1,0.1}" legend_ncol=3  \
    "var_lim={THROUGHPUT:0-2+18-55}" "graph_bar_inter=0.05" "var_ticks={THROUGHPUT:0+20+30+40+50}"\
    --graph-size 6.5 2.5 --no-transform --output ${BASE}/csvs/ \
    --variables LB_CORES=1 CAPACITY=${size}\
    TSTATS_T=0.5 TIMES=1 IGNORE=2 \
    --tags both16 newgen promisc timing tstats gentstats 

