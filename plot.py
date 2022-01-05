import os
import numpy as np
import matplotlib.pyplot as plt


os.chdir('./scriptResults/plot')
phy = '80211a'
packetInterval = '1'
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
    for nb_flows in ['1']: #['1', '10', '30', '50']:
        for packetSize in ['16']: #['32', '256', '1024']:
            y=np.loadtxt('./packetInterval-'+packetInterval+'-'+phy+'-'+nb_flows+'-flows/'+parameter+'-packetSize-'+packetSize, usecols=1)
            x=np.loadtxt('./packetInterval-'+packetInterval+'-'+phy+'-'+nb_flows+'-flows/'+parameter+'-packetSize-'+packetSize, usecols=0)
            error=np.loadtxt('./packetInterval-'+packetInterval+'-'+phy+'-'+nb_flows+'-flows/'+parameter+'-packetSize-'+packetSize, usecols=2)
            plt.errorbar(x, y, yerr=error, fmt='o', capsize=6)
    plt.savefig('plot-'+parameter+'-packetInterval-'+packetInterval+'.png')
    plt.clf() # clear the entire current figure with all its axes

