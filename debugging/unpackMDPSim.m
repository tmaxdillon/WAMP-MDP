%UNPACKMDPSIM unpacks simulation structure into substructures for debugging
clear all, close all, clc
%% set structure name

simStruct = sim_n20F1970mu01000pb;


%% unpack structures

amp = simStruct.amp;
mdp = simStruct.mdp;
output = simStruct.output;
sim = simStruct.sim;
wec = simStruct.wec;
FM = simStruct.FM;
clear simStruct