#!/bin/bash
################################
#
# 
################################
clear

################################################################
configureNS3(){
    version=29
    local=0 #(0) local (1) cenapad
    comandoWaf="./waf --run"

    if [ $local -eq 0 ]
    then
        path_project=~/workspace
    else
        particaoCluster=gpu
        comandoWaf="srun -p $particaoCluster $comandoWaf"
        path_project=~/workspace
    fi

    #echo "Configure NS3"
    path_NS3=$path_project/ns-allinone-3.$version/ns-3.$version
    #clear old traces
    rm -rf $path_NS3/mesh-*.* $path_NS3/mesh-.pcap $path_NS3/results.xml $path_NS3/logMesh*.txt
    #$path_NS3/checked*.dot
}
################################################################
configureScenario(){

    #UNIFORM DISK
    #nb_nodes=81
    #radius=100
    xSize=1
    ySize=2
    root="00:00:00:00:00:01"
    path_scenario=$path_NS3/mesh-grid/ns-3.$version/grid-$xSize\x$ySize

}
################################################################
getStringPhyLayer(){

    #####INTERFACES#####

    case $1 in
       0)  phy="80211a";;
       1)  phy="80211b";;
       2)  phy="80211g";;
       3)  phy="80211_10MHZ";;
       4)  phy="80211_5MHZ";;
       5)  phy="holland";;
       6)  phy="80211n_2_4GHZ";;     # doesn't work
       7)  phy="80211n_5GHZ";;       # doesn't work
       8)  phy="80211ac";;           # doesn't work
       9)  phy="80211ax_2_4GHZ";;    # doesn't work
       10) phy="80211ax_5GHZ";;      # doesn't work
       *) exit;;
    esac
}
################################################################
configureSimulationParameters(){

    #####SIMULATION TIME#####
    timeSimulationDiscovery=10
    timeSimulation=30

    # standardPhy=1
    # getStringPhyLayer $standardPhy
    # echo $phy

    min_nb_interfaces=1
    max_nb_interfaces=1
    nb_channels=12 #nb channels 802.11b=3 - 802.11a=12 #todo depende do padrao

    ##### TIME SIMULATIONPACKET, FLOWS#####
    #nb_pps=500 #number of packets per second
    timeStartFlowSources=$timeSimulationDiscovery+2

    #####NS3 LOGS,REPORTS#####
    export NS_LOG=
    # export 'NS_LOG=*=level_all|prefix_func|prefix_time'
    report=1 # [0-disable 1- enable] Generate "mesh-report.xml"
    pcap=0 # [0-disable 1- enable] Generate "mp-.pcap"

    #####SIMULATION ROUNDS#####
    #rounds
    nb_sim_rounds=6 #number of simulation rounds for each topology

    #UNIFORM DISK
    #topology
    nb_sim_topologies=5
    max_topologies_attempts=3
    max_rounds_attempts=4

    echo "Parameters : $step step / $packetSize packetSize / $phy / packetInterval $packetInterval / $nb_sim_topologies topologies / $nb_sim_rounds rounds per topology"
    #Max topologies attempts is $max_topologies_attempts. Max rounds attempts is $max_rounds_attempts. "

    checkSimulationParameters
}
################################################################
alert(){
echo "/\/\/"
echo " O O"
echo "  |"
echo " --"
}
################################################################
checkSimulationParameters(){

    #Interfaces
    if [ $min_nb_interfaces -eq 0 ] #-eq (equal)
    then
        alert
        echo "ALERT: min_nb_interfaces must be greater than 0 (min_nb_interfaces [$min_nb_interfaces] > 0])"
        exit
    fi

    if [ $max_nb_interfaces -lt $min_nb_interfaces ] #-lt (less than)
    then
        alert
        echo "ALERT: max_nb_interfaces must be greater than or equal to min_nb_interfaces (max_nb_interfaces [$max_nb_interfaces] >= min_nb_interfaces [$min_nb_interfaces])"
        exit
    fi

    #Flows
    #if [ $min_nb_flows -eq 0 ]
    #then
    #    echo "ALERT: min_nb_flows must be greater than 0 (min_nb_interfaces [$min_nb_flows] > 0])"
    #    exit
    #fi

    #if [ $max_nb_flows -lt $min_nb_flows ]
    #then
    #    echo "ALERT: max_nb_flows must be greater than or equal to min_nb_flows (max_nb_flows [$max_nb_flows] >= min_nb_flows [$min_nb_flows])"
    #    exit
    #fi

    # if [ $nb_flows -ge $nb_nodes ] #-ge (greater than or equal)
    # then
    #     alert
    #     #Root does not initiate a flow
    #     echo "ALERT: nb_nodes must be greater than nb_flows (nb_nodes [$nb_nodes] > nbFlows [$nb_flows])"
    # exit
    # fi

    #Topology
    if [ $nb_sim_topologies -eq 0 ] #-eq (equal)
    then
        alert
        echo "ALERT: nb_sim_topologies must be greater than 0 (nb_sim_topologies [$nb_sim_topologies] > 0])"
        exit
    fi

    if [ $nb_sim_rounds -eq 0 ] #-eq (equal)
    then
        alert
        echo "ALERT: nb_sim_rounds must be greater than 0 (nb_sim_rounds [$nb_sim_rounds] > 0])"
        exit
    fi

    if [ $max_topologies_attempts -eq 0 ] #-eq (equal)
    then
        alert
        echo "ALERT: max_topologies_attempts must be greater than 0 (max_topologies_attempts [$max_topologies_attempts] > 0])"
        exit
    fi
}
################################################################
checkTopologyConnected(){

    #-------------------------------------------------#
    #CHECK IF TOPOLOGY IS CONNECTED
    # 1st step - each node has at least one neighbor
    # 2nd step - each node reaches all other nodes
    #-------------------------------------------------#

    echo "################################################################################"
    echo "Interface=$current_interface / Topology=$current_topology" / Step=$step / packetInterval=$packetInterval
    echo "ID next topology connected: $nb_sim_topologies_connected"
    echo "################################################################################"

    discovery=1 #(0) false (1) true

    cd $path_NS3

        ### UNIFORM DISK ###
        $comandoWaf "scratch/mesh-grid
        --discovery=$discovery
        --phy=$standardPhy
        --step=$step
        --x-size=$xSize
        --y-size=$ySize
        --time=$timeSimulationDiscovery
        --seed=$current_topology
        --report=$report" > logMeshSimulationDiscovery.txt 2>&1

    #--------------------------------------#
    # Register number of neighbors per node
    #--------------------------------------#

    #pwd
    #Create file with information about the number of neighbors per node
    #rm logMeshSimulationTopology.txt

    echo "################################################################################" >> logMeshSimulationTopology.txt 2>&1
    echo " Topology $current_topology - $current_interface interface(s)" >> logMeshSimulationTopology.txt 2>&1
    echo "################################################################################" >> logMeshSimulationTopology.txt 2>&1
    sum_neighbors_mean=0 #reset

    for ((  n = 0 ;  n < $xSize*$ySize;  n++  ))
    do
        sum_nbNeighbors=`grep -c 'peerMeshPointAddress=' mesh-report-$n.xml` #sum number of lines file
        echo "Node $n = $sum_nbNeighbors neighbors" >> logMeshSimulationTopology.txt 2>&1
        sum_neighbors_mean=`expr $sum_neighbors_mean \+ $sum_nbNeighbors`
    done

    meanLinks=`echo "scale = 5 ; $sum_neighbors_mean / ($xSize * $ySize)" | bc`
    echo "meanLinks =$meanLinks" >> logMeshSimulationTopology.txt 2>&1
    meanNeighbors=`echo "scale = 5 ; $meanLinks / $current_interface" | bc`
    echo "meanNeighbors=$meanNeighbors" >> logMeshSimulationTopology.txt 2>&1

}
################################################################
run(){

    #for current_interface in 2 4
    for ((  current_interface = $min_nb_interfaces ;  current_interface <= $max_nb_interfaces;  current_interface++  ))
    do

        nb_topologies_failed_attempts=0
        #nb_topologies_success=0
        nb_sim_topologies_experiments=$nb_sim_topologies
        nb_sim_topologies_connected=1

        path_traces=$path_scenario/phy-$phy/time-$timeSimulation/step-$step-intf-$current_interface-channels-$nb_channels-packetSize-$packetSize/$packetInterval-packetInterval

        #remove old traces
        #rm -rf $path_traces


        for ((  current_topology = 1 ;  current_topology <= $nb_sim_topologies_experiments;  current_topology++  ))
        do

            checkTopologyConnected

            #-------------------------------#
            # Check if topology is connected
            #-------------------------------#

            if [ $? -eq 1 ] # the command ? represents the last status of the last function that have executed.
            then

                nb_topologies_failed_attempts=`expr $nb_topologies_failed_attempts + 1`
                nb_sim_topologies_experiments=`expr $nb_sim_topologies_experiments + 1`

                #//////////////////////////////
                #save failed topology traces
                echo "Topology $current_topology is NOT CONNECTED" >> logMeshTopologyConnectivity.txt 2>&1
                path_traces_topology=$path_traces/topology-$current_topology-NOT-CONNECTED
                #rm -rf $path_traces_topology
                mkdir -p $path_traces_topology/discovery/report
                mv logMeshSimulationDiscovery.txt   $path_traces_topology/discovery
                mv logMeshSimulationTopology.txt    $path_traces_topology/discovery
                mv mesh-report-*.xml                $path_traces_topology/discovery/report
                if [ -f checked*.dot ]
                then
                    mv checked*.dot 	      	    $path_traces_topology/discovery
                fi                
                #//////////////////////////////

                echo "Topology $current_topology is NOT connected. $nb_topologies_failed_attempts/$max_topologies_attempts failed topologies attempts / nb_sim_topologies_experiments=$nb_sim_topologies_experiments "

            else

                nb_rounds_failed_attempts=0
                discovery=0

                #//////////////////////////////
                #save good topology traces
                path_traces_topology=$path_traces/topology-$nb_sim_topologies_connected
                #rm -rf $path_traces_topology
                mkdir -p $path_traces_topology/discovery/report
                mv logMeshSimulationDiscovery.txt  $path_traces_topology/discovery/
                mv logMeshSimulationTopology.txt   $path_traces_topology/discovery/
                mv mesh-report-*.xml   		    $path_traces_topology/discovery/report
                if [ -f checked*.dot ]
                then
                    mv checked*.dot 	      	    $path_traces_topology/discovery
                fi

                echo "Topology $current_topology is ready to RUN."
                cd $path_NS3

                for ((  current_round = 1 ;  current_round <= $nb_sim_rounds;  current_round++))
                do

                    echo "-----------------------------------------------"
                    echo "ROUND $current_round of $nb_sim_rounds"
                    

                    ### GRID ###
                    $comandoWaf "scratch/mesh-grid
                    --phy=$standardPhy
                    --time=$timeSimulation
                    --step=$step
                    --x-size=$xSize
                    --y-size=$ySize
                    --root=$root                    
                    --interfaces=$current_interface
                    --packet-interval=$packetInterval
                    --packet-size=$packetSize
                    --report=$report
                    --seed=$current_topology
                    --pcap=$pcap" > logMeshSimulation.txt 2>&1


                    ##############################
                    #Save final simulation traces
                    path_traces_round=$path_traces_topology/round-$current_round
                    mkdir -p $path_traces_round/report
                    #rm -rf $path_traces_round/report/*

                    mv mesh-report-*.xml $path_traces_round/report/

                    if [ $pcap -eq 1 ]
                    then
                        mkdir -p $path_traces_round/pcap
                        rm -rf $path_traces_round/pcap/*
                        mv *.pcap $path_traces_round/pcap/
                    fi

                    mv logMeshSimulation.txt $path_traces_round/
                    mv results.xml $path_traces_round/
                    #mv mesh-final.txt $path_traces_round/.
                    #mv MeshMultiInterface.tr $path_traces/.
                    # if [ -f checked*.dot ]
                    # then
                    #     mv checked*.dot 	      	    $path_traces/
                    # fi
                    ##############################
                    if [ $current_round -eq $nb_sim_rounds ]
                    then
                        echo "-> Topology $current_topology CONNECTED with all flows initialized"
                        echo "Topology $current_topology CONNECTED -> Topology $nb_sim_topologies_connected" >> logMeshTopologyConnectivity.txt 2>&1
                        nb_sim_topologies_connected=`expr $nb_sim_topologies_connected + 1`
                    fi                    

                done # for [current_round]
            fi # if [ connected ]
        done #current_topology

        # mv logMeshTopologyConnectivity.txt $path_traces

    done # current_interface

}

####################################
#RUN

configureNS3
configureScenario




for standardPhy in 0 #1 2
do

    getStringPhyLayer $standardPhy
	echo $phy

	for packetInterval in 0.01 #1 0.1 0.01
	do

		echo "-- $packetInterval interval"

		for step in 96.5 97.5 99.5 100 100.5 #98.6 98.7 98.8 98.9 100.1 100.2  #96.5 102.5 #60 70 80 90 100 110 120 160 200
		do

			echo "--- $step step"

			for packetSize in 1024 #16 64 128 512 ###16 32 64 128 256 512 750 1024 # "packetSize = 8" doesn't work
			do

				echo "---- $packetSize packet size"

					configureSimulationParameters
					run

			done #packetsize

		done #step

	done #packetInterval

done #standardPhy
