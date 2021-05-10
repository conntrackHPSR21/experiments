#!/bin/bash

# CALL as
# NRUNS=3 single_thread.sh --no-build
# NRUNS is default 1


source common.sh
mkdir -p npf_graphs

REPO=fastclick-conntrack

# Avgload up to max
size=2000000
BASE="npf_graphs/kth_single_thread_avgload/"

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
    --tags lb_high etherfix parallel cpuload impcounters gen_nolat \
    --config "graph_color={1,2,3,4,5,6}" \
    "graph_tick_params={direction:in,which:both,axis:both,grid_linestyle:dotted,labelbottom:true,bottom:true,top:true,right:true,left:true,grid_color:#444444}" \
    "var_grid=1" legend_ncol=2 "graph_markers={None}" "graph_error={result:fill}"\
    "graph_subplot_results={INSERTS_CYCLES+LOOKUPS_CYCLES:2}" "graph_subplot_type=subplot" "legend_loc=outer lower center" legend_ncol=3 "legend_bbox={0,1,1,0.01}" \
    --graph-size 6 2.5 --no-transform  \
    --variables LB_CORES=1 CAPACITY=${size}\
    --tags kth16 newgen promisc timing tstats gentstats \
    TSTATS_T=0.5 TIMES=1 IGNORE=2 --config n_runs=${NRUNS} time_precision=0 $@

