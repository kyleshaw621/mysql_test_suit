#!/bin/bash

sysbench --test=cpu --cpu-max-prime=20000 --num-threads=2 run 
