import os
import numpy as np
import matplotlib.pyplot as plt

os.chdir('./scriptResults-all-0001/plot')
cwd = os.getcwd()
phy = '80211a'
nb_nodes='81'
packetInterval = '0.001'
# listParameter=['AggregateThroughput', 'DeliveryRate', 'DelayMean', 'JitterMean']
listParameter=['AggregateThroughput', 'DeliveryRate', 'DelayMean']
listPacketSize=['32', '256', '1024']
# listPacketSize=['32', '1024']
listFlows=['1', '10', '30', '50', '70']
# listFlows=['10']
listModes=['R','RP']
markerStyle=''

for parameter in listParameter:
    if (parameter == 'AggregateThroughput'):
        plt.axis([0, 71, 0, 8])
        # plt.ylabel('Aggregate Throughput (Mbit/s)')
        plt.ylabel('Somatório Throughput (Mbit/s)')
    elif (parameter == 'DeliveryRate'):
        plt.axis([0, 71, 0, 100])
        # plt.ylabel('Delivery Rate (%)')
        plt.ylabel('Taxa de Entrega (%)')
    elif (parameter == 'DelayMean'):
        plt.axis([0, 71, 0, 1])
        # plt.ylabel('Delay Mean (s)')
        plt.ylabel('Média de Atraso (s)')
    elif (parameter == 'JitterMean'):
        plt.axis([0, 71, 0, 0.25])
        # plt.ylabel('Jitter Mean (s)')
        plt.ylabel('Média Jitter (s)')

    for mode in listModes:
        if mode == 'R':
            color = 'orange'
        elif mode == 'RR':
            color = 'blue'
        elif mode == 'RP':
            color = 'green'
        for packetSize in listPacketSize:
            x = np.array([])
            y = np.array([])
            error = np.array([])
            for nb_flows in listFlows:
                load_y = np.loadtxt('./'+mode+'/nb_nodes-'+nb_nodes+'-packetInterval-'+packetInterval+'-'+phy+'-'+nb_flows+'-flows/'+parameter+'-packetSize-'+packetSize, usecols=1)
                y = np.append(y, load_y)

                load_x = np.loadtxt('./'+mode+'/nb_nodes-'+nb_nodes+'-packetInterval-'+packetInterval+'-'+phy+'-'+nb_flows+'-flows/'+parameter+'-packetSize-'+packetSize, usecols=0)
                x = np.append(x, load_x)

                load_error=np.loadtxt('./'+mode+'/nb_nodes-'+nb_nodes+'-packetInterval-'+packetInterval+'-'+phy+'-'+nb_flows+'-flows/'+parameter+'-packetSize-'+packetSize, usecols=2)
                error = np.append(error, load_error)
            if packetSize == '32':
                markerStyle='>'
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
            # plt.xlabel('flows number')
            plt.xlabel('Número de fluxos')
            plt.errorbar(x, y, yerr=error, marker=markerStyle, color=color, label=mode+' '+packetSize+' bytes', capsize=6)
            # plt.errorbar(x, y, marker=markerStyle, color=color, label=legend+' '+packetSize+' bytes', capsize=6)
            plt.legend(bbox_to_anchor=(0.2, -.3, .6, .102), loc='lower left', ncol=2, mode="expand", borderaxespad=0)
            plt.grid(True)

    plt.savefig('./plot-'+parameter+'-packetInterval-'+packetInterval+'-Comparative-PT.pdf', bbox_inches="tight")
    plt.clf() # clear the entire current figure with all its axes

