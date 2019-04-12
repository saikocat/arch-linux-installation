#!/usr/bin/env sed -f
s/\(^zram_enabled[ ]*=[ ]*\)\(.*\)/\10/
s/\(^zswap_enabled[ ]*=[ ]*\)\(.*\)/\11/
s/\(^swapfc_enabled[ ]*=[ ]*\)\(.*\)/\11/
