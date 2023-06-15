close all; clc; clearvars;
rng(42)

m = 8;
[taps,E,mF] = cos_pulse(1,m,4,0.2);

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
vv = vv(cut+1:end-cut);
vvv = fi(vv, 1, 14, 9);
% binary
vvvv = bin(vvv')  - '0';

%%

% args = dec2bin(signal, 8) - '0';
% args = args(:,end-2:end);
% 
% fileID = fopen('in.txt','w');
% fprintf(fileID,'%d%d%d000000000000000000000\n',args');
% 
% fclose(fileID);
% 
% fileID = fopen('out.txt', 'w');
% fprintf(fileID,'%d%d%d%d%d%d%d%d%d%d%d%d%d%d\n',vvvv');
% 
% fclose(fileID);
% 
% h = figure;
% 
% plot(vvv)
% 
% grid on
% ylim([-.5 0.5])
% xlim([0 432])
% 
% legend('PAM4', 'Location','southwest')
% ylabel('Amplitude')
% xlabel('Sample Number','FontSize',11,'FontWeight','bold')
% title('Filtered Signal','FontSize',14,'FontWeight','bold')
% 
% set(h,'Units','Inches');
% pos = get(h,'Position');
% set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% print(h,'../Docs/PulseShaperDirectedTest_1_target','-dpdf','-r0')

%%

r = double(conv(vvv, double(fi(mF,1,13,12))));
rr = r(cut+1:end-cut);
rrr = rr(1:m:end);
fsig = round(rrr/m*alpha);
fsig ~= signal

%%

sample = repmat([1 0 0 0 0 0 0 0 ], 1, size(rr,2)/8);
stem(sample)
hold on
plot(rr, '-gsq')

steps = zeros(1,size(rr,2)+2);
r_0 = [0 rr 0];

for i = 2:size(rr,2)+1
    steps(i-1) = r_0(i+1) - r_0(i-1);
end

plot(steps, '-bx')
xlim([cut size(rr,2)-cut])

close all;

hold on
for i = 1:7
    plot(steps(i:m:end))
    mean(steps(i:m:end))
    
end