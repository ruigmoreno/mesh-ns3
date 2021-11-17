#!/usr/bin/python
__author__ = "Rui G. F. Moreno, Carina Teixeira de Oliveira"
__license__ = "GPL"
__version__ = "1.1"
__maintainer__ = "Rui Moreno"
__status__ = "In Progress"

from glob import glob
import networkx as nx
from networkx.drawing.nx_pydot import write_dot
from lxml import etree
from sys import exit
from time import time
import os

reports = glob('mesh-report-*.xml')
ids = dict()

for report in reports:
    aux = open(report).read()
    meshPointDevice = etree.XML(aux)
    curr_address = meshPointDevice.get('address')
    curr_id = filter(str.isdigit, curr_address)
    ids[curr_address] = curr_id

G = nx.Graph()
for report in reports:
    aux = open(report).read()
    meshPointDevice = etree.XML(aux)
    currAddress = meshPointDevice.get('address')
    currId = ids[currAddress]
    G.add_node(currId)

    peerManagementProtocol = meshPointDevice.find('PeerManagementProtocol')
    links = peerManagementProtocol.findall('PeerLink')
    for link in links:
        peerAddress = link.get('peerMeshPointAddress')
        peerId = ids[peerAddress]
        G.add_edge(currId, peerId)
#print('current working directory - %s' % os.getcwd())
print ('Media num conexoes:', float(len(G.edges()))/float(len(G.nodes())))
write_dot(G, 'checked_%d.dot' % int(time()))
if not nx.is_connected(G):
    raise Exception("[check.py] invalid topology!")
