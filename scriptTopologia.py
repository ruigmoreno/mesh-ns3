#!/usr/bin/env python
#-*- coding:utf-8 -*-
import os, cairo, lxml, lxml.etree
from math import pi

ARQ = 'logMeshSimulationDiscovery.txt'
XML_DIR = './'
IMG_W, IMG_H = 700, 700

class Node:
    def __init__(self, id, x, y):
        self.id = id
        self.x, self.y = x, y
        self.vizinhos = []
        self.addr = ''

def findNodeByAddr(addr, nodes):
    for nd in nodes:
        if nd.addr == addr:
            return nd.id
    return -1

def main():
    f = open(ARQ)
    lines = f.read().split('\n')
    f.close()
    
    nodes = []    
    min_x, max_x, min_y, max_y = 10000.0, -10000.0, 10000.0, -10000.0
    for s in lines:
        s = s.strip()
        if len(s) == 0: continue
        if 'Node is at' in s:
            termos = s[ s.find('(')+1 : -1 ].split(',')
            x, y = float( termos[0].strip() ), float( termos[1].strip() )
            min_x, max_x = min(x, min_x), max(x, max_x)
            min_y, max_y = min(y, min_y), max(y, max_y)
            nodes.append( Node( len(nodes), x,y) )    
    
    min_vz, max_vz = 1000, -1000
    arqs = os.listdir(XML_DIR)

    for arq in arqs:
        arq = os.path.join( XML_DIR, arq )
        if (os.path.splitext(arq)[1] != '.xml' or os.path.split(arq)[1] == 'results.xml'): continue

        node_i = int( os.path.splitext(arq)[0].split('-')[-1] )
        s = open(arq).read()
        t = lxml.etree.fromstring( s )
        
        nd = nodes[node_i]
        nd.addr = str( t.xpath( u"//MeshPointDevice/@address" )[0] )
        for tk in t.xpath( u"//MeshPointDevice/PeerManagementProtocol/PeerLink/@peerInterfaceAddress" ):
            nd.vizinhos.append( str(tk) )
        
        min_vz, max_vz = min( min_vz, len(nd.vizinhos) ), max( max_vz, len(nd.vizinhos) )

    min_vz, max_vz = float(min_vz), float(max_vz)        
    
    for nd in nodes:
        nd.nz = float( (len(nd.vizinhos) - min_vz) ) / (max_vz - min_vz)

    surf = cairo.SVGSurface( "graph.svg", IMG_W, IMG_H )
    cr = cairo.Context( surf )
    ## Set background color
    cr.set_source_rgb(1,1,1)
    cr.paint()
    cr.select_font_face( "Arial" )
    cr.set_font_size( 15 )

    for nd in nodes:
        print ("Node %d: addr = %s, x = %f, y = %f, vzs = %d [%f]" % \
            (nd.id, nd.addr, nd.x, nd.y, len(nd.vizinhos), nd.nz ))
        for vz in nd.vizinhos:
            vz_i = findNodeByAddr( vz, nodes )
            print ("  - %s (node %d)" % (vz, vz_i))
        
        fx = (nd.x - min_x) / (max_x - min_x)
        fy = (nd.y - min_y) / (max_y - min_y)
        nd.px = fx * IMG_W 
        nd.py = fy * IMG_H

    for nd in nodes:
        if len(nd.vizinhos) == 0: cr.set_source_rgb( 0,1,0 )
        else: cr.set_source_rgb( 1,0,0 )

        nds = nd.nz*90
        grad = cairo.RadialGradient( nd.px,nd.py,2, nd.px,nd.py, 10+nds )
        grad.add_color_stop_rgba( 0.0,  1,0,0,1 )
        grad.add_color_stop_rgba( 1.0,  1,1,0,0 )
        cr.set_source( grad )
        cr.new_path()
        cr.arc( nd.px, nd.py, 100,  0, 2*pi )
        cr.close_path()        
        cr.fill()            
        cr.new_path()
        cr.arc( nd.px, nd.py, 8,  0, 2*pi )
        cr.close_path()        
        cr.fill()
                
        for vz in nd.vizinhos:
            vz_nd = nodes[ findNodeByAddr(vz, nodes) ]
            cr.set_source_rgb( 0,0,1 )
            cr.move_to( nd.px, nd.py ) 
            cr.line_to( vz_nd.px, vz_nd.py )            
            cr.stroke()

    for nd in nodes:
        cr.set_source_rgb( 0.5,0,0 )
        cr.move_to( nd.px+10, nd.py )
        cr.show_text( '%d' % nd.id )

    surf.show_page()
    surf.finish()
    print ("OK! Figure was generated.")
                
main()
