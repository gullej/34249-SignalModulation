close all; clc; clearvars;
% pbrs

n = 127*8;

sr = [1 1 1 1 1 1 1];
bit_seq = zeros(1, n);

for i = 1:n
    sr = [xor(sr(6), sr(7)) sr(1) sr(2) sr(3) sr(4) sr(5) sr(6)];
    bit_seq(i) = sr(7);
end

%%
T = 1;
m = 8;
[pulse,E,mF] = cos_pulse(T,m,4,0.2);
cut = (size(pulse,2)-1)/2;

v = pam_gray(bit_seq, n, 4);
N = n/log2(4);
v = reshape([v; zeros(m - 1, N)], 1, N * m);
v = conv(v, pulse);
v = v(cut+1:end-cut);

hold on
plot(v(1:1016))
plot(v(1017:2032))
plot(v(2033:3048))
plot(v(3049:4064))
legend('first', 'second', 'third', 'fourth')

% first and last periods will be altered slightly by the convolution adding
% and going to zeros, but the second and third period should be identical:
period = 127 * 8; % we add 7 zeros after each symbol so the period is biggers
sum(v(period+1:period*2) ~= v(period*2+1:period*3))



