#!/bin/bash
lsblk -dplnx size -o name,type,ro,size | grep "disk\s*0" | tac
