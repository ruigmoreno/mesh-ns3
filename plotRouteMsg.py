import os
import numpy as np
import matplotlib.pyplot as plt

os.chdir('./scriptResults-all-001/plot')
cwd = os.getcwd()
phy = '80211a'
packetInterval = '0.01'
parameter='Perr'
mode = 'Reactive + Proactive'
listModes=['R','RR','RP']
title = 'Modes with packet interval of '+packetInterval+' s'
# for parameter in listParameter:

plt.axis([0, 71, 0, 50])
plt.ylabel('Average Number of '+parameter+' Messages per Node')

for mode in listModes:
    if mode == 'R':
        color='blue'
    elif mode == 'RR':
        color='orange'
    elif mode == 'RP':
        color='green'
    for packetSize in ['32', '256', '1024']:
        x = np.array([])
        y = np.array([])
        error = np.array([])
        for nb_flows in ['1', '10', '30', '50', '70']:
            load_y = np.loadtxt('./'+mode+'/packetInterval-'+packetInterval+'-'+phy+'-'+nb_flows+'-flows/'+'interfaces-temp-'+parameter+'-packetSize-'+packetSize, usecols=1)
            y = np.append(y, load_y)

            load_x = np.loadtxt('./'+mode+'/packetInterval-'+packetInterval+'-'+phy+'-'+nb_flows+'-flows/'+'interfaces-temp-'+parameter+'-packetSize-'+packetSize, usecols=0)
            x = np.append(x, load_x)

            load_error=np.loadtxt('./'+mode+'/packetInterval-'+packetInterval+'-'+phy+'-'+nb_flows+'-flows/'+'interfaces-temp-'+parameter+'-packetSize-'+packetSize, usecols=2)
            error = np.append(error, load_error)

        plt.xlabel('flows number')
        plt.errorbar(x, y, yerr=error, color=color, label=mode+' '+packetSize+' bytes', capsize=6)
        plt.legend(bbox_to_anchor=(0., -.3, 1., .102), loc='lower left', ncol=3, mode="expand", borderaxespad=0)
        plt.grid(True)
plt.suptitle(title, y=0.925)
plt.savefig('./plot-'+parameter+'-route-msgs-per-node.pdf', bbox_inches="tight")
plt.clf() # clear the entire current figure with all its axes

