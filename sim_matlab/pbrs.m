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

A = 14;
L = 2 + 1; % (dependant on constellation size)

alpha  = sum(abs(pulse));     % formula
lambda = ceil(log2(alpha)); % formula

taps_norm   = pulse / alpha;
alpha_norm  = sum(abs(taps_norm));
lambda_norm = ceil(log2(alpha_norm)); % formula

b_norm = min(floor(log2(2^(A-1)-1/max(abs(taps_norm)))), A - L - lambda_norm);

taps_norm_fi     = double(fi(taps_norm,1,A-L-1,b_norm-1));

v = pam_gray(bit_seq, n, 4);
N = n/log2(4);
v = reshape([v; zeros(m - 1, N)], 1, N * m);
v = conv(v, taps_norm_fi);
v = v(cut+1:end-cut);

% first and last periods will be altered slightly by the convolution adding
% and going to zeros, but the second and third period should be identical:
period = 127 * 8; % we add 7 zeros after each symbol so the period is biggers
sum(v(period+1:period*2) ~= v(period*2+1:period*3))

h = figure;

plot(v(1:2*period))
grid on
xlim([1 2*period])
pbaspect([5 1 1])

legend('PAM4', 'Location','southeast')
ylabel('Amplitude')
xlabel('Sample Number','FontSize',11,'FontWeight','bold')
title('Filtered Signal','FontSize',14,'FontWeight','bold')

set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,'../Docs/PulseShaperPBRSTest_1_target','-dpdf','-r0')