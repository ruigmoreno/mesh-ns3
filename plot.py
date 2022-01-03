import os
import numpy as np
import matplotlib.pyplot as plt

# os.chdir(./scriptsResults/nb_flows/plot) 
# interface = 80211a
# for nb_flows in [1, 10, 30, 50]
# for packetInterval in [1, 0.1, 0.01]

plt.axis([0, 85, 0, 16])    # Throughput
#plt.axis([0, 85, 0, 100])  # DeliveryRate
#plt.axis([0, 85, 0, 1])    # DelayMean
#plt.axis([0, 85, 0, 0.25]) # JitterMean
y = np.loadtxt('./scriptsResults/nb_flows/plot/packetInterval-1-80211a/AggregateThroughput-packetSize-16', usecols=1)
x = np.loadtxt('./scriptsResults/nb_flows/plot/packetInterval-1-80211a/AggregateThroughput-packetSize-16', usecols=0)
error = np.loadtxt('./scriptsResults/nb_flows/plot/packetInterval-1-80211a/AggregateThroughput-packetSize-16', usecols=2)
plt.errorbar(x, y, yerr=error, fmt='ro', capsize=6)


y = np.loadtxt('./scriptsResults/nb_flows/plot/packetInterval-1-80211a/AggregateThroughput-packetSize-32', usecols=1)
x = np.loadtxt('./scriptsResults/nb_flows/plot/packetInterval-1-80211a/AggregateThroughput-packetSize-32', usecols=0)
error = np.loadtxt('./scriptsResults/nb_flows/plot/packetInterval-1-80211a/AggregateThroughput-packetSize-32', usecols=2)
plt.errorbar(x, y, yerr=error, fmt='bx', capsize=6)

plt.savefig('temp2.png')