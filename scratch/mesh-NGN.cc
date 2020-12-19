/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */
/*
 * Copyright (c) 2008,2009 IITP RAS
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation;
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Author: Kirill Andreev <andreev@iitp.ru>
 *
 *
 * By default this script creates m_xSize * m_ySize square grid topology with
 * IEEE802.11s stack installed at each node with peering management
 * and HWMP protocol.
 * The side of the square cell is defined by m_step parameter.
 * When topology is created, UDP ping is installed to opposite corners
 * by diagonals. packet size of the UDP ping and interval between two
 * successive packets is configurable.
 * 
 *  m_xSize * step
 *  |<--------->|
 *   step
 *  |<--->|
 *  * --- * --- * <---Ping sink  _
 *  | \   |   / |                ^
 *  |   \ | /   |                |
 *  * --- * --- * m_ySize * step |
 *  |   / | \   |                |
 *  | /   |   \ |                |
 *  * --- * --- *                _
 *  ^ Ping source
 *
 *  See also MeshTest::Configure to read more about configurable
 *  parameters.
 */

#include <iostream>
#include <sstream>
#include <fstream>
#include <string>
#include <vector>
#include <utility> // std::pair
#include "ns3/core-module.h"
#include "ns3/internet-module.h"
#include "ns3/network-module.h"
#include "ns3/applications-module.h"
#include "ns3/mesh-module.h"
#include "ns3/mobility-module.h"
#include "ns3/mesh-helper.h"
#include "ns3/yans-wifi-helper.h"

#include "ns3/flow-monitor-module.h"
#include "ns3/flow-monitor-helper.h"

using namespace ns3;

NS_LOG_COMPONENT_DEFINE ("TestMeshScript");

/**
 * \ingroup mesh
 * \brief MeshTest class
 */
