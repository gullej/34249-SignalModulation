clear variables;close all;clc
%%
T = 1;
m = 4;
T_s = T/m;

pulse = cos_pulse(T,m,25,0.2);
E = sum(pulse.^2)*T_s;

SNR = [0:1:24]; %EbN0+10*log10(1/n); % dB
N0 = sqrt(10.^(-SNR/10)/2); % sqrt(No/2) with Eb=1
n = size(N0,2);

M = [2,4,8];
m = size(M,2);

P_e = zeros(m,n);
for i = 1:m
    E_av = (M(i)^2-1)/3 * E;
    for j = 1:n
        P_e(i,j) = (2*M(i)-2)/M(i) * qfunc(sqrt(6*E_av)/((M(i)^2-1)*N0(j)));
    end
end

h = figure;

semilogy(P_e(1,:)')
hold on
semilogy(P_e(2,:)')
semilogy(P_e(3,:)')

ylim([10^(-10) 10^(0)])
xlim([1 24])
grid on
legend('PAM2','PAM4','PAM8')
ylabel('P_e','FontSize',11,'FontWeight','bold')
xlabel('10*log(E_{av}/N_0) [SNR]','FontSize',11,'FontWeight','bold')
title('Symbol Error Probability','FontSize',14,'FontWeight','bold')

set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,'docs/SymbolErrorProbability','-dpdf','-r0')