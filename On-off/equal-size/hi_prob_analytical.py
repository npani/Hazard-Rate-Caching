#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Apr 12 22:09:44 2021

@author: nitish
"""

import numpy as np
from scipy.io import loadmat
from scipy.special import comb

cache_size_arr  = np.arange(10,110,10)
#cache_size_arr  = np.arange(1,11,1)
#cache_size_arr  = np.arange(500,1050,50)
hit_probs_analytical = np.zeros(len(cache_size_arr))
hit_probs_analytical_pn = np.zeros(len(cache_size_arr))
hit_probs_analytical_pn_new = np.zeros(len(cache_size_arr))


no_of_contents = 1000

Ton = 7
Toff = 63
mu01 = 1/Toff
mu10 = 1/Ton
pi0 = (mu10/(mu10+mu01))
pi1 = 1-pi0
rho = pi1


x = loadmat('on_off_trace_N1000_new.mat')
lambdas = np.squeeze(np.array(x['p']))
t_max = 5027.015
no_of_arrivals = 705107
t_avg = t_max/no_of_arrivals

#print(lambdas)


#hit_probs_sim = np.array([0.3145,0.4427,0.5417,0.6270,0.7025,0.7712,0.8334,0.8915,0.9437,0.9811])

#print(pi0)

for i in range(len(cache_size_arr)):
    cs = cache_size_arr[i]
    p = np.zeros((cs+1, no_of_contents+1))
    r = np.zeros((cs+1, no_of_contents+1))  
    
    p[0][0] = 1
    
#    for l in range(1,no_of_contents+1):   
#        p[0][l] = p[0][l-1]*pi0
#    
#    for k in range(1,cs+1):   
#        p[k][k] = p[k-1][k-1]*pi1    
#        r[k][k] = r[k-1][k-1] + lambdas[k-1]
#    
#    for k in range(1,cs):
#        for l in range(k+1,no_of_contents+1):
#            p[k][l] = (p[k-1][l-1]*pi1) + (p[k][l-1]*pi0)
#            r[k][l] = ((p[k-1][l-1]*pi1*(r[k-1][l-1]+lambdas[l-1])) + (p[k][l-1]*pi0*r[k][l-1]))/p[k][l]
#    
#    for l in range(cs+1,no_of_contents+1):    
#        p[cs][l] = (p[cs-1][l-1]*pi1)+ p[cs][l-1]
#        r[cs][l] = ((p[cs-1][l-1]*pi1*(r[cs-1][l-1]+lambdas[l-1]))+ (p[cs][l-1]*r[cs][l-1]))/p[cs][l]    
     
#    hit_probs_analytical[i] = np.sum(np.array(p[:,-1]*r[:,-1]))/(np.sum(lambdas)*pi1)
#    hit_probs_analytical[i] = np.sum(np.array(p[:,-1]*r[:,-1]))
    sum_i = 0.0
    for k in range(1,no_of_contents):
        if (k <= cs):
            h_k = 1
        else:    
            sum_k = 0.0
            for k2 in range(cs):
                sum_k = sum_k+ (((rho/(1-rho))**k2)*comb(k-1,k2))
            
            h_k =   ((1-rho)**(k-1))*sum_k
        sum_i = sum_i + (h_k*lambdas[k-1]*pi1)
    
    hit_probs_analytical_pn[i] = sum_i/(np.sum(lambdas)*pi1)
#    hit_probs_analytical_pn_new[i] = sum_i
    
#    for k in range(1,no_of_contents):
#        if (k <= cs):
#            h_k = 1
#        else:    
#            sum_k = 0.0
#            for k2 in range(cs):
#                sum_k = sum_k+ (((rho/(1-rho))**k2)*comb(k-1,k2))
#            
#            h_k =   ((1-rho)**(k-1))*sum_k
#        sum_i = sum_i + (h_k*lambdas[k-1]*pi1)
#    
#    hit_probs_analytical_pn[i] = sum_i/(np.sum(lambdas)*pi1)
    

print('n = '+str(no_of_contents))
print('Cache Sizes')
print(cache_size_arr)
print('Analytic Hit Probs-ToMPECS')
print(hit_probs_analytical) 
print('Analytic Hit Probs-Philippe')
print(hit_probs_analytical_pn) 
#print('Analytic Hit Probs-Philippe-new')
#print(hit_probs_analytical_pn_new) 
#print('Simulation Hit Probs')
#print(hit_probs_sim)