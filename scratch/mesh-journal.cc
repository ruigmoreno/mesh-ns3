#include "ns3/core-module.h"
#include "ns3/internet-module.h"
#include "ns3/network-module.h"
#include "ns3/applications-module.h"
#include "ns3/wifi-module.h"
#include "ns3/mesh-module.h"
#include "ns3/mobility-module.h"
#include "ns3/mesh-helper.h"

#include "ns3/flow-monitor-module.h"
#include "ns3/flow-monitor-helper.h"

#include <ctime>
#include <time.h>
#include <iostream>
#include <sstream>
#include <fstream>

using namespace ns3;

NS_LOG_COMPONENT_DEFINE ("TestMeshScript");

class MeshJournal
{
public:
  /// Init test
  MeshJournal ();
  /// Configure test from command line arguments
  void Configure (int argc, char ** argv);
  /// Run test
  int Run ();
private:
  //int       m_xSize;
  //int       m_ySize;
  int       m_nbNodes;
  int       m_numFlows;
  int       m_seed;
  //double    m_step;
  double    m_radius;
  double    m_randomStart;
  double    m_totalTime;
  double    m_packetInterval;
  float     m_timeStartFlowSources;   // ?????
  uint16_t  m_packetSize;
  uint32_t  m_nIfaces;
  bool      m_chan;                   /* ???? */
  bool      m_pcap;                   /* ???? */
  bool      m_report;
  bool      m_discovery; //(0) false (1) true

