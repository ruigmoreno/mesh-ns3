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
        path_project=~/carinaoliveira/2016
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
    radius=300
    #root=0
    path_scenario=$path_NS3/mesh-traces/ns-3.$version/uniformDisk-$radius

}
################################################################
getStringPhyLayer(){

    #####CHANNEL AND INTERFACES#####
    #PHY LAYER
    #1) WIFI_PHY_STANDARD_80211a 5 GHz
    #2)WIFI_PHY_STANDARD_80211b
    #3) WIFI_PHY_STANDARD_80211g
    #4) WIFI_PHY_STANDARD_80211n_2_4GHZ
    #5)WIFI_PHY_STANDARD_80211n_5GHZ

    case $1 in
       1) phy="80211a";;
       2) phy="80211b";;
       3) phy="80211g";;
       4) phy="80211n_2_4GHZ";;
       5) phy="80211n_5GHZ";;
        #6) phy="80211n_5GHZ";; todo ah
       *) exit;;
    esac
}
################################################################
configureSimulationParameters(){

    #####SIMULATION TIME#####
    timeSimulationDiscovery=10
    timeSimulation=30

    standardPhy=1
    getStringPhyLayer $standardPhy
    echo $phy

    min_nb_interfaces=1
    max_nb_interfaces=1
    nb_channels=12 #nb channels 802.11b=3 - 802.11a=12 #todo depende do padrao

    #####PACKET, FLOWS#####
    #packetSize=25
    #nb_pps=500 #number of packets per second
    #packetInterval=0.1
    #nb_flows=1
    timeStartFlowSources=$timeSimulationDiscovery+2
    #min_nb_flows=45
    #max_nb_flows=45
    #interval_nb_Flows=1

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

    echo "Parameters : $nb_nodes nodes / $packetSize packetSize / $nb_flows flows / packetInterval $packetInterval / $nb_sim_topologies topologies / $nb_sim_rounds rounds per topology"
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

    if [ $nb_flows -ge $nb_nodes ] #-ge (greater than or equal)
    then
        alert
        #Root does not initiate a flow
        echo "ALERT: nb_nodes must be greater than nb_flows (nb_nodes [$nb_nodes] > nbFlows [$nb_flows])"
    exit
    fi

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
    echo "Interface=$current_interface / Topology=$current_topology" / Flows=$nb_flows / packetInterval=$packetInterval
    echo "ID next topology connected: $nb_sim_topologies_connected"
    echo "################################################################################"

    discovery=1 #(0) false (1) true

    cd $path_NS3

#
#       --standardPhy=$standardPhy"

        ### UNIFORM DISK ###
        $comandoWaf "scratch/mesh-journal
        --discovery=$discovery
        --nbNodes=$nb_nodes
        --radius=$radius
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

    for ((  n = 0 ;  n < $nb_nodes;  n++  ))
    do
        sum_nbNeighbors=`grep -c 'peerMeshPointAddress=' mesh-report-$n.xml` #sum number of lines file
        echo "Node $n = $sum_nbNeighbors neighbors" >> logMeshSimulationTopology.txt 2>&1
        sum_neighbors_mean=`expr $sum_neighbors_mean \+ $sum_nbNeighbors`
    done

    meanLinks=`echo "scale = 5 ; $sum_neighbors_mean / $nb_nodes" | bc`
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

        path_traces=$path_scenario/phy-$phy/time-$timeSimulation/nbNodes-$nb_nodes-intf-$current_interface-channels-$nb_channels-packetSize-$packetSize/$nb_flows-flows/$packetInterval-packetInterval

        #remove old traces
        #rm -rf $path_traces


        for ((  current_topology = 1 ;  current_topology <= $nb_sim_topologies_experiments;  current_topology++  ))
        do

            if [ $nb_topologies_failed_attempts -eq $max_topologies_attempts ]
            then

                alert
                echo "ALERT(1)! Simulation stopped after $max_topologies_attempts topologies attempts. Better try another configuration."
                echo "**Simulation stopped after $max_topologies_attempts topologies attempts**" >> logMeshTopologyConnectivity.txt 2>&1
                mv logMeshTopologyConnectivity.txt $path_traces

                #stop simulation
                exit
            fi

            checkTopologyConnected

            #-------------------------------#
            # Check if topology is connected
            #-------------------------------#

            python3 ./check.py

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
                #mv topology*.png                     $path_traces_topology/discovery
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
                #mv topology*.png                     $path_traces_topology/discovery
                mv mesh-report-*.xml   		    $path_traces_topology/discovery/report
                if [ -f checked*.dot ]
                then
                    mv checked*.dot 	      	    $path_traces_topology/discovery
                fi
                #//////////////////////////////

                echo "Topology $current_topology is CONNECTED. Check started flows..."

                #nb_flows=$min_nb_flows  #reset

                #return_topology_loop=0

                #while [ $nb_flows -le $max_nb_flows ]
                #do

                #Check nb attempts rounds
                #if [ $return_topology_loop -eq 1 ]
                # then
                #echo "Try another Topology"
                #break
                #fi

                #return_topology_loop=0  #reset

                #echo "FLOW $nb_flows of $max_nb_flows"

                #nb_sim_rounds_experiments=$nb_sim_rounds


                    for ((  current_round = 1 ;  current_round <= $nb_sim_rounds;  current_round++))
                    do

                        echo "-----------------------------------------------"
                        echo "ROUND $current_round of $nb_sim_rounds"
                        
                        #root issues
                        #id_root=`expr $root + 1`
                        #   id_intf=`expr $id_root \* $current_interface - $current_interface + 1`
                        #   valor=$(echo "ibase=10;obase=16;$id_intf" | bc) #convert decimal to hexa
                        #   echo "Root is node $id_root (address mac decimal=$id_intf hexa=$valor)"
                        #   echo "Root ID NS3 = $id_root / Root MAC Address 1º interface = 00:00:00:00:00:$valor"

                        # --standardPhy=$standardPhy
                        #--pps=$nb_pps
                        #--idRoot=$root
                        #--ipRoot=10.1.1.$id_root
                        #--root=00:00:00:00:00:$valor


                        ### UNIFORM DISK ###
                        $comandoWaf "scratch/mesh-journal
                        --discovery=$discovery
                        --time=$timeSimulation
                        --timeStartFlowSources=$timeStartFlowSources
                        --nbNodes=$nb_nodes
                        --radius=$radius
                        --interfaces=$current_interface
                        --numFlows=$nb_flows
                        --packet-interval=$packetInterval
                        --packet-size=$packetSize
                        --report=$report
                        --seed=$current_topology
                        --pcap=$pcap" > logMeshSimulation.txt 2>&1

                        
                        #check flows have started
                        nb_not_started_flow=`grep -c 'Flow Not Started:' logMeshSimulation.txt`
                        echo "Not started flow:" $nb_not_started_flow


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
                        

                        if [ $nb_not_started_flow -eq 0 ]
                        then
                            #echo "All flows OK ($nb_not_started_flow)."
                            #echo "current_round=$current_round / nb_sim_rounds=$nb_sim_rounds"
                            if [ $current_round -eq $nb_sim_rounds ]
                            then
                                echo "-> Topology $current_topology CONNECTED with all flows initialized"
                                echo "Topology $current_topology CONNECTED -> Topology $nb_sim_topologies_connected" >> logMeshTopologyConnectivity.txt 2>&1
                                nb_sim_topologies_connected=`expr $nb_sim_topologies_connected + 1`
                            fi

                        else
                            nb_rounds_failed_attempts=`expr $nb_rounds_failed_attempts + 1`

                            if [ $nb_rounds_failed_attempts -eq $max_rounds_attempts ]
                            then
                                nb_sim_topologies_experiments=`expr $nb_sim_topologies_experiments + 1`
                                nb_topologies_failed_attempts=`expr $nb_topologies_failed_attempts + 1`

                                echo "Topology $current_topology CONNECTED, BUT PROBLEM WITH FLOWS" >> logMeshTopologyConnectivity.txt 2>&1

                                #change traces folder name
                                mv $path_traces_topology $path_traces/topology-$current_topology-PROBLEM-FLOWS

                                alert
                                echo "ALERT(3)! $nb_rounds_failed_attempts/$max_rounds_attempts rounds attempts. $nb_topologies_failed_attempts/$max_topologies_attempts topologies attempts. Better try another topology."

                                #skip topology
                                break
                            fi

                            alert
                            echo "ALERT(4)! $nb_rounds_failed_attempts/$max_rounds_attempts rounds attempts. Let's try again this round..."
                            echo "nb_sim_topologies_experiments=$nb_sim_topologies_experiments nb_sim_topologies_connected=$nb_sim_topologies_connected"

                            #repeat round
                            current_round=`expr $current_round - 1`
                            #break

                        fi
                        

                    done # for [current_round]

                    #nb_flows=`expr $nb_flows + $interval_nb_Flows`

                #done # while [ nbFlows ]

            fi # if [ connected ]

        done #current_topology

        mv logMeshTopologyConnectivity.txt $path_traces

    done # current_interface

}

####################################
#RUN

configureNS3
configureScenario




for nb_nodes in 81 #121 101 61 141
do

	echo "$nb_nodes nodes"
	
	for packetInterval in 0.1 #1 0.1 0.01
	do
	
		echo "-- $packetInterval interval"

		for nb_flows in 1 10 30 50
		do

			echo "--- $nb_flows flows"
		
			for packetSize in 32 256 1024 ###16 32 64 128  256 512 750 1024 # "packetSize = 8" doesn't work
			do	
			
					echo "---- $packetSize packet size"
			
					configureSimulationParameters
					run

			done #packetsize

		done # nb_flows

	done #packetInterval
	
done #nb_nodes
