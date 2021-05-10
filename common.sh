#!/bi/bash

NRUNS=${NRUNS:=5}

USER=`whoami`

# Add here you user, and your cluster configuration
if [ "$USER" == "massimo" ]; then
    CLUSTER="--cluster client=nslrack25-100G,nic=0 dut=nslrack14-100G,nic=2"
elif [ "$USER" == "tom" ]; then
    CLUSTER="--cluster client=nslrack26-100G,nic=0 dut=nslrack14-100G,nic=0"
else
    echo "UNKNOWN USER! ABORTING"
    exit 1
fi

MAXLB=${MAXLB:=8}

COMMON_OPTS="
    --testie conntrack_lb.npf
    --use-last
    ${CLUSTER}
    --config n_runs=${NRUNS} 
    --tags ${USER}
"
COMMON_OPTS="$COMMON_OPTS $@" # --output-columns x perc1 perc25 median perc75 perc99"

COMMON_TAGS="parallel"


set -o xtrace


