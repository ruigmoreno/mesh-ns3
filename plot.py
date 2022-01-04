import os
import numpy as np
import matplotlib.pyplot as plt
from glob import glob

# os.chdir(./scriptResults/plot) 
# phy = 80211a
# packetInterval = 0.1
listParameter=['AggregateThroughput', 'DeliveryRate', 'DelayMean', 'JitterMean']
for parameter in listParameter:
    if (parameter == 'AggregateThroughput'):
        plt.axis([0, 85, 0, 16])
    elif (parameter == 'DeliveryRate'):
        plt.axis([0, 85, 0, 100])
    elif (parameter == 'DelayMean'):
        plt.axis([0, 85, 0, 1])
    elif (parameter == 'JitterMean'):
        plt.axis([0, 85, 0, 0.25])

    for nb_flows in [1, 10, 30, 50]:
        for packetSize in [32, 256, 1024]:
            y=np.loadtxt('./packetInterval-'+packetInterval+'-'+phy+'-'+nb_flows+'-flows/'+parameter+'-packetSize-'+packetSize, usecols=1)
            x=np.loadtxt('./packetInterval-'+packetInterval+'-'+phy+'-'+nb_flows+'-flows/'+parameter+'-packetSize-'+packetSize, usecols=0)
            error=np.loadtxt('./packetInterval-'+packetInterval+'-'+phy+'-'+nb_flows+'-flows/'+parameter+'-packetSize-'+packetSize, usecols=2)
            plt.errorbar(x,y,yerr=error,fmt='ro', capsize=6)


plt.axis([0, 85, 0, 16])    # Throughput
#plt.axis([0, 85, 0, 100])  # DeliveryRate
#plt.axis([0, 85, 0, 1])    # DelayMean
#plt.axis([0, 85, 0, 0.25]) # JitterMean
y = np.loadtxt('./scriptResults/plot/packetInterval-1-80211a-1-flows/AggregateThroughput-packetSize-16', usecols=1)
x = np.loadtxt('./scriptResults/plot/packetInterval-1-80211a-1-flows/AggregateThroughput-packetSize-16', usecols=0)
error = np.loadtxt('./scriptResults/plot/packetInterval-1-80211a-1-flows/AggregateThroughput-packetSize-16', usecols=2)
plt.errorbar(x, y, yerr=error, fmt='ro', capsize=6)


y = np.loadtxt('./scriptResults/plot/packetInterval-1-80211a-1-flows/AggregateThroughput-packetSize-32', usecols=1)
x = np.loadtxt('./scriptResults/plot/packetInterval-1-80211a-1-flows/AggregateThroughput-packetSize-32', usecols=0)
error = np.loadtxt('./scriptResults/plot/packetInterval-1-80211a-1-flows/AggregateThroughput-packetSize-32', usecols=2)
plt.errorbar(x, y, yerr=error, fmt='bx', capsize=6)

plt.savefig('temp2.png')