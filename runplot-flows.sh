#!/bin/bash
#NS3
configureNS3(){
    version=29

    path_project=~/workspace
    path_NS3=$path_project/ns-allinone-3.$version/ns-3.$version

    path_traces=$path_NS3/mesh-traces
    path_results=$path_NS3/scriptResults

}

configureScenario(){
    nb_nodes=81
    radius=300
    path_scenario=$path_NS3/mesh-traces/ns-3.$version/uniformDisk-$radius
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
packetInterval=0.1
nb_flows=1

#####SIMULATION ROUNDS#####
#rounds
nb_sim_rounds=6 #number of simulation rounds for each topology
#topology
nb_sim_topologies=5

}

run(){

path_plot=$path_results/plot/packetInterval-$packetInterval-$phy-$nb_flows-flows
mkdir -p $path_plot
mkdir -p $path_results/AggregateThroughput $path_results/DeliveryRate $path_results/DelayMean $path_results/JitterMean


#rm $path_results/*-temp-*


for ((  current_interface = $min_nb_interfaces ;  current_interface <= $max_nb_interfaces;  current_interface++  ))
do

    for packetSize in 32 256 1024 # packetSize = 8 doesn't work
    do

        echo "Uniform disk / $nb_nodes nodes / radius $radius / packetSize $packetSize / packetInterval $packetInterval /  $nb_flows  nb_flows / $nb_sim_topologies topologies / $nb_sim_rounds rounds per topology. "


        rm $path_results/TxPackets/TxPackets-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize
        rm $path_results/RxPackets/RxPackets-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize
        rm $path_results/AggregateThroughput/AggregateThroughput-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize
        rm $path_results/LostPackets/LostPackets-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize
        rm $path_results/DeliveryRate/DeliveryRate-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize
        rm $path_results/DelayMean/DelayMean-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize
        rm $path_results/JitterMean/JitterMean-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize

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
                #pwd
                # grep 'TxPackets'		$path_logmesh/logMeshSimulation.txt | cut -d: -f2 | cut -d'%' -f1        > $path_results/result_TxPackets
                # grep 'RxPackets'		$path_logmesh/logMeshSimulation.txt | cut -d: -f2 | cut -d'%' -f1        > $path_results/result_RxPackets
                grep 'Throughput'		$path_logmesh/logMeshSimulation.txt | cut -d: -f2 | cut -d'%' -f1        > $path_results/result_AggregateThroughput
                # grep 'LostPackets'	$path_logmesh/logMeshSimulation.txt | cut -d: -f2 | cut -d'%' -f1        > $path_results/result_LostPackets
                grep 'DeliveryRate' 		$path_logmesh/logMeshSimulation.txt | cut -d: -f2 | cut -d'%' -f1        > $path_results/result_DeliveryRate
                grep 'DelayMean'		$path_logmesh/logMeshSimulation.txt | cut -d: -f2 | cut -d'%' -f1        > $path_results/result_DelayMean
                grep 'JitterMean'		$path_logmesh/logMeshSimulation.txt | cut -d: -f2 | cut -d'%' -f1        > $path_results/result_JitterMean


                cd $path_results
		#pwd
		### The NR is only for check if there is any value into result_*.
		### If there is, NR will be always 1. If there isn't, NR will be 0 and execution will show an error.
                # sum_TxPackets=`awk '{ s=s+$1 } END {print s}' result_TxPackets`
                # sum_RxPackets=`awk '{ s=s+$1 } END {print s}' result_RxPackets`
                sum_AggregateThroughput=`awk '{ s=s+$1 } END {print s}' result_AggregateThroughput`
                # sum_LostPackets=`awk '{ s=s+$1 } END {print s}' result_LostPackets`
                average_DeliveryRate=`awk '{ s += $1 } END {print s/NR}' result_DeliveryRate`
                average_DelayMean=`awk '{ s += $1 } END {print s/NR}' result_DelayMean`
                average_JitterMean=`awk '{ s += $1 } END {print s/NR}' result_JitterMean`

                cd $path_NS3
                #pwd
                echo $nb_flows $sum_AggregateThroughput >> $path_results/AggregateThroughput/AggregateThroughput-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize
                echo $nb_flows $average_DeliveryRate     	>> $path_results/DeliveryRate/DeliveryRate-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize
                echo $nb_flows $average_DelayMean        	>> $path_results/DelayMean/DelayMean-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize
                echo $nb_flows $average_JitterMean       	>> $path_results/JitterMean/JitterMean-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize

                rm -r $path_results/result*

            done #round

        done #topology

        chmod -R 755 $path_results/AggregateThroughput/.
        chmod -R 755 $path_results/DeliveryRate/.
        chmod -R 755 $path_results/DelayMean/.
        chmod -R 755 $path_results/JitterMean/.



        #  ./confidenceInterval.sh ci=95 nrvar=1 TxPackets/TxPackets-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize >> plot/packetInterval-$packetInterval-$phy/TxPackets-packetSize-$packetSize           				
        #  ./confidenceInterval.sh ci=95 nrvar=1 RxPackets/RxPackets-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize >> plot/packetInterval-$packetInterval-$phy/RxPackets-packetSize-$packetSize
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/AggregateThroughput/AggregateThroughput-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize >> $path_plot/AggregateThroughput-packetSize-$packetSize
        #  ./confidenceInterval.sh ci=95 nrvar=1 LostPackets/LostPackets-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize >> plot/packetInterval-$packetInterval-$phy/LostPackets-packetSize-$packetSize
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/DeliveryRate/DeliveryRate-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize >> $path_plot/DeliveryRate-packetSize-$packetSize
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/DelayMean/DelayMean-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize >> $path_plot/DelayMean-packetSize-$packetSize
        ./confidenceInterval.sh ci=95 nrvar=1 $path_results/JitterMean/JitterMean-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize >> $path_plot/JitterMean-packetSize-$packetSize

        # ./confidenceInterval.sh ci=95 nrvar=1 DroppedTtlL3/DroppedTtlL3-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize >> plot/packetInterval-$packetInterval-$phy/DroppedTtlL3-packetSize-$packetSize
        #    ./confidenceInterval.sh ci=95 nrvar=1 QueuedL3/QueuedL3-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize >> plot/packetInterval-$packetInterval-$phy/QueuedL3-packetSize-$packetSize
        #    ./confidenceInterval.sh ci=95 nrvar=1 DroppedL3/DroppedL3-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize >> plot/packetInterval-$packetInterval-$phy/DroppedL3-packetSize-$packetSize
        #   ./confidenceInterval.sh ci=95 nrvar=1 Preq-initiatedPreq/Preq-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize >> plot/packetInterval-$packetInterval-$phy/Preq-initiatedPreq-packetSize-$packetSize
        #./confidenceInterval.sh ci=95 nrvar=1 Preq-initiatedPreqProactive/Preq-nb_nodes-$nb_nodes-rootPosition-$rootPosition-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-original80211s 	 >> plot/scenario-$scenario-$rootPosition-packetSize-$packetSize-packetInterval-$packetInterval-flows-$nb_flows-$phy/Preq-initiatedPreqProactive-interface-$current_interface-original80211s
        #./confidenceInterval.sh ci=95 nrvar=1 Preq-retransmittedPreq/Preq-nb_nodes-$nb_nodes-rootPosition-$rootPosition-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-original80211s    		 >> plot/scenario-$scenario-$rootPosition-packetSize-$packetSize-packetInterval-$packetInterval-flows-$nb_flows-$phy/Preq-retransmittedPreq-interface-$current_interface-original80211s
        #  ./confidenceInterval.sh ci=95 nrvar=1 Preq-total/Preq-nb_nodes-$nb_nodes-rootPosition-$rootPosition-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-original80211s >> plot/scenario-$scenario-$rootPosition-packetSize-$packetSize-packetInterval-$packetInterval-flows-$nb_flows-$phy/Preq-total-interface-$current_interface-original80211s
        #   ./confidenceInterval.sh ci=95 nrvar=1 Prep-total/Prep-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize >> plot/packetInterval-$packetInterval-$phy/Prep-total-packetSize-$packetSize
        #   ./confidenceInterval.sh ci=95 nrvar=1 Perr-total/Perr-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize		 >> plot/packetInterval-$packetInterval-$phy/Perr-total-packetSize-$packetSize
        #   ./confidenceInterval.sh ci=95 nrvar=1 RoutingControlPackets/RoutingControlPackets-nb_nodes-$nb_nodes-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-packetSize-$packetSize >> plot/packetInterval-$packetInterval-$phy/RoutingControlPackets-packetSize-$packetSize
        #./confidenceInterval.sh ci=95 nrvar=1 txMngtxDataHWMP/txMngBytesHWMP-nb_nodes-$nb_nodes-rootPosition-$rootPosition-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-original80211s	 	 >> plot/scenario-$scenario-$rootPosition-packetSize-$packetSize-packetInterval-$packetInterval-flows-$nb_flows-$phy/txMngBytesHWMP-interface-$current_interface-original80211s
        #./confidenceInterval.sh ci=95 nrvar=1 txMngtxDataHWMP/txDataBytesHWMP-nb_nodes-$nb_nodes-rootPosition-$rootPosition-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-original80211s	 	 >> plot/scenario-$scenario-$rootPosition-packetSize-$packetSize-packetInterval-$packetInterval-flows-$nb_flows-$phy/txDataBytesHWMP-interface-$current_interface-original80211s
        #./confidenceInterval.sh ci=95 nrvar=1 PMP/txOpenPMP-nb_nodes-$nb_nodes-rootPosition-$rootPosition-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-original80211s	 	         	 >> plot/scenario-$scenario-$rootPosition-packetSize-$packetSize-packetInterval-$packetInterval-flows-$nb_flows-$phy/txOpenPMP-interface-$current_interface-original80211s
        #./confidenceInterval.sh ci=95 nrvar=1 PMP/txConfirmPMP-nb_nodes-$nb_nodes-rootPosition-$rootPosition-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-original80211s	 	         >> plot/scenario-$scenario-$rootPosition-packetSize-$packetSize-packetInterval-$packetInterval-flows-$nb_flows-$phy/txConfirmPMP-interface-$current_interface-original80211s  
        #./confidenceInterval.sh ci=95 nrvar=1 PMP/txClosePMP-nb_nodes-$nb_nodes-rootPosition-$rootPosition-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-original80211s	 	        	 >> plot/scenario-$scenario-$rootPosition-packetSize-$packetSize-packetInterval-$packetInterval-flows-$nb_flows-$phy/txClosePMP-interface-$current_interface-original80211s
        #./confidenceInterval.sh ci=95 nrvar=1 PMP/txMngBytesPMP-nb_nodes-$nb_nodes-rootPosition-$rootPosition-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-original80211s	 	     	 >> plot/scenario-$scenario-$rootPosition-packetSize-$packetSize-packetInterval-$packetInterval-flows-$nb_flows-$phy/txMngBytesPMP-interface-$current_interface-original80211s  
        #./confidenceInterval.sh ci=95 nrvar=1 PMP/droppedPMP-nb_nodes-$nb_nodes-rootPosition-$rootPosition-interface-$current_interface-flows-$nb_flows-packetInterval-$packetInterval-original80211s				 >> plot/scenario-$scenario-$rootPosition-packetSize-$packetSize-packetInterval-$packetInterval-flows-$nb_flows-$phy/droppedPMP-interface-$current_interface-original80211s


    done #packetSize

done #interface


}

