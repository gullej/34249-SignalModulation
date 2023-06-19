clear variables; close all; clc
%% calculating Qa.b

taps = cos_pulse(1,8,4,0.2);
A = 14;
L = 2 + 1; % (dependant on constellation size)

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

taps_fi     = fi(taps,1,A-L,b)';
taps_fi_bin = bin(taps_fi);

taps_norm_fi     = fi(taps_norm,1,A-L-1,b_norm-1)';
taps_norm_fi_bin = bin(taps_norm_fi);

%%

h = figure;
plot(taps)
ylabel('Amplitude')
xlabel('Sample Number','FontSize',11,'FontWeight','bold')
title('Impulse Response','FontSize',14,'FontWeight','bold')
set(h,'Units','Inches');
pos = get(h,'Position');

set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,'../Docs/Impulse_Response','-dpdf','-r0')

%%

h = figure;
plot(taps_norm_fi)
ylabel('Amplitude')
xlabel('Sample Number','FontSize',11,'FontWeight','bold')
title('Impulse Response (Finite Point)','FontSize',14,'FontWeight','bold')
set(h,'Units','Inches');
pos = get(h,'Position');

set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,'../Docs/Impulse_Response_NoFi','-dpdf','-r0')