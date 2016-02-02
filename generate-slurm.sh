#!/bin/bash
# modified from original DCU script by ...?

JOBDIR=$HOME/slurm/jobs/
PPN=1
MEM=$((16*1024))
TIME=24
ULIMIT=8000000
WDIR=$(pwd)
PARTITION=serial
NODES=1
TASKS=1

#---- input parameters ----#
while [ $# -gt 0 ]
do
  case "$1" in
  --ppn|--cpus)
    PPN=$2;shift;;
  --mem)
      MEM=$(($2 * 1024));shift;;
  --time)
    TIME=$2;shift;;
  --ulimit)
    ULIMIT=$2;shift;;
  --node)
    NODE=$2;shift;;
  --mail*)
    MAILTO=$2;shift;;
  --partition)
    PARTITION=$2;shift;;
  -h|--help)
    echo "Usage: $0 [--ppn ##|--mem min##GB|--time HH|--ulimit]... [--help]"; exit 1
    ;;
  -*)
    echo "Unknown switch $1"; exit 1
    ;;
  *)
    break;;
  esac
  shift
done

EXE=$1
ARG1=$2
shift
ARGS=();
for ARG in $*; do
  ARGS=("${ARGS[@]}" $ARG)
done
DATESTAMP=$(date +"%Y%m%d%H%M%S%N")
OUT=$JOBDIR/gen-$EXE-$ARG1-$DATESTAMP.sh

echo "#!/bin/bash -l" > $OUT
echo "# Common SLURM variables" >> $OUT
echo "#SBATCH --mem=$MEM" >> $OUT
echo "#SBATCH -c $PPN" >> $OUT
echo "#SBATCH -p $PARTITION" >> $OUT
echo "#SBATCH -J $EXE-$ARG1-P${PPN}T$TIME" >> $OUT
echo "#SBATCH -n $TASKS" >> $OUT
echo "#SBATCH -N $NODES" >> $OUT
if test -n $MAILTO ; then
    echo "#SBATCH --mail-user=$MAILTO" >> $OUT
fi
echo "#SBATCH --mail-type=ALL" >> $OUT
echo "#SBATCH -t $TIME:00:00" >> $OUT
echo "#PBS -V" >> $OUT
echo "#SBATCH -o slurm/logs/$EXE-$ARG1-$DATESTAMP-out.txt" >> $OUT
echo "#SBATCH -e slurm/logs/$EXE-$ARG1-$DATESTAMP-err.txt" >> $OUT
echo "#ulimit -v $ULIMIT" >> $OUT
echo "source ${HOME}/.bashrc" >> $OUT
#echo "exp_dir=$WDIR" >> $OUT
echo "cd $WDIR" >> $OUT
echo "$EXE ${ARGS[@]}" >> $OUT

pushd $HOME
sbatch $OUT
popd

