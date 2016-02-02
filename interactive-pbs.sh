#!/bin/bash
# modified from DCU script by ...?

JOBDIR=$HOME/pbs/jobs/
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
    echo "Usage: $0 [--ppn|--mem|--time|--ulimit]... [--help]"; exit 1
    ;;
  -*)
    echo "Unknown switch $1"; exit 1
    ;;
  *)
    break;;
  esac
  shift
done

if test $# -gt 0 ; then
	echo rubbish at end of params $@
fi
OUT=$JOBDIR/interactive/`date +"%Y%m%d%H%M%S%N"`.pbs

echo "#!/bin/bash" > $OUT
echo "# Common PBS variables" >> $OUT
echo "#PBS -l nodes=1:ppn=$PPN:$MEM" >> $OUT
if ! test -z $NODE ; then
echo "#PBS -q $NODE" >> $OUT
fi
echo "#PBS -N IAbash-P${PPN}T$TIME" >> $OUT
if test -n $MAILTO ; then
    echo "#PBS -M $MAILTO" >> $OUT
fi
echo "#PBS -m bea" >> $OUT
echo "#PBS -l walltime=$TIME" >> $OUT
echo "#PBS -V" >> $OUT
echo "#PBS -I" >> $OUT
echo "#ulimit -v $ULIMIT" >> $OUT
echo "source ${HOME}/.bashrc" >> $OUT
#echo "exp_dir=$WDIR" >> $OUT
echo "cd $WDIR" >> $OUT
echo "/bin/bash" >> $OUT

pushd $HOME
qsub -I $OUT
popd


