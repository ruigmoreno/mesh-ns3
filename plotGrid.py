import os
import numpy as np
import matplotlib.pyplot as plt


os.chdir('./scriptGridResults/plot')
# phy = '80211a'
packetInterval = '0.01'
packetSize = '1024'
listParameter=['AggregateThroughput', 'DeliveryRate', 'DelayMean', 'JitterMean']

for parameter in listParameter:
    if (parameter == 'AggregateThroughput'):
        plt.axis([70, 121, 0, 2])
        plt.ylabel('Aggregate Throughput (Mbit/s)')
    elif (parameter == 'DeliveryRate'):
        plt.axis([70, 121, 0, 101])
        plt.ylabel('Delivery Rate (%)')
    elif (parameter == 'DelayMean'):
        plt.axis([70, 121, 0, 0.5])
        plt.ylabel('Delay Mean (s)')
    elif (parameter == 'JitterMean'):
        plt.axis([70, 121, 0, 0.5])
        plt.ylabel('Jitter Mean (s)')
    for phy in ['80211a', '80211b', '80211g']:
        x = np.array([])
        y = np.array([])
        error = np.array([])        
        for step in ['70', '80', '90', '100', '110', '120']:
            load_y = np.loadtxt('./packetInterval-'+packetInterval+'-'+phy+'-'+'step-'+step+'/'+parameter+'-packetSize-'+packetSize, usecols=1)
            y = np.append(y, load_y)

            load_x = np.loadtxt('./packetInterval-'+packetInterval+'-'+phy+'-'+'step-'+step+'/'+parameter+'-packetSize-'+packetSize, usecols=0)
            x = np.append(x, load_x)

            # load_error=np.loadtxt('./packetInterval-'+packetInterval+'-'+phy+'-'+'step-'+step+'/'+parameter+'-packetSize-'+packetSize, usecols=2)
            # error = np.append(error, load_error)

        plt.xlabel('step')
        plt.plot(x , y , label=phy )
        # plt.errorbar(x, y, yerr=error, label=packetSize+' bytes', capsize=6)
        plt.legend()
        plt.grid(True)

    plt.savefig('plot-'+parameter+'-packetInterval-'+packetInterval+'.jpg')
    plt.clf() # clear the entire current figure with all its axes

