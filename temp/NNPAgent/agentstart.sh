#!/bin/sh
MALLOC_CHECK_=0
export MALLOC_CHECK_
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data/djlee/job/NNPAgent/LIB
export LD_LIBRARY_PATH
cd MAgent/bin;./magentctl -start;cd ../..
