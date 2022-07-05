import os
import numpy as np
import matplotlib.pyplot as plt

os.chdir('./scriptResults-all-001/plot')
cwd = os.getcwd()
phy = '80211a'
packetInterval = '0.01'
listParameter=['AggregateThroughput', 'DeliveryRate', 'DelayMean', 'JitterMean']
listPacketSize=['32', '256', '1024']
listFlows=['1', '10', '30', '50', '70']
markerStyle=''

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

    for i in range(3):
        if i == 0:
            legend = 'R'
            color = 'blue'
            os.chdir(cwd+'/reactiveWithoutRoot')
        elif i == 1:
            legend = 'RR'
            color = 'orange'
            os.chdir(cwd+'/reactiveWithRoot')
        elif i == 2:
            legend = 'RP'
            color = 'green'
            os.chdir(cwd+'/reactiveProactive')
        for packetSize in listPacketSize:
            x = np.array([])
            y = np.array([])
            error = np.array([])
            for nb_flows in listFlows:
                load_y = np.loadtxt('./packetInterval-'+packetInterval+'-'+phy+'-'+nb_flows+'-flows/'+parameter+'-packetSize-'+packetSize, usecols=1)
                y = np.append(y, load_y)

                load_x = np.loadtxt('./packetInterval-'+packetInterval+'-'+phy+'-'+nb_flows+'-flows/'+parameter+'-packetSize-'+packetSize, usecols=0)
                x = np.append(x, load_x)

                load_error=np.loadtxt('./packetInterval-'+packetInterval+'-'+phy+'-'+nb_flows+'-flows/'+parameter+'-packetSize-'+packetSize, usecols=2)
                error = np.append(error, load_error)
            if packetSize == '32':
                markerStyle='<'
                # if i == 0:
                #     markerStyle='<'
                # elif i == 1:
                #     markerStyle='>'
                # elif i == 2:
                #     markerStyle='^'
            elif packetSize == '256':
                markerStyle='*'
            elif packetSize == '1024':
                markerStyle='d'                
            plt.xlabel('flows number')
            plt.errorbar(x, y, yerr=error, marker=markerStyle, color=color, label=legend+' '+packetSize+' bytes', capsize=6)
            # plt.errorbar(x, y, marker=markerStyle, color=color, label=legend+' '+packetSize+' bytes', capsize=6)
            plt.legend(bbox_to_anchor=(0., -.31, 1., .102), loc='lower left', ncol=3, mode="expand", borderaxespad=0)
            plt.grid(True)

    plt.savefig('../plot-'+parameter+'-packetInterval-'+packetInterval+'-Comparative.pdf', bbox_inches="tight")
    plt.clf() # clear the entire current figure with all its axes

