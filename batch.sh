#!/bin/bash

for f in data/patterns/*.ptn
do
  ptn=`basename $f | sed s/.ptn//`
  rp5 run swarm.rb $ptn
done
