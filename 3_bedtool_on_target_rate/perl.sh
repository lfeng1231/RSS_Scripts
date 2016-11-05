#!/usr/bin/env bash

CURRENT_DIR=$(pwd)

qsub -q long.q -l "mem_free=4G" -N "RNG_ontarget" -o ${CURRENT_DIR}/log.stdout -e ${CURRENT_DIR}/log.stderr <<EOF
#!/usr/bin/env bash
cd $CURRENT_DIR
perl ${CURRENT_DIR}/on-target.pl
EOF