class MeshTest
{
public:
  /// Init test
  MeshTest ();
  /**
   * Configure test from command line arguments
   *
   * \param argc command line argument count
   * \param argv command line arguments
   */
  void Configure (int argc, char ** argv);
  /**
   * Run test
   * \returns the test status
   */
  int Run ();
private:
  int       m_xSize;                ///< X size
  int       m_ySize;                ///< Y size
  int       m_standardPhy;          /// carina: set phy layer
  int       m_numFlows;             /// carina: set num flows
  double    m_step;                 ///< step
  double    m_randomStart;          ///< random start
  double    m_totalTime;            ///< total time
  double    m_packetInterval;       ///< packet interval
  float     m_timeStartFlowSources; /// carina:
  uint16_t  m_packetSize;           ///< packet size
  uint32_t  m_nIfaces;              ///< number interfaces
  bool      m_chan;     ///< channel
  bool      m_pcap;     ///< PCAP
  bool      m_ascii;    ///< ASCII
  std::string m_stack;  ///< stack
  std::string m_root;   ///< root
  float delivery_rate;  /// Rui: parameter to report file
  float throughput;     /// Rui: parameter to report file
  float delay_mean;     /// Rui: parameter to report file
  float jitter_mean;    /// Rui: parameter to report file
  /// List of network nodes
  NodeContainer nodes;
  /// List of all mesh point devices
  NetDeviceContainer meshDevices;
  /// Addresses of interfaces:
  Ipv4InterfaceContainer interfaces;
  /// MeshHelper. Report is not static methods
  MeshHelper mesh;
private:
  /// Create nodes and setup their mobility
  void CreateNodes ();
  //carina: Show position of nodes (physical topology)
  void PrintPositionNodes ();
  /// Install internet m_stack on nodes
  void InstallInternetStack ();
  bool ExistSource (int candidateSource,int sizeVector, int vec[]);
  /// Install applications
  void InstallApplication ();
  /// Print mesh devices diagnostics
  void Report ();
  // Print mesh parameters
  void Write_csv();
};
MeshTest::MeshTest () :
  m_xSize (2),
  m_ySize (1),
  m_standardPhy(1), //1 a / 2 b / 3 g
  m_numFlows(1),
  m_step (80),
  m_randomStart (0.1),
  m_totalTime (30.0),
  m_packetInterval (0.0001),
  m_timeStartFlowSources(1),
  m_packetSize (1024),
  m_nIfaces (1),
  m_chan (true),
  m_pcap (false),
  m_ascii (false),
  m_stack ("ns3::Dot11sStack"),
  m_root ("ff:ff:ff:ff:ff:ff"),
  delivery_rate(0),
  throughput(0),
  delay_mean(0),
  jitter_mean(0)
{
}
void
MeshTest::Configure (int argc, char *argv[])
{
  std::cout << "argc: " << argc << ";" << std::endl;  
  std::cout <<"argv[0]: " << argv[0] << std::endl;
  std::cout <<"argv[1]: " << argv[1] << std::endl;
  CommandLine cmd;
  cmd.AddValue ("x-size", "Number of nodes in a row grid", m_xSize);
  cmd.AddValue ("y-size", "Number of rows in a grid", m_ySize);
  cmd.AddValue ("phy",   "phy Layer [1-802.11a]", m_standardPhy);
  cmd.AddValue ("numFlows", "Number of flows. [1]", m_numFlows);
  cmd.AddValue ("step",   "Size of edge in our grid (meters)", m_step);
  // Avoid starting all mesh nodes at the same time (beacons may collide)
  cmd.AddValue ("start",  "Maximum random start delay for beacon jitter (sec)", m_randomStart);
  cmd.AddValue ("time",  "Simulation time (sec)", m_totalTime);
  cmd.AddValue ("packet-interval",  "Interval between packets in UDP ping (sec)", m_packetInterval);
  cmd.AddValue ("timeStartFlowSources",  "Time to start source flows, seconds [1 s]", m_timeStartFlowSources);
  cmd.AddValue ("packet-size",  "Size of packets in UDP ping (bytes)", m_packetSize);
  cmd.AddValue ("interfaces", "Number of radio interfaces used by each mesh point", m_nIfaces);
  cmd.AddValue ("channels",   "Use different frequency channels for different interfaces", m_chan);
  cmd.AddValue ("pcap",   "Enable PCAP traces on interfaces", m_pcap);
  cmd.AddValue ("ascii",   "Enable Ascii traces on interfaces", m_ascii);
  cmd.AddValue ("stack",  "Type of protocol stack. ns3::Dot11sStack by default", m_stack);
  cmd.AddValue ("root", "Mac address of root mesh point in HWMP", m_root);

  cmd.Parse (argc, argv);
  NS_LOG_DEBUG ("Grid:" << m_xSize << "*" << m_ySize);
  NS_LOG_DEBUG ("Simulation time: " << m_totalTime << " s");
  if (m_ascii)
    {
      PacketMetadata::Enable ();
    }
}
enum WifiPhyStandard getEnumFromString(int phy)
{
    //ps: src/wifi/model/wifi-phy-standard.h
    switch(phy)
    {   case 1:
            return WIFI_PHY_STANDARD_80211a; //OFDM PHY 5 GHz
        case 2:
            return WIFI_PHY_STANDARD_80211b;//2.4 GHz
        case 3:
            return WIFI_PHY_STANDARD_80211g;//2.4 GHz
        //case 4:
            //return WIFI_PHY_STANDARD_80211n_2_4GHZ; //n funciona
        //case 5: 
           // return WIFI_PHY_STANDARD_80211n_5GHZ;//n funciona
        default:
            return WIFI_PHY_STANDARD_80211a;
    }
}
void
MeshTest::CreateNodes ()
{ 
  /*
   * Create m_ySize*m_xSize stations to form a grid topology
   */
  nodes.Create (m_ySize*m_xSize);
  // Configure YansWifiChannel
  YansWifiPhyHelper wifiPhy = YansWifiPhyHelper::Default ();
  YansWifiChannelHelper wifiChannel = YansWifiChannelHelper::Default ();
  wifiPhy.SetChannel (wifiChannel.Create ());
  /*
   * Create mesh helper and set stack installer to it
   * Stack installer creates all needed protocols and install them to
   * mesh point device
   */
  mesh = MeshHelper::Default ();
  if (!Mac48Address (m_root.c_str ()).IsBroadcast ())
    {
      mesh.SetStackInstaller (m_stack, "Root", Mac48AddressValue (Mac48Address (m_root.c_str ())));
    }
  else
    {
      //If root is not set, we do not use "Root" attribute, because it
      //is specified only for 11s
      mesh.SetStackInstaller (m_stack);
    }
  if (m_chan)
    {
      mesh.SetSpreadInterfaceChannels (MeshHelper::SPREAD_CHANNELS);
    }
  else
    {
      mesh.SetSpreadInterfaceChannels (MeshHelper::ZERO_CHANNEL);
    }

  mesh.SetStandard(getEnumFromString(m_standardPhy));

  mesh.SetMacType ("RandomStart", TimeValue (Seconds (m_randomStart)));
  // Set number of interfaces - default is single-interface mesh point
  mesh.SetNumberOfInterfaces (m_nIfaces);
  // Install protocols and return container if MeshPointDevices
  meshDevices = mesh.Install (wifiPhy, nodes);
  // Setup mobility - static grid topology
  MobilityHelper mobility;
  //SeedManager::SetSeed (4);

  mobility.SetPositionAllocator ("ns3::GridPositionAllocator",
                                 "MinX", DoubleValue (0.0),
                                 "MinY", DoubleValue (0.0),
                                 "DeltaX", DoubleValue (m_step),
                                 "DeltaY", DoubleValue (m_step),
                                 "GridWidth", UintegerValue (m_xSize),
                                 "LayoutType", StringValue ("RowFirst"));
  mobility.SetMobilityModel ("ns3::ConstantPositionMobilityModel");
  mobility.Install (nodes);
  if (m_pcap)
    wifiPhy.EnablePcapAll (std::string ("mp-"));
  if (m_ascii)
    {
      AsciiTraceHelper ascii;
      wifiPhy.EnableAsciiAll (ascii.CreateFileStream ("mesh.tr"));
    }

    PrintPositionNodes();
}
void
MeshTest::PrintPositionNodes ()
{

    NS_LOG_DEBUG ("\nPosition of nodes: ");

    NodeContainer const & n = NodeContainer::GetGlobal ();

    for (NodeContainer::Iterator i = n.Begin (); i != n.End (); ++i)
    {
        Ptr<Node> node = *i;
        Ptr<MobilityModel> mob = node->GetObject<MobilityModel> ();

        if (! mob) continue; // Strange -- node has no mobility model installed. Skip.
        Vector pos = mob->GetPosition ();

        std::cout << "Node is at (" << pos.x << ", " << pos.y << ")\n";
    }
}
void
MeshTest::InstallInternetStack ()
{
  InternetStackHelper internetStack;
  internetStack.Install (nodes);
  Ipv4AddressHelper address;
  address.SetBase ("10.1.1.0", "255.255.255.0");
  interfaces = address.Assign (meshDevices);
}
bool
MeshTest::ExistSource (int candidateSource,int sizeVector, int vec[])
{
  /*std::cout <<  "sources=";
  for(int i=0; i < sizeVector; i++){
    std::cout << vec[i]<< " ";
  }
  std::cout <<  "\n";*/

  for(int i=0; i < sizeVector; i++){
      if (candidateSource == vec[i]){
          //std::cout << candidateSource << " is already a source. Search Next.\n";
          return true;}
  }
  
  //std::cout << candidateSource << " is NOT a source\n\n";

  return false;
}
void
MeshTest::InstallApplication ()
{
  /*UdpEchoServerHelper echoServer (9);
  ApplicationContainer serverApps = echoServer.Install (nodes.Get (0));
  serverApps.Start (Seconds (0.0));
  serverApps.Stop (Seconds (m_totalTime));
  UdpEchoClientHelper echoClient (interfaces.GetAddress (0), 9);
  echoClient.SetAttribute ("MaxPackets", UintegerValue ((uint32_t)(m_totalTime*(1/m_packetInterval))));
  echoClient.SetAttribute ("Interval", TimeValue (Seconds (m_packetInterval)));
  echoClient.SetAttribute ("PacketSize", UintegerValue (m_packetSize));
  ApplicationContainer clientApps = echoClient.Install (nodes.Get (m_xSize*m_ySize-1));
  clientApps.Start (Seconds (0.0));
  clientApps.Stop (Seconds (m_totalTime));*/
  
  int sources[m_numFlows];
  int candidateSource;
  int limit = ((m_xSize*m_ySize)-1);

  UdpServerHelper server (9);
  //node 0 is always the server
  ApplicationContainer serverApps = server.Install (nodes.Get (0));
  serverApps.Start (Seconds (0.0));
  serverApps.Stop (Seconds (m_totalTime));

  UdpClientHelper client (interfaces.GetAddress (0), 9);
  client.SetAttribute ("MaxPackets", UintegerValue ((uint32_t)(m_totalTime*(1/m_packetInterval))));
  client.SetAttribute ("Interval", TimeValue (Seconds (m_packetInterval)));
  client.SetAttribute ("PacketSize", UintegerValue (m_packetSize));

  //ApplicationContainer clientApps = client.Install (nodes.Get (m_xSize*m_ySize-1));
  //clientApps.Start (Seconds (10.0));
  //clientApps.Stop (Seconds (m_totalTime));
  ApplicationContainer clientApps;
  srand(time(NULL));
  for (int index=0; index < m_numFlows; ++index) {
      //std::cout << "Flow " << (index+1)<< "\n" ;
      candidateSource = 1 + (rand() % (limit));
      //std::cout << "*candidateSource: " << candidateSource<< "\n" ;

      while(ExistSource(candidateSource,index,sources)){
          candidateSource = 1 + (rand() % (limit));
          //std::cout << "candidateSource: " << candidateSource<< "\n" ;
      }
      sources[index] = candidateSource;
      clientApps = client.Install (nodes.Get (candidateSource));
      clientApps.Start (Seconds (m_timeStartFlowSources*(0.01*candidateSource)));
  }
  clientApps.Stop (Seconds (Seconds (m_totalTime-2)));

}
int
MeshTest::Run ()
{
  int counterNbFlow = 0;
  int count = 0;

  // while (counterNbFlow < m_samples-1 ) 
  // {
    CreateNodes ();
    InstallInternetStack ();
    InstallApplication ();

    FlowMonitorHelper flowmon;
    Ptr<FlowMonitor> monitor = flowmon.InstallAll ();
    std::vector< ns3::Ptr<ns3::FlowProbe> > flowProbes = monitor->GetAllProbes ();


    Simulator::Schedule (Seconds (m_totalTime), &MeshTest::Report, this);
    Simulator::Stop (Seconds (m_totalTime));
    Simulator::Run ();

    monitor->SerializeToXmlFile("results.xml", true, true);
    monitor->CheckForLostPackets ();

    Ptr<Ipv4FlowClassifier> classifier = DynamicCast<Ipv4FlowClassifier> (flowmon.GetClassifier ());
    std::map<FlowId, FlowMonitor::FlowStats> stats = monitor->GetFlowStats ();
    for (std::map<FlowId, FlowMonitor::FlowStats>::const_iterator i = stats.begin (); i != stats.end (); ++i)
    {
      Ipv4FlowClassifier::FiveTuple t = classifier->FindFlow (i->first);
      if (i->second.rxBytes > 0) 
      {
        std::cout << "  Wireless Mesh Network IEEE ";
        switch (m_standardPhy)
        {
        case 1:
          std::cout << "802.11a" << std::endl;
          break;

        case 2:
          std::cout << "802.11b" << std::endl;
          break;

        case 3:
          std::cout << "802.11g" << std::endl;
          break;
        
        default:
          break;
        }
        delivery_rate = (i->second.rxPackets * 100.0)/ (i->second.txPackets);
        throughput = i->second.rxBytes * 8.0 / 10.0 / 1024 / 1024;
        delay_mean = (i->second.delaySum.GetSeconds()) / (i->second.rxPackets);
        jitter_mean = (i->second.jitterSum.GetSeconds()) / (i->second.rxPackets -1);

        std::cout << "  Flow " << i->first << " (" << t.sourceAddress << " -> " << t.destinationAddress << ")\n";
        std::cout << "  DeliveyRate:                 " << delivery_rate << " %\n";
        std::cout << "  Throughput:                  " << throughput  << " Mbps\n";
        std::cout << "  TxBytes:                     " << i->second.txBytes << "\n";
        std::cout << "  RxBytes:                     " << i->second.rxBytes << "\n";
        std::cout << "  TxPackets:                   " << i->second.txPackets << "\n";
        std::cout << "  RxPackets:                   " << i->second.rxPackets << "\n";
        //std::cout << "  LostPackets:	               " << (i->second.lostPackets) << "\n";
        //std::cout << "  DelaySum:                    " << i->second.delaySum.GetSeconds()<< " s\n";
        std::cout << "  DelayMean:                   " << delay_mean << " s\n";
        //std::cout << "  JitterSum:                   " << i->second.jitterSum.GetSeconds()<< " s\n";
        std::cout << "  JitterMean:                  " << jitter_mean << " s\n";
        std::cout << "  TimeFirstTxPacket:           " << i->second.timeFirstTxPacket.GetSeconds() << " s\n";
        std::cout << "  TimeLastTxPacket:            " << i->second.timeLastTxPacket.GetSeconds() << " s\n";
        std::cout << "  TimeFirstRxPacket:           " << i->second.timeFirstRxPacket.GetSeconds() << " s\n";
        std::cout << "  TimeLastRxPacket:            " << i->second.timeLastRxPacket.GetSeconds() << " s\n";
        //std::cout << "  MeanTransmittedPacketSize:   " << (i->second.txBytes) / (i->second.txPackets) << " byte\n";
        //std::cout << "  MeanTransmittedBitrate:      " << ((i->second.txBytes) * 8.0) / ((i->second.timeLastTxPacket.GetSeconds())-(i->second.timeFirstTxPacket.GetSeconds())) << " bit/s\n";
        //std::cout << "  MeanHopCount:                " << (i->second.timesForwarded) / (i->second.rxPackets) + 1 << "\n";
        //std::cout << "  PacketLossRatio:             " << (i->second.lostPackets) / ((i->second.rxPackets)+(i->second.lostPackets)) << "\n";
        //std::cout << "  MeanReceivedPacketSize:      " << (i->second.rxBytes) / (i->second.rxPackets) << " byte\n";
        //std::cout << "  MeanReceivedBitrate:         " << ((i->second.rxBytes)* 8.0) / ((i->second.timeLastRxPacket.GetSeconds())-(i->second.timeFirstRxPacket.GetSeconds())) << " bit/s \n";

        counterNbFlow++;
      }
    }
    count++;
    // vec(m_samples, scond.)
    std::cout << "Counter: " << count << std::endl;
    MeshTest::Write_csv ();
    Simulator::Destroy ();
  // }
  return 0;
}
void
MeshTest::Report ()
{
  unsigned n (0);
  for (NetDeviceContainer::Iterator i = meshDevices.Begin (); i != meshDevices.End (); ++i, ++n)
    {
      std::ostringstream os;
      os << "mp-report-" << n << ".xml";
      std::cerr << "Printing mesh point device #" << n << " diagnostics to " << os.str () << "\n";
      std::ofstream of;
      of.open (os.str ().c_str ());
      if (!of.is_open ())
        {
          std::cerr << "Error: Can't open file " << os.str () << "\n";
          return;
        }
      mesh.Report (*i, of);
      of.close ();
    }
}
void
MeshTest::Write_csv(){

    // Create an output filestream object
    std::string filename = "mp-report.csv";
    bool hasFile = true;
    std::string header = "DeliveryRate,Throughput,DelayMean,JitterMean,";
    std::fstream myReport(filename, std::ios::in);  //open a file to perform read operation using file object
    std::vector<std::string> v_string; // Created to store the lines from .csv files and to update new data
    
    if (myReport.fail()) { 
      hasFile = false;
      std::cerr << "Failed! There isn't " << filename << " in directory.";
      v_string.push_back(header + "\n");
      std::cerr << "Header in Vector: " << v_string.at(0) << "\n";      
    }

    // Reading the existing report .csv file
    if (myReport.is_open() && hasFile)   //checking whether the file is open
    {
      std::cerr << "File opened!" << "\n";
      std::string tp;
      while (std::getline(myReport, tp)) //read data from file object and put it into string.
      {
        if (!tp.empty()) 
        {
          v_string.push_back(tp + "\n");
        } else { 
          v_string.push_back(header + "\n");
        }
      }
      myReport.close(); //close the file object.
    }
    // Printing what was readed at existing file
    std::cerr << "Printing what was readed at existing file..." << std::endl;
    std::for_each(v_string.begin(), v_string.end(), [](std::string vs)
    {
      std::cerr << "vector before: " << vs;
    });

    // int it = v_string.begin();
    // for (it; it != v_string.end(); it++){
    //   std::cerr << "pass here" << std::endl;
    // }
    // Updating the lines added
    v_string.push_back(
      std::to_string(delivery_rate)+","+
      std::to_string(throughput)+","+
      std::to_string(delay_mean)+","+
      std::to_string(jitter_mean)+","+
      "\n"
    );
    std::cerr << "\n";
    // Reading the lines that they were added
    std::for_each(v_string.begin(), v_string.end(), [](std::string s)
    {
      std::cerr << "vector after: " << s;
    });
    std::cerr << "\n";
    // Writing the lines to the mp-report.csv file
    std::cerr << "Writing mesh simulate diagnostics to " << filename << std::endl;
    myReport.open(filename, std::ios::out);  // open a file to perform write operation using file object
    if (myReport.is_open())
    {
      std::for_each(v_string.begin(), v_string.end(), [&myReport](std::string s)
      {
        myReport << s;
      });      
    }
    myReport.close();
    std::cerr << "mp-report.csv was closed!" << std::endl;
}
int
main (int argc, char *argv[])
{
    MeshTest t;
    t.Configure (argc, argv);
    return t.Run ();
}
