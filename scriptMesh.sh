#!/usr/bin/env bash

while getopts n:x:y: flag
do
    case "${flag}" in
        n) nExecution=${OPTARG};;
        x) axis_x=${OPTARG};;
        y) axis_y=${OPTARG};;
    esac
done
echo "nExecution: $nExecution";
echo "Axis-X: $axis_x";
echo "Axis-Y: $axis_y";

i=1

while [ $i -lt $nExecution ]
do
 ./waf --run 'scratch/mesh-journal' > logMeshSimulationDiscovery"$i".txt
 ((i++))
done