  std::string m_stack;
  std::string m_root;
  std::vector<std::string> v_string; // Created to store the output
  /// List of network nodes
  NodeContainer nodes;
  /// List of all mesh point devices
  NetDeviceContainer meshDevices;
  //Addresses of interfaces:
  Ipv4InterfaceContainer interfaces;
  // MeshHelper. Report is not static methods
  MeshHelper mesh;
private:
  /// Create nodes and setup their mobility
  void CreateNodes ();
  void PrintPositionNodes ();
  /// Install internet m_stack on nodes
  void InstallInternetStack ();
  bool ExistSource (int candidateSource,int sizeVector, int vec[]);
  /// Install applications
  void InstallApplication ();
  /// Print mesh devices diagnostics
  void Report ();
  void WriteToBeUsedScriptTopology();
};
MeshJournal::MeshJournal () :
  //m_xSize (2),
  //m_ySize (1),
  m_nbNodes (10),
  m_numFlows(1),
  m_seed (1),
  //m_step (100.0),
  m_radius (100.0),
  m_randomStart (0.1),
  m_totalTime (30.0),
  m_packetInterval (0.1),
  m_timeStartFlowSources(1),
  m_packetSize (512),
  m_nIfaces (1),
  m_chan (true),
  m_pcap (false),
  m_report(true),
  m_discovery (false),
  m_stack ("ns3::Dot11sStack"),
  m_root ("ff:ff:ff:ff:ff:ff")
{
}
void
MeshJournal::Configure (int argc, char *argv[])
{
  CommandLine cmd;
  //cmd.AddValue ("x-size", "Number of nodes in a row grid. [3]", m_xSize);
  //cmd.AddValue ("y-size", "Number of rows in a grid. [3]", m_ySize);
  cmd.AddValue ("nbNodes", "Number of rows in a Uniform Random Disc. [5]", m_nbNodes);
  cmd.AddValue ("numFlows", "Number of flows. [1]", m_numFlows);
  cmd.AddValue ("seed", "Seed [1]", m_seed);
  //cmd.AddValue ("step",   "Size of edge in our grid, meters. [100 m]", m_step);
  cmd.AddValue ("radius", "Radius Uniform Disk [100]", m_radius);
  /*
   * As soon as starting node means that it sends a beacon,
   * simultaneous start is not good.
   */
  cmd.AddValue ("start",  "Maximum random start delay, seconds. [0.1 s]", m_randomStart);
  cmd.AddValue ("time",  "Simulation time, seconds [100 s]", m_totalTime);
  cmd.AddValue ("packet-interval",  "Interval between packets in UDP ping, seconds [0.001 s]", m_packetInterval);
  cmd.AddValue ("timeStartFlowSources",  "Time to start source flows, seconds [1 s]", m_timeStartFlowSources);
  cmd.AddValue ("packet-size",  "Size of packets in UDP ping", m_packetSize);
  cmd.AddValue ("interfaces", "Number of radio interfaces used by each mesh point. [1]", m_nIfaces);
  cmd.AddValue ("channels",   "Use different frequency channels for different interfaces. [0]", m_chan);
  cmd.AddValue ("pcap",   "Enable PCAP traces on interfaces. [0]", m_pcap);
  cmd.AddValue ("report", "Enable report. [1]", m_report);
  cmd.AddValue ("discovery", "Simulate Neighbor Discovery [0]", m_discovery);
  cmd.AddValue ("stack",  "Type of protocol stack. ns3::Dot11sStack by default", m_stack);
  cmd.AddValue ("root", "Mac address of root mesh point in HWMP", m_root);

  cmd.Parse (argc, argv);
  //NS_LOG_DEBUG ("Grid:" << m_xSize << "*" << m_ySize);
  //NS_LOG_DEBUG ("Simulation time: " << m_totalTime << " s");
}
void
MeshJournal::CreateNodes ()
{
  /*
   * Create stations to form a disc topology
   */
  nodes.Create (m_nbNodes);
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
  // ??????
  if (m_chan)
  {
    mesh.SetSpreadInterfaceChannels (MeshHelper::SPREAD_CHANNELS);
  }
  else
  {
    mesh.SetSpreadInterfaceChannels (MeshHelper::ZERO_CHANNEL);
  }

  
  mesh.SetMacType ("RandomStart", TimeValue (Seconds (m_randomStart)));
  // Set number of interfaces - default is single-interface mesh point
  mesh.SetNumberOfInterfaces (m_nIfaces);
  // Install protocols and return container if MeshPointDevices
  meshDevices = mesh.Install (wifiPhy, nodes);
  // Setup mobility - static grid topology
  
  MobilityHelper mobility;
  SeedManager::SetSeed (m_seed);
  mobility.SetPositionAllocator ("ns3::UniformDiscPositionAllocator",
                                   "rho", DoubleValue (m_radius), //The radius of the disc
                                   "X", DoubleValue (0),          //The x/y coordinate of the center of the disc
                                   "Y", DoubleValue (0));
  mobility.SetMobilityModel ("ns3::ConstantPositionMobilityModel");
  mobility.Install (nodes);
  if (m_pcap)
    wifiPhy.EnablePcapAll (std::string ("mp-"));

  PrintPositionNodes();
}
void
MeshJournal::PrintPositionNodes ()
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
        v_string.push_back("Node is at (" + std::to_string(pos.x) + ", " + std::to_string(pos.y) + ")\n");
    }
}
void
MeshJournal::InstallInternetStack ()
{
  InternetStackHelper internetStack;
  internetStack.Install (nodes);
  Ipv4AddressHelper address;
  address.SetBase ("10.1.1.0", "255.255.255.0");
  interfaces = address.Assign (meshDevices);
}
bool
MeshJournal::ExistSource (int candidateSource,int sizeVector, int vec[])
{
    for(int i=0; i < sizeVector; i++){
        if (candidateSource == vec[i])
            return true;
    }
    return false;
}
void
MeshJournal::InstallApplication ()
{
  int sources[m_numFlows];
  int candidateSource;
  int limit = ((m_nbNodes)-1);

  UdpServerHelper server (9);
  //node 0 is always the server
  ApplicationContainer serverApps = server.Install (nodes.Get (0));
  serverApps.Start (Seconds (0.0));
  serverApps.Stop (Seconds (m_totalTime));

  UdpClientHelper client (interfaces.GetAddress (0), 9);
  client.SetAttribute ("MaxPackets", UintegerValue ((uint32_t)(m_totalTime*(1/m_packetInterval))));
  client.SetAttribute ("Interval", TimeValue (Seconds (m_packetInterval)));
  client.SetAttribute ("PacketSize", UintegerValue (m_packetSize));
  ApplicationContainer clientApps;

  srand(time(NULL));
  for (int index=1; index <= m_numFlows; ++index) {
      candidateSource = 1 + (rand() % (limit));
      while(ExistSource(candidateSource,index,sources)){
          candidateSource = 1 + (rand() % (limit));
      }
      sources[index] = candidateSource;
      clientApps = client.Install (nodes.Get (candidateSource));
      clientApps.Start (Seconds (m_timeStartFlowSources*(0.01*candidateSource)));
  }
  clientApps.Stop (Seconds (Seconds (m_totalTime-1)));
}
int
MeshJournal::Run ()
{

  CreateNodes ();
  InstallInternetStack ();
  if (!m_discovery) {
    InstallApplication ();
  }
    
  int counterNbFlow = 0;

  FlowMonitorHelper flowmon;

  Ptr<FlowMonitor> monitor = flowmon.InstallAll ();

  std::vector< ns3::Ptr<ns3::FlowProbe> > flowProbes = monitor->GetAllProbes ();

    if (m_report)
        Simulator::Schedule (Seconds (m_totalTime), &MeshJournal::Report, this);

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
            std::cout << "  Flow " << i->first << " (" << t.sourceAddress << " -> " << t.destinationAddress << ")\n";
            std::cout << "  DeliveyRate:                 " << (i->second.rxPackets * 100.0)/ (i->second.txPackets)  << " %\n";
            std::cout << "  Throughput:                  " << i->second.rxBytes * 8.0 / 10.0 / 1024 / 1024  << " Mbps\n";
            std::cout << "  TxBytes:                     " << i->second.txBytes << "\n";
            std::cout << "  RxBytes:                     " << i->second.rxBytes << "\n";
            std::cout << "  TxPackets:                   " << i->second.txPackets << "\n";
            std::cout << "  RxPackets:                   " << i->second.rxPackets << "\n";
            std::cout << "  LostPackets:	               " << (i->second.lostPackets) << "\n";
            std::cout << "  DelaySum:                    " << i->second.delaySum.GetSeconds()<< " s\n";
            std::cout << "  DelayMean:                   " << (i->second.delaySum.GetSeconds()) / (i->second.rxPackets) << " s\n";
            std::cout << "  JitterSum:                   " << i->second.jitterSum.GetSeconds()<< " s\n";
            std::cout << "  JitterMean:                  " << (i->second.jitterSum.GetSeconds()) / (i->second.rxPackets -1)<< " s\n";
            std::cout << "  TimeFirstTxPacket:           " << i->second.timeFirstTxPacket.GetSeconds() << " s\n";
            std::cout << "  TimeLastTxPacket:            " << i->second.timeLastTxPacket.GetSeconds() << " s\n";
            std::cout << "  TimeFirstRxPacket:           " << i->second.timeFirstRxPacket.GetSeconds() << " s\n";
            std::cout << "  TimeLastRxPacket:            " << i->second.timeLastRxPacket.GetSeconds() << " s\n";
            std::cout << "  MeanTransmittedPacketSize:   " << (i->second.txBytes) / (i->second.txPackets) << " byte\n";
            std::cout << "  MeanTransmittedBitrate:      " << ((i->second.txBytes) * 8.0) / ((i->second.timeLastTxPacket.GetSeconds())-(i->second.timeFirstTxPacket.GetSeconds())) << " bit/s\n";
            std::cout << "  MeanHopCount:                " << (i->second.timesForwarded) / (i->second.rxPackets) + 1 << "\n";
            std::cout << "  PacketLossRatio:             " << (i->second.lostPackets) / ((i->second.rxPackets)+(i->second.lostPackets)) << "\n";
            std::cout << "  MeanReceivedPacketSize:      " << (i->second.rxBytes) / (i->second.rxPackets) << " byte\n";
            std::cout << "  MeanReceivedBitrate:         " << ((i->second.rxBytes)* 8.0) / ((i->second.timeLastRxPacket.GetSeconds())-(i->second.timeFirstRxPacket.GetSeconds())) << " bit/s \n";

           counterNbFlow++;
        }
    }

  NS_LOG_DEBUG ("\nNumber of started flows = "<< counterNbFlow);
  Simulator::Destroy ();
  WriteToBeUsedScriptTopology();
  return 0;
}
void
MeshJournal::Report ()
{
  unsigned n (0);
  for (NetDeviceContainer::Iterator i = meshDevices.Begin (); i != meshDevices.End (); ++i, ++n)
    {
      std::ostringstream os;
      os << "mesh-report-" << n << ".xml";
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
MeshJournal::WriteToBeUsedScriptTopology()
{
    std::string filename = "logMeshSimulationDiscovery.txt";
    //open a file to perform write operation using file object
    std::fstream log_mesh(filename, std::ios::out);  

    std::cerr << "Writing mesh simulate diagnostics to " << filename << std::endl;
    
    if (log_mesh.is_open())
    {
      std::for_each(v_string.begin(), v_string.end(), [&log_mesh](std::string s)
      {
        log_mesh << s;
      });
      std::cerr << filename << " was writted with successfully!" << std::endl;
    }
    log_mesh.close();
}
int
main (int argc, char *argv[])
{
  MeshJournal t;
  t.Configure (argc, argv);
  return t.Run ();
}
