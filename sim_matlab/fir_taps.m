clear variables; close all; clc
%% calculating Qa.b

taps = cos_pulse(1,8,4,0.2);
A = 14;
L = 2; % (dependant on constellation size)

alpha  = sum(abs(taps));     % formula
lambda = ceil(log2(alpha)); % formula

taps_norm   = taps / alpha;
alpha_norm  = sum(abs(taps_norm));
lambda_norm = ceil(log2(alpha_norm)); % formula

b      = min(floor(log2(2^(A-1)-1/max(abs(taps)))), A - L - lambda);
b_norm = min(floor(log2(2^(A-1)-1/max(abs(taps_norm)))), A - L - lambda_norm);
a      = A - b;
a_norm = A - b_norm;

%% converting to Qa.b

taps_fi     = fi(taps,1,A,b)';
taps_fi_bin = bin(taps_fi);

taps_norm_fi     = fi(taps_norm,1,A,b_norm)';
taps_norm_fi_bin = bin(taps_norm_fi);