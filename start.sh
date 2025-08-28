#!/bin/bash

LOCKFILE='lock.file'

echo "[Swap Optimizer Setup] Setup complete."

if [ -f ${LOCKFILE} ]
then
    echo "Check pid alive!"
    PID=`/bin/cat ${LOCKFILE}`
    if ps -p ${PID} > /dev/null
    then
        echo "${PID} is running, so skip, bye."
        exit 0
    else
        echo "${PID} is dead, delete ${LOCKFILE}"
        rm -f ${LOCKFILE}
    fi
fi

echo $$ > $LOCKFILE

if [ ! -f ${LOCKFILE} ]
then
    echo "Create lock file failed!"
    exit 1
fi

echo "[Swap Optimizer] Starting the path-finder service..."

# Ensure .env exists
if [ ! -f .env ]; then
    echo "[ERROR] Missing .env file. Please run setup.sh first."
    exit 1
fi

# Run orchestrator logic
echo "[Swap Optimizer] Starting orchestrator..."
npm run build

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOGFILE="logs/output_$TIMESTAMP.log"
npm start 2>&1 | tee -a "$LOGFILE"

(
  sleep 300
  pkill -f "node src/app.js"
  echo "[SWAP OPTIMIZER] Simulated crash: app.js stopped after 5 minutes." >> logs/output.log
) &

wait

rm $LOCKFILE
