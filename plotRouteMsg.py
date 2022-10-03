import os
import numpy as np
import matplotlib.pyplot as plt

os.chdir('./scriptResults-all-001/')
cwd = os.getcwd()
phy = '80211a'
nb_nodes='81' # 81
packetInterval = '0.01'
parameter='droppedTtl' # DelayMean, DeliveryRate, Preq, Prep, Perr, txPreq, txPrep, txPerr, droppedTtl
listModes=['R','RP']
listPacketSize=['32','256','1024']
listFlows= ['1','10'] # ['1','10','30','50','70']
# title = 'Modes with packet interval of '+packetInterval+' s'
title = 'Modos com intervalo de pacote de '+packetInterval+' s'
# for parameter in listParameter:

plt.axis([0, 71, 0, 5])
# plt.ylabel('Average Number of '+parameter+' Messages per Node')
plt.ylabel('Média do Número de Mensagens '+parameter+' por nó')

for mode in listModes:
    if mode == 'R':
        color='black'
    elif mode == 'RR':
        color='blue'
    elif mode == 'RP':
        color='red'
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
            markerStyle='.'
        elif packetSize == '256':
            markerStyle='s'
        elif packetSize == '1024':
            markerStyle='x'
        # plt.xlabel('flows number')
        plt.xlabel('Número de fluxos')
        plt.errorbar(x, y, yerr=error, marker=markerStyle, color=color, label=mode+' '+packetSize+' bytes', capsize=6)
        plt.legend(bbox_to_anchor=(0.2, -.3, .6, .102), loc='lower left', ncol=2, mode="expand", borderaxespad=0)
        plt.grid(True)
plt.suptitle(title, y=0.925)
# plt.savefig('./plot-'+parameter+'-route-msgs-per-node.pdf', bbox_inches="tight")
plt.savefig('./plot-'+parameter+'-route-msgs-per-node-PT.pdf', bbox_inches="tight")
plt.clf() # clear the entire current figure with all its axes

