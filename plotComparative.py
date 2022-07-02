import os
import numpy as np
import matplotlib.pyplot as plt

os.chdir('./scriptResults-0.01/plot')
cwd = os.getcwd()
phy = '80211a'
packetInterval = '0.01'
listParameter=['AggregateThroughput', 'DeliveryRate', 'DelayMean', 'JitterMean']

for parameter in listParameter:
    if (parameter == 'AggregateThroughput'):
        plt.axis([0, 71, 0, 16])
        plt.ylabel('Aggregate Throughput (Mbit/s)')
    elif (parameter == 'DeliveryRate'):
        plt.axis([0, 71, 0, 100])
        plt.ylabel('Delivery Rate (%)')
    elif (parameter == 'DelayMean'):
        plt.axis([0, 71, 0, 1])
        plt.ylabel('Delay Mean (s)')
    elif (parameter == 'JitterMean'):
        plt.axis([0, 71, 0, 0.25])
        plt.ylabel('Jitter Mean (s)')

    for i in range(2):
        if i == 0:
            legend = 'HWMP-R'
            os.chdir(cwd+'/noRoot')
        elif i == 1:
            legend = 'HWMP-RR'
            os.chdir(cwd+'/rootReactive')
        for packetSize in ['32', '256', '1024']:
            x = np.array([])
            y = np.array([])
            error = np.array([])
            for nb_flows in ['1', '10', '30', '50', '70']:
                load_y = np.loadtxt('./packetInterval-'+packetInterval+'-'+phy+'-'+nb_flows+'-flows/'+parameter+'-packetSize-'+packetSize, usecols=1)
                y = np.append(y, load_y)

                load_x = np.loadtxt('./packetInterval-'+packetInterval+'-'+phy+'-'+nb_flows+'-flows/'+parameter+'-packetSize-'+packetSize, usecols=0)
                x = np.append(x, load_x)

                load_error=np.loadtxt('./packetInterval-'+packetInterval+'-'+phy+'-'+nb_flows+'-flows/'+parameter+'-packetSize-'+packetSize, usecols=2)
                error = np.append(error, load_error)

            plt.xlabel('flows number')
            plt.errorbar(x, y, yerr=error, label=legend+' '+packetSize+' bytes', capsize=6)
            plt.legend()
            plt.grid(True)

    plt.savefig('../plot-'+parameter+'-packetInterval-'+packetInterval+'-Comparative.png')
    plt.clf() # clear the entire current figure with all its axes

