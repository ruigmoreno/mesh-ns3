#!/bin/bash
#NS3
configureNS3(){
    version=29

    path_project=~/workspace
    path_NS3=$path_project/ns-allinone-3.$version/ns-3.$version

    path_traces=$path_NS3/mesh-traces-rp
    path_results=$path_NS3/scriptResults-rp-001

}

configureScenario(){
    nb_nodes=81
    radius=300
}

configureSimulationParameters(){

#####SIMULATION TIME#####
timeSimulationDiscovery=10
timeSimulation=30

#####CHANNEL AND INTERFACES#####
phy=80211a
min_nb_interfaces=1
max_nb_interfaces=1
nb_channels=12 #nb channels 802.11b=3 - 802.11a=12

#####PACKET, FLOWS#####
packetInterval=0.01
nb_flows=1

#####SIMULATION ROUNDS#####
#rounds
nb_sim_rounds=16 #number of simulation rounds for each topology
#topology
nb_sim_topologies=5

}

run(){

path_plot=$path_results/plot/nb_nodes-$nb_nodes-packetInterval-$packetInterval-$phy-$nb_flows-flows
mkdir -p $path_plot
mkdir -p $path_results/AggregateThroughput $path_results/DeliveryRate $path_results/DelayMean $path_results/JitterMean

mkdir -p $path_results/PreqPerNode $path_results/PrepPerNode $path_results/PerrPerNode
mkdir -p $path_results/TxPreqPerNode $path_results/TxPrepPerNode $path_results/TxPerrPerNode
mkdir -p $path_results/DroppedTtlPerNode $path_results/TotalQueuedPerNode
mkdir -p $path_results/TotalDroppedPerNode

mkdir -p $path_results/PreqTotal $path_results/PrepTotal $path_results/PerrTotal
mkdir -p $path_results/TxPreqTotal $path_results/TxPrepTotal $path_results/TxPerrTotal


#rm $path_results/*-temp-*


for ((  current_interface = $min_nb_interfaces ;  current_interface <= $max_nb_interfaces;  current_interface++  ))
do

    for packetSize in 32 256 1024 # packetSize = 8 doesn't work
    do

        echo "Uniform disk / $nb_nodes nodes / radius $radius / packetSize $packetSize / packetInterval $packetInterval /  $nb_flows  nb_flows / $nb_sim_topologies topologies / $nb_sim_rounds rounds per topology. "


        #rm $path_results/TxPackets/TxPackets-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize
        #rm $path_results/RxPackets/RxPackets-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize
        #rm $path_results/LostPackets/LostPackets-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize
        rm $path_results/AggregateThroughput/AggregateThroughput-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize
        rm $path_results/DeliveryRate/DeliveryRate-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize
        rm $path_results/DelayMean/DelayMean-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize
        # rm $path_results/JitterMean/JitterMean-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize
        rm $path_results/PreqPerNode/Preq-nb_nodes-$nb_nodes-interface-$current_interface-nbFlows-$nb_flows-packetSize-$packetSize-original80211s
        rm $path_results/PrepPerNode/Prep-nb_nodes-$nb_nodes-interface-$current_interface-nbFlows-$nb_flows-packetSize-$packetSize-original80211s
        rm $path_results/PerrPerNode/Perr-nb_nodes-$nb_nodes-interface-$current_interface-nbFlows-$nb_flows-packetSize-$packetSize-original80211s
        rm $path_results/PreqTotal/Preq-nb_nodes-$nb_nodes-interface-$current_interface-nbFlows-$nb_flows-packetSize-$packetSize-original80211s
        rm $path_results/PrepTotal/Prep-nb_nodes-$nb_nodes-interface-$current_interface-nbFlows-$nb_flows-packetSize-$packetSize-original80211s
        rm $path_results/PerrTotal/Perr-nb_nodes-$nb_nodes-interface-$current_interface-nbFlows-$nb_flows-packetSize-$packetSize-original80211s
        

        for ((  current_topology = 1 ;  current_topology <= $nb_sim_topologies;  current_topology++  ))
        do

            echo "################################################################################"
            echo "Topology=$current_topology"
            echo "################################################################################"

            #rounds for the same topology
            for ((  current_round = 1 ;  current_round <= $nb_sim_rounds;  current_round++))
            do

                echo "Round" $current_round

                path_logmesh=$path_traces/ns-3.$version/uniformDisk-$radius/phy-$phy/time-$timeSimulation/nbNodes-$nb_nodes-intf-$current_interface-channels-$nb_channels-packetSize-$packetSize/$nb_flows-flows/$packetInterval-packetInterval/topology-$current_topology/round-$current_round

                grep 'Throughput'		$path_logmesh/logMeshSimulation.txt | cut -d: -f2 | cut -d'%' -f1        > $path_results/result_AggregateThroughput
                grep 'DeliveryRate' 		$path_logmesh/logMeshSimulation.txt | cut -d: -f2 | cut -d'%' -f1        > $path_results/result_DeliveryRate
                grep 'DelayMean'		$path_logmesh/logMeshSimulation.txt | cut -d: -f2 | cut -d'%' -f1        > $path_results/result_DelayMean
                # grep 'JitterMean'		$path_logmesh/logMeshSimulation.txt | cut -d: -f2 | cut -d'%' -f1        > $path_results/result_JitterMean

	  			for ((  x = 0 ;  x < $nb_nodes;  x++  ))
				do
				    grep 'droppedTtl=' $path_logmesh/report/mesh-report-$x.xml | cut -d= -f5 | cut -d'"' -f2 >> $path_results/result_droppedTtl
				    grep 'totalQueued=' $path_logmesh/report/mesh-report-$x.xml | cut -d= -f6 | cut -d'"' -f2 >> $path_results/result_totalQueued
				    grep 'totalDropped=' $path_logmesh/report/mesh-report-$x.xml | cut -d= -f7 | cut -d'"' -f2 >> $path_results/result_totalDropped                
				    grep 'initiatedPreq=' $path_logmesh/report/mesh-report-$x.xml | cut -d= -f8 | cut -d'"' -f2 >> $path_results/result_Preq
				    grep 'initiatedPrep=' $path_logmesh/report/mesh-report-$x.xml | cut -d= -f9 | cut -d'"' -f2 >> $path_results/result_Prep
				    grep 'initiatedPerr=' $path_logmesh/report/mesh-report-$x.xml | cut -d= -f10 | cut -d'"' -f2 >> $path_results/result_Perr
				    grep 'txPreq=' $path_logmesh/report/mesh-report-$x.xml | cut -d= -f2 | cut -d'"' -f2 >> $path_results/result_txPreq
				    grep 'txPrep=' $path_logmesh/report/mesh-report-$x.xml | cut -d= -f2 | cut -d'"' -f2 >> $path_results/result_txPrep
				    grep 'txPerr=' $path_logmesh/report/mesh-report-$x.xml | cut -d= -f2 | cut -d'"' -f2 >> $path_results/result_txPerr
				done #x

                cd $path_results
                #pwd
                ### The NR is only for check if there is any value into result_*.
                ### If there is, NR will be always 1. If there isn't, NR will be 0 and execution will show an error.

                # if ! [[ -s result_DelayMean || -s result_DeliveryRate || -s  result_JitterMean ]];
                if ! [[ -s result_DelayMean || -s result_DeliveryRate ]];
                then
                    echo "One of three result (DelayMean, DeliveryRate or JitterMean) is empty."
                    continue
                fi

                sum_AggregateThroughput=`awk '{ s=s+$1 } END {print s}' result_AggregateThroughput`
                if [ "$sum_AggregateThroughput" == '-nan' ];
                then
                    echo "Error: Invalid value in Aggregate Throughput."
                    continue
                fi
                # echo $sum_AggregateThroughput

                average_DeliveryRate=`awk '{ s += $1 } END {print s/NR}' result_DeliveryRate`
                if [ "$average_DeliveryRate" == '-nan' ];
                then
                    echo "Error: Invalid value in DeliveryRate."
                    continue
                fi
                # echo $average_DeliveryRate
                average_DelayMean=`awk '{ s += $1 } END {print s/NR}' result_DelayMean`
                if [ "$average_DelayMean" == '-nan' ];
                then
                    echo "Error: Invalid value in DelayMean."
                    continue
                fi
                # echo $average_DelayMean
                # average_JitterMean=`awk '{ s += $1 } END {print s/NR}' result_JitterMean`
                # pwd
                # len=`expr length "$average_JitterMean"`
                # echo "JitterMean: $average_JitterMean // JitterMean.length: $len"
                # if [ "$average_JitterMean" == '-nan' ];
                # then
                #     echo "Error: Invalid value in JitterMean."
                #     continue
                # fi
                # exit

                # PROTOCOL HWMP
                sum_Preq=`awk '{ s=s+$1 } END {print s}' result_Preq`
                sum_Prep=`awk '{ s=s+$1 } END {print s}' result_Prep`
                sum_Perr=`awk '{ s=s+$1 } END {print s}' result_Perr`
                
                sum_txPreq=`awk '{ s=s+$1 } END {print s}' result_txPreq`
                sum_txPrep=`awk '{ s=s+$1 } END {print s}' result_txPrep`
                sum_txPerr=`awk '{ s=s+$1 } END {print s}' result_txPerr`
                sum_droppedTtl=`awk '{ s=s+$1 } END {print s}' result_droppedTtl`
                
                sum_totalDropped=`awk '{ s=s+$1 } END {print s}' result_totalDropped`
                sum_totalQueued=`awk '{ s=s+$1 } END {print s}' result_totalQueued`
                

                if [[ $sum_Preq == '-nan' || $sum_Preq == [[:space:]]* ]];
                then
                    echo "Error: Invalid value in sum_Preq."
                    continue
                fi
                if [[ $sum_Prep == '-nan' || $sum_Prep == [[:space:]]* ]];
                then
                    echo "Error: Invalid value in sum_Prep."
                    continue
                fi
                if [[ $sum_Perr == '-nan' || $sum_Perr == [[:space:]]* ]];
                then
                    echo "Error: Invalid value in sum_Perr."
                    continue
                fi

                if [[ $sum_txPrep == '-nan' || $sum_txPreq == [[:space:]]* ]];
                then
                    echo "Error: Invalid value in sum_Perr."
                    continue
                fi
                if [[ $sum_txPrep == '-nan' || $sum_txPrep == [[:space:]]* ]];
                then
                    echo "Error: Invalid value in sum_Perr."
                    continue
                fi
                if [[ $sum_txPerr == '-nan' || $sum_txPerr == [[:space:]]* ]];
                then
                    echo "Error: Invalid value in sum_Perr."
                    continue
                fi
                if [[ $sum_droppedTtl == '-nan' || $sum_droppedTtl == [[:space:]]* ]];
                then
                    echo "Error: Invalid value in sum_Perr."
                    continue
                fi
                if [[ $sum_totalDropped == '-nan' || $sum_totalDropped == [[:space:]]* ]];
                then
                    echo "Error: Invalid value in sum_Perr."
                    continue
                fi
                if [[ $sum_totalQueued == '-nan' || $sum_totalQueued == [[:space:]]* ]];
                then
                    echo "Error: Invalid value in sum_Perr."
                    continue
                fi

                # per node
                preq_perNode=`echo "scale=2; $sum_Preq/$nb_nodes" | bc`
                prep_perNode=`echo "scale=2; $sum_Prep/$nb_nodes" | bc`
                perr_perNode=`echo "scale=2; $sum_Perr/$nb_nodes" | bc`

                txpreq_perNode=`echo "scale=2; $sum_txPreq/$nb_nodes" | bc`
                txprep_perNode=`echo "scale=2; $sum_txPrep/$nb_nodes" | bc`
                txperr_perNode=`echo "scale=2; $sum_txPerr/$nb_nodes" | bc`
                droppedttl_perNode=`echo "scale=2; $sum_droppedTtl/$nb_nodes" | bc`
                totaldropped_perNode=`echo "scale=2; $sum_totalDropped/$nb_nodes" | bc`
                totalqueued_perNode=`echo "scale=2; $sum_totalQueued/$nb_nodes" | bc`

                preq_total=`echo "scale=2; $sum_Preq/1" | bc`
                prep_total=`echo "scale=2; $sum_Prep/1" | bc`
                perr_total=`echo "scale=2; $sum_Perr/1" | bc`

                txpreq_total=`echo "scale=2; $sum_txPreq/1" | bc`
                txprep_total=`echo "scale=2; $sum_txPrep/1" | bc`
                txperr_total=`echo "scale=2; $sum_txPerr/1" | bc`

                cd $path_NS3
                # #pwd
                echo $nb_flows $sum_AggregateThroughput >> $path_results/AggregateThroughput/AggregateThroughput-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize
                echo $nb_flows $average_DeliveryRate     	>> $path_results/DeliveryRate/DeliveryRate-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize
                echo $nb_flows $average_DelayMean        	>> $path_results/DelayMean/DelayMean-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize
                # echo $nb_flows $average_JitterMean       	>> $path_results/JitterMean/JitterMean-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize

                echo $nb_flows $preq_perNode			>> $path_results/PreqPerNode/Preq-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s
                echo $nb_flows $prep_perNode			>> $path_results/PrepPerNode/Prep-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s
                echo $nb_flows $perr_perNode			>> $path_results/PerrPerNode/Perr-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s

                echo $nb_flows $txpreq_perNode			>> $path_results/TxPreqPerNode/txPreq-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s
                echo $nb_flows $txprep_perNode			>> $path_results/TxPrepPerNode/txPrep-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s
                echo $nb_flows $txperr_perNode			>> $path_results/TxPerrPerNode/txPerr-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s
                echo $nb_flows $droppedttl_perNode			>> $path_results/DroppedTtlPerNode/droppedTtl-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s
                echo $nb_flows $totaldropped_perNode		>> $path_results/TotalDroppedPerNode/totalDropped-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s
                echo $nb_flows $totalqueued_perNode			>> $path_results/TotalQueuedPerNode/totalQueued-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s

                echo $nb_flows $preq_total		  >> $path_results/PreqTotal/PreqTotal-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s
                echo $nb_flows $prep_total		  >> $path_results/PrepTotal/PrepTotal-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s
                echo $nb_flows $perr_total		  >> $path_results/PerrTotal/PerrTotal-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s

                echo $nb_flows $txpreq_total		  >> $path_results/TxPreqTotal/TxPreqTotal-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s
                echo $nb_flows $txprep_total		  >> $path_results/TxPrepTotal/TxPrepTotal-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s
                echo $nb_flows $txperr_total		  >> $path_results/TxPerrTotal/TxPerrTotal-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s


                rm -r $path_results/result*

            done #round

        done #topology
        # sum_Preq=''
        # sum_Prep=''
        # sum_Perr=''
        # total_msgs=`expr $nb_sim_rounds \* $nb_sim_topologies`
        # sum_Preq=`awk '{ s=s+$2 } END {print s}' $path_results/PreqTotal/Preq-interface-$min_nb_interfaces-nbFlows-$nb_flows-packetSize-$packetSize-original80211s`
        # echo $sum_Preq
        

        # Preq-interface-1-nbFlows-1-packetSize-32-original80211s
        # sum_Prep=`awk '{ s=s+$1 } END {print s}' result_Prep`
        # sum_Perr=`awk '{ s=s+$1 } END {print s}' result_Perr`
        
        # per node
        # preq_perNode=`echo "scale=2; $sum_Preq/$nb_nodes" | bc`
        # prep_perNode=`echo "scale=2; $sum_Prep/$nb_nodes" | bc`
        # perr_perNode=`echo "scale=2; $sum_Perr/$nb_nodes" | bc`


        chmod -R 755 $path_results/AggregateThroughput/.
        chmod -R 755 $path_results/DeliveryRate/.
        chmod -R 755 $path_results/DelayMean/.
        chmod -R 755 $path_results/JitterMean/.
        
        chmod -R 755 $path_results/PreqPerNode/.
        chmod -R 755 $path_results/PrepPerNode/.
        chmod -R 755 $path_results/PerrPerNode/.
        
        chmod -R 755 $path_results/TxPreqPerNode/.
        chmod -R 755 $path_results/TxPrepPerNode/.
        chmod -R 755 $path_results/TxPerrPerNode/.
        chmod -R 755 $path_results/DroppedTtlPerNode/.
        chmod -R 755 $path_results/TotalDroppedPerNode/.
        chmod -R 755 $path_results/TotalQueuedPerNode/.
        
        chmod -R 755 $path_results/TxPreqTotal/.
        chmod -R 755 $path_results/TxPrepTotal/.
        chmod -R 755 $path_results/TxPerrTotal/.


        
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/AggregateThroughput/AggregateThroughput-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize >> $path_plot/AggregateThroughput-packetSize-$packetSize
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/DeliveryRate/DeliveryRate-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize >> $path_plot/DeliveryRate-packetSize-$packetSize
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/DelayMean/DelayMean-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize >> $path_plot/DelayMean-packetSize-$packetSize
        # ./confidenceInterval.sh ci=95 nrvar=1 $path_results/JitterMean/JitterMean-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize >> $path_plot/JitterMean-packetSize-$packetSize


        # Per node
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/PreqPerNode/Preq-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s >> $path_plot/Preq-packetSize-$packetSize
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/PrepPerNode/Prep-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s >> $path_plot/Prep-packetSize-$packetSize
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/PerrPerNode/Perr-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s >> $path_plot/Perr-packetSize-$packetSize
        
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/TxPreqPerNode/txPreq-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s >> $path_plot/txPreq-packetSize-$packetSize
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/TxPrepPerNode/txPrep-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s >> $path_plot/txPrep-packetSize-$packetSize
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/TxPerrPerNode/txPerr-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s >> $path_plot/txPerr-packetSize-$packetSize
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/DroppedTtlPerNode/droppedTtl-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s >> $path_plot/droppedTtl-packetSize-$packetSize
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/TotalDroppedPerNode/totalDropped-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s >> $path_plot/totalDropped-packetSize-$packetSize
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/TotalQueuedPerNode/totalQueued-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s >> $path_plot/totalQueued-packetSize-$packetSize

        # Total
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/PreqTotal/PreqTotal-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s >> $path_plot/PreqTotal-packetSize-$packetSize
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/PrepTotal/PrepTotal-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s >> $path_plot/PrepTotal-packetSize-$packetSize
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/PerrTotal/PerrTotal-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s >> $path_plot/PerrTotal-packetSize-$packetSize


        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/TxPreqTotal/TxPreqTotal-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s >> $path_plot/txPreqTotal-packetSize-$packetSize
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/TxPrepTotal/TxPrepTotal-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s >> $path_plot/txPrepTotal-packetSize-$packetSize
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/TxPerrTotal/TxPerrTotal-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize-original80211s >> $path_plot/txPerrTotal-packetSize-$packetSize
        

    done #packetSize

done #interface
}


configureNS3
configureScenario
configureSimulationParameters
run
