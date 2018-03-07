#!/usr/bin/env python

import json
import subprocess
import sys
import time
import datetime

sys.path.insert(0, '.')
import bitcloudrpc

rpc = bitcloudrpc.getrpc()
mns = rpc.masternodelist('full')

now = int(datetime.datetime.utcnow().strftime("%s"))
mn_queue=[]
for line in mns:
    mnstat = mns[line].split()
    if mnstat[0] == 'ENABLED':
        # if last paid time == 0
        if int(mnstat[5]) == 0:
            # use active seconds
            mnstat.append(int(mnstat[4]))
        else:
            # now minus last paid
            delta = now - int(mnstat[5])
            # if > active seconds, use active seconds
            if delta >= int(mnstat[4]):
                mnstat.append(int(mnstat[4]))
            # use active seconds
            else:
                mnstat.append(delta)
        mn_queue.append(mnstat)
mn_queue = sorted(mn_queue, key=lambda x: x[8])

for line in mn_queue:
    print line

