#!/bin/bash
# modified from original DCU script by ...?

JOBSDIR=$HOME/pbs/jobs/
PPN=1
MEM=min16GB
TIME=24
ULIMIT=8000000
WDIR=$(pwd)

#---- input parameters ----#
while [ $# -gt 0 ]
do
  case "$1" in
  --ppn)
    PPN=$2;shift;;
  --mem)
    MEM=$2;shift;;
  --time)
    TIME=$2;shift;;
  --ulimit)
    ULIMIT=$2;shift;;
  --node)
    NODE=$2;shift;;
  --mail*)
    MAILTO=$2;shift;;
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
OUT=$JOBDIR/gen-$EXE-$ARG1-.`date +"%Y%m%d%H%M%S%N"`.pbs

echo "#!/bin/bash" > $OUT
echo "# Common PBS variables" >> $OUT
echo "#PBS -l nodes=1:ppn=$PPN:$MEM" >> $OUT
if ! test -z $NODE ; then
echo "#PBS -q $NODE" >> $OUT
fi
echo "#PBS -N $EXE-$ARG1-P${PPN}T$TIME" >> $OUT
if test -n $MAILTO ; then
    echo "#PBS -M $MAILTO" >> $OUT
fi
echo "#PBS -m bea" >> $OUT
echo "#PBS -l walltime=$TIME:00:00" >> $OUT
echo "#PBS -V" >> $OUT
echo "#PBS -o pbs/logs" >> $OUT
echo "#PBS -e pbs/logs" >> $OUT
echo "#ulimit -v $ULIMIT" >> $OUT
echo "source ${HOME}/.bashrc" >> $OUT
#echo "exp_dir=$WDIR" >> $OUT
echo "cd $WDIR" >> $OUT
echo "$EXE ${ARGS[@]}" >> $OUT

pushd $HOME
qsub $OUT
popd

