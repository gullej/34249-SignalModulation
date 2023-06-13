close all; clc; clearvars;
rng(42)

m = 8;
taps = cos_pulse(1,m,4,0.2);

A = 14;
L = 2 + 1; % (dependant on constellation size)

alpha  = sum(abs(taps));     % formula
lambda = ceil(log2(alpha)); % formula

taps_norm   = taps / alpha;
alpha_norm  = sum(abs(taps_norm));
lambda_norm = ceil(log2(alpha_norm)); % formula

b_norm = min(floor(log2(2^(A-1)-1/max(abs(taps_norm)))), A - L - lambda_norm);

taps_norm_fi     = double(fi(taps_norm,1,A-L-1,b_norm-1));
cut = (size(taps_norm_fi, 2) -1)/2;

N = 50;

signal = randsample([-3 -1 1 3], N, true);
% upsample
v = reshape([signal; zeros(m - 1, N)], 1, N * m);
% pulse shaping
vv = conv(v, taps_norm_fi);
% fixed point
%vv = vv(cut+1:end-cut);
vvv = fi(vv, 1, A, b_norm-1);
% binary
vvvv = bin(vvv')  - '0';


%r = double(conv(vvv, taps_norm_fi));
%rr = r(cut+1:end-cut);
%rrr = rr(1:m:end)/m;
%ans = round(rrr*alpha*alpha);

args = dec2bin(signal, 8) - '0';
args = args(:,end-2:end);

fileID = fopen('in.txt','w');
fprintf(fileID,'%d%d%d000000000000000000000\n',args');

fclose(fileID);

fileID = fopen('out.txt', 'w');
fprintf(fileID,'%d%d%d%d%d%d%d%d%d%d%d%d%d%d\n',vvvv');

fclose(fileID);

