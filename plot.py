import os
import numpy as np
import matplotlib.pyplot as plt


os.chdir('./scriptResults/plot')
phy = '80211a'
packetInterval = '0.1'
listParameter=['AggregateThroughput', 'DeliveryRate', 'DelayMean', 'JitterMean']

for parameter in listParameter:
    if (parameter == 'AggregateThroughput'):
        plt.axis([0, 51, 0, 16])
    elif (parameter == 'DeliveryRate'):
        plt.axis([0, 51, 0, 100])
    elif (parameter == 'DelayMean'):
        plt.axis([0, 51, 0, 1])
    elif (parameter == 'JitterMean'):
        plt.axis([0, 51, 0, 0.25])
    for packetSize in ['32', '256', '1024']:
        x = np.array([])
        y = np.array([])
        error = np.array([])        
        for nb_flows in ['1', '10', '30', '50']:
            load_y = np.loadtxt('./packetInterval-'+packetInterval+'-'+phy+'-'+nb_flows+'-flows/'+parameter+'-packetSize-'+packetSize, usecols=1)
            y = np.append(y, load_y)

            load_x = np.loadtxt('./packetInterval-'+packetInterval+'-'+phy+'-'+nb_flows+'-flows/'+parameter+'-packetSize-'+packetSize, usecols=0)
            x = np.append(x, load_x)

            load_error=np.loadtxt('./packetInterval-'+packetInterval+'-'+phy+'-'+nb_flows+'-flows/'+parameter+'-packetSize-'+packetSize, usecols=2)
            error = np.append(error, load_error)

        plt.xlabel('number of flows')
        plt.ylabel(parameter)
        plt.errorbar(x, y, yerr=error, label=packetSize, capsize=6)
        plt.legend()

    plt.savefig('plot-'+parameter+'-packetInterval-'+packetInterval+'.png')
    plt.clf() # clear the entire current figure with all its axes

