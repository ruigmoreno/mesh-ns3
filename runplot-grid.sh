#!/bin/bash
#NS3
configureNS3(){
    version=29

    path_project=~/workspace
    path_NS3=$path_project/ns-allinone-3.$version/ns-3.$version

    path_traces=$path_NS3/mesh-grid
    path_results=$path_NS3/scriptGridResults

}

configureScenario(){
    # nb_nodes=81
    xSize=1
    ySize=2
    step=120
    path_scenario=$path_NS3/mesh-grid/ns-3.$version/grid-$xSize\x$ySize
}

configureSimulationParameters(){

#####SIMULATION TIME#####
timeSimulationDiscovery=10
timeSimulation=30

#####CHANNEL AND INTERFACES#####

# phy=80211a
# phy=80211b
phy=80211g
# phy=80211ax_2_4_GHZ
# phy=80211ax_5GHZ
# phy=80211ax_6GHZ
min_nb_interfaces=1
max_nb_interfaces=1
nb_channels=12

#####PACKET, FLOWS#####
packetInterval=0.01
nb_flows=1

#####SIMULATION ROUNDS#####
#rounds
nb_sim_rounds=6 #number of simulation rounds for each topology
#topology
nb_sim_topologies=1

}

run(){

path_plot=$path_results/plot/packetInterval-$packetInterval-$phy-step-$step
mkdir -p $path_plot
mkdir -p $path_results/AggregateThroughput $path_results/DeliveryRate $path_results/DelayMean $path_results/JitterMean


#rm $path_results/*-temp-*


for ((  current_interface = $min_nb_interfaces ;  current_interface <= $max_nb_interfaces;  current_interface++  ))
do

    for packetSize in 1024 #32 256 1024 # packetSize = 8 doesn't work
    do

        echo "Grid $xSize"x"$ySize / Step $step / packetSize $packetSize / packetInterval $packetInterval /  $nb_flows  nb_flows / $nb_sim_topologies topologies / $nb_sim_rounds rounds per topology. "


        rm $path_results/AggregateThroughput/AggregateThroughput-$phy-step-$step-interface-$current_interface-packetInterval-$packetInterval-packetSize-$packetSize
        # rm $path_results/LostPackets/LostPackets-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize
        rm $path_results/DeliveryRate/DeliveryRate-$phy-step-$step-interface-$current_interface-packetInterval-$packetInterval-packetSize-$packetSize
        rm $path_results/DelayMean/DelayMean-$phy-step-$step-interface-$current_interface-packetInterval-$packetInterval-packetSize-$packetSize
        rm $path_results/JitterMean/JitterMean-$phy-step-$step-interface-$current_interface-packetInterval-$packetInterval-packetSize-$packetSize

        rm $path_plot/AggregateThroughput-packetSize-$packetSize
        rm $path_plot/DeliveryRate-packetSize-$packetSize
        rm $path_plot/DelayMean-packetSize-$packetSize
        rm $path_plot/JitterMean-packetSize-$packetSize

        for ((  current_topology = 1 ;  current_topology <= $nb_sim_topologies;  current_topology++  ))
        do

            echo "################################################################################"
            echo "Topology=$current_topology"
            echo "################################################################################"

            #rounds for the same topology
            for ((  current_round = 1 ;  current_round <= $nb_sim_rounds;  current_round++))
            do

                echo "Round" $current_round

                path_logmesh=$path_traces/ns-3.$version/grid-$xSize\x$ySize/phy-$phy/time-$timeSimulation/step-$step-intf-$current_interface-channels-$nb_channels-packetSize-$packetSize/$packetInterval-packetInterval/topology-$current_topology/round-$current_round
                #pwd
                # grep 'TxPackets'		$path_logmesh/logMeshSimulation.txt | cut -d: -f2 | cut -d'%' -f1        > $path_results/result_TxPackets
                # grep 'RxPackets'		$path_logmesh/logMeshSimulation.txt | cut -d: -f2 | cut -d'%' -f1        > $path_results/result_RxPackets
                grep 'Throughput'		$path_logmesh/logMeshSimulation.txt | cut -d: -f2 | cut -d'%' -f1        > $path_results/result_AggregateThroughput
                # grep 'LostPackets'	$path_logmesh/logMeshSimulation.txt | cut -d: -f2 | cut -d'%' -f1        > $path_results/result_LostPackets
                grep 'DeliveryRate' 	$path_logmesh/logMeshSimulation.txt | cut -d: -f2 | cut -d'%' -f1        > $path_results/result_DeliveryRate
                grep 'DelayMean'		$path_logmesh/logMeshSimulation.txt | cut -d: -f2 | cut -d'%' -f1        > $path_results/result_DelayMean
                grep 'JitterMean'		$path_logmesh/logMeshSimulation.txt | cut -d: -f2 | cut -d'%' -f1        > $path_results/result_JitterMean


                cd $path_results
                #pwd
                ### The NR is only for check if there is any value into result_*.
                ### If there is, NR will be always 1. If there isn't, NR will be 0 and execution will show an error.

                sum_AggregateThroughput=`awk '{ s=s+$1 } END {print s}' result_AggregateThroughput`
                # sum_LostPackets=`awk '{ s=s+$1 } END {print s}' result_LostPackets`
                average_DeliveryRate=`awk '{ s += $1 } END {print s/NR}' result_DeliveryRate`
                average_DelayMean=`awk '{ s += $1 } END {print s/NR}' result_DelayMean`
                average_JitterMean=`awk '{ s += $1 } END {print s/NR}' result_JitterMean`

                cd $path_NS3
                #pwd
                echo $step $sum_AggregateThroughput     >> $path_results/AggregateThroughput/AggregateThroughput-$phy-step-$step-interface-$current_interface-packetInterval-$packetInterval-packetSize-$packetSize
                echo $step $average_DeliveryRate     	>> $path_results/DeliveryRate/DeliveryRate-$phy-step-$step-interface-$current_interface-packetInterval-$packetInterval-packetSize-$packetSize
                echo $step $average_DelayMean        	>> $path_results/DelayMean/DelayMean-$phy-step-$step-interface-$current_interface-packetInterval-$packetInterval-packetSize-$packetSize
                echo $step $average_JitterMean       	>> $path_results/JitterMean/JitterMean-$phy-step-$step-interface-$current_interface-packetInterval-$packetInterval-packetSize-$packetSize

                rm -r $path_results/result*

            done #round

        done #topology

        chmod -R 755 $path_results/AggregateThroughput/.
        chmod -R 755 $path_results/DeliveryRate/.
        chmod -R 755 $path_results/DelayMean/.
        chmod -R 755 $path_results/JitterMean/.


        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/AggregateThroughput/AggregateThroughput-$phy-step-$step-interface-$current_interface-packetInterval-$packetInterval-packetSize-$packetSize >> $path_plot/AggregateThroughput-packetSize-$packetSize
        #  ./confidenceInterval.sh ci=95 nrvar=1 LostPackets/LostPackets-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize >> plot/packetInterval-$packetInterval-$phy/LostPackets-packetSize-$packetSize
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/DeliveryRate/DeliveryRate-$phy-step-$step-interface-$current_interface-packetInterval-$packetInterval-packetSize-$packetSize >> $path_plot/DeliveryRate-packetSize-$packetSize
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/DelayMean/DelayMean-$phy-step-$step-interface-$current_interface-packetInterval-$packetInterval-packetSize-$packetSize >> $path_plot/DelayMean-packetSize-$packetSize
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/JitterMean/JitterMean-$phy-step-$step-interface-$current_interface-packetInterval-$packetInterval-packetSize-$packetSize >> $path_plot/JitterMean-packetSize-$packetSize

    done #packetSize

done #interface


}

configureNS3
configureScenario
configureSimulationParameters
run