plot(){

    cd $path_results/plot

ls

    cp  $path_results/plot/packetInterval-$packetInterval-$phy/* $path_results/plot/.


ls

    gnuplot TxPackets.plot
    gnuplot RxPackets.plot
    gnuplot AggregateThroughput.plot
    gnuplot LostPackets.plot
    gnuplot DeliveryRate.plot
    gnuplot DelayMean.plot
    gnuplot JitterMean.plot
    #gnuplot TimesForwarded.pĺot
    #gnuplot RxBytes.plot
    #gnuplot DropMacQueue.plot 
    #gnuplot FramesSentTotal.plot 
    #gnuplot FramesSentData.plot 
    #gnuplot FramesSentMng.plot	
    gnuplot DroppedTtlL3.plot
    gnuplot QueuedL3.plot
    gnuplot DroppedL3.plot
    gnuplot Preq-initiatedPreq.plot
    #gnuplot Preq-initiatedPreqProactive.plot
    #gnuplot Preq-retransmittedPreq.plot
    #gnuplot Preq-total.plot
    gnuplot Prep-total.plot
    gnuplot Perr-total.plot
    gnuplot RoutingControlPackets.plot
    #gnuplot txMngtxDataHWMP.plot
    #gnuplot txMngHWMP.plot
    #gnuplot txOpenPMP.plot
    #gnuplot txConfirmPMP.plot
    #gnuplot txClosePMP.plot
    #gnuplot txMngPMP.plot
    #gnuplot droppedPMP.plot
            
    epstopdf TxPackets.eps
    epstopdf RxPackets.eps
    epstopdf AggregateThroughput.eps
    epstopdf LostPackets.eps
    epstopdf DeliveryRate.eps
    epstopdf DelayAverage.eps
    epstopdf JitterAverage.eps
    #epstopdf TimesForwarded.eps
    #epstopdf RxBytes.eps
    #epstopdf DropMacQueue.eps
    #epstopdf pps-FramesSentTotal.eps
    #epstopdf pps-FramesSentData.eps
    #epstopdf pps-FramesSentMng.eps
    epstopdf DroppedTtlL3.eps
    epstopdf QueuedL3.eps
    epstopdf DroppedL3.eps
    epstopdf Preq-initiatedPreq.eps
    #epstopdf Preq-initiatedPreqProactive.eps
    #epstopdf Preq-retransmittedPreq.eps
    #epstopdf Preq-total.eps
    epstopdf Prep-total.eps
    epstopdf Perr-total.eps
    epstopdf RoutingControlPackets.eps
    #epstopdf txMngtxDataHWMP.eps
    #epstopdf txMngHWMP.eps
    #epstopdf txOpenPMP.eps
    #epstopdf txConfirmPMP.eps
    #epstopdf txClosePMP.eps
    #epstopdf txMngPMP.eps
    #epstopdf droppedPMP.eps


   mv TxPackets.pdf 		    		TxPackets-packetInterval-$packetInterval-$phy-nb_nodes-$nb_nodes.pdf
   mv RxPackets.pdf 		   		RxPackets-packetInterval-$packetInterval-$phy-nb_nodes-$nb_nodes.pdf
   mv AggregateThroughput.pdf 	AggregateThroughput-packetInterval-$packetInterval-$phy-nb_nodes-$nb_nodes.pdf
   mv LostPackets.pdf 	        	LostPackets-packetInterval-$packetInterval-$phy-nb_nodes-$nb_nodes.pdf
   mv DeliveryRate.pdf 		    	DeliveryRate-packetInterval-$packetInterval-$phy-nb_nodes-$nb_nodes.pdf
   mv DelayAverage.pdf 		    	DelayAverage-packetInterval-$packetInterval-$phy-nb_nodes-$nb_nodes.pdf
   mv JitterAverage.pdf 		 	JitterAverage-packetInterval-$packetInterval-$phy-nb_nodes-$nb_nodes.pdf
   #mv TimesForwarded.pdf 		TimesForwarded-scenario-$scenario-$rootPosition-packetSize-$packetSize-packetInterval-$packetInterval-flows-$nb_flows-$phy.pdf
    ##mvDropMacQueue.pdf 		DropMacQueue-flows-$nb_flows.pdf 
    mv DroppedTtlL3.pdf 		DroppedTtlL3-packetInterval-$packetInterval-$phy-nb_nodes-$nb_nodes.pdf
    mv QueuedL3.pdf 		QueuedL3-packetInterval-$packetInterval-$phy-nb_nodes-$nb_nodes.pdf
    mv DroppedL3.pdf 		DroppedL3-packetInterval-$packetInterval-$phy-nb_nodes-$nb_nodes.pdf
    ##mvPreq.pdf Preq-perNode-flows-$nb_flows.pdf 
    mv Preq-initiatedPreq.pdf          Preq-initiatedPreq-packetInterval-$packetInterval-$phy-nb_nodes-$nb_nodes.pdf
   # mv Preq-initiatedPreqProactive.pdf Preq-initiatedPreqProactive-scenario-$scenario-$rootPosition-packetSize-$packetSize-packetInterval-$packetInterval-flows-$nb_flows-$phy.pdf
   # mv Preq-retransmittedPreq.pdf      Preq-retransmittedPreq-scenario-$scenario-$rootPosition-packetSize-$packetSize-packetInterval-$packetInterval-flows-$nb_flows-$phy.pdf
   # mv Preq-total.pdf                  Preq-total-scenario-$scenario-$rootPosition-packetSize-$packetSize-packetInterval-$packetInterval-flows-$nb_flows-$phy.pdf
    mv Prep-total.pdf                  Prep-total-packetInterval-$packetInterval-$phy-nb_nodes-$nb_nodes.pdf
    mv Perr-total.pdf                  Perr-total-packetInterval-$packetInterval-$phy-nb_nodes-$nb_nodes.pdf
    mv RoutingControlPackets.pdf 	   RoutingControlPackets-packetInterval-$packetInterval-$phy-nb_nodes-$nb_nodes.pdf
    #mvtxMngtxDataHWMP.pdf  	    txMngtxDataHWMP-flows-$nb_flows.pdf 
    #mvtxMngHWMP.pdf  	      	    txMngHWMP-flows-$nb_flows.pdf 
    #mvtxOpenPMP.pdf 		    txOpenPMP-flows-$nb_flows.pdf 
    #mvtxConfirmPMP.pdf 		    txConfirmPMP-flows-$nb_flows.pdf 
    #mvtxClosePMP.pdf 		    txClosePMP-flows-$nb_flows.pdf 
    #mvtxMngPMP.pdf 		    txMngPMP-flows-$nb_flows.pdf 
    #mvdroppedPMP.pdf 		    droppedPMP-flows-$nb_flows.pdf 


    mkdir -p $path_results/Results-PDF/nodes-$nb_nodes-packetInterval-$packetInterval-$phy
    mv *.pdf $path_results/Results-PDF/nodes-$nb_nodes-packetInterval-$packetInterval-$phy/.

    rm -rf *.eps
    rm $path_results/plot/*-packetSize-*

}


configureNS3
configureScenario
configureSimulationParameters
run
#plot


