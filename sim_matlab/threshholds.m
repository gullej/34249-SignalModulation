close all; clc; clearvars;
% Qa.b

% PS taps Q1.9
% multiplied by
% values Q4.0
% gives
% Q(1+4).(9+0)
% = Q5.9

% MF taps Q1.12
% multiplied by
% values Q6.9
% gives
% Q(6+1).(12+9)
% = Q7.21

L = 28;
a = 7; 
b = 21;

alpha = 11.0646; % from other scripts
m = 8;
thresh = 2/m;

thresh_pos = bin(fi(thresh,1,L,b));
thresh_neg = bin(fi(-thresh,1,L,b));

delta = 1e-03;
delta_pos = bin(fi(delta,1,L,b));
delta_neg = bin(fi(-delta,1,L,b));

