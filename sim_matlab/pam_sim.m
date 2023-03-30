clear vars; close all; clc;
%%
% Impulse response
T = 1;
m = 8;
[pulse,E,mF] = cos_pulse(T,m,16,0.2);
cut = (size(pulse,2)-1)/2;

% Noise
SNR = [0:1:24]; %EbN0+10*log10(1/n); % dB
k = size(SNR,2);

% normalize noise based on symbols of the pam
N0 = cell(1,3);
pamSyms2 = [-1 1];
pow2 = (mean(abs(pamSyms2).^2)*E);
N0{1} = sqrt(10.^(-SNR/10))*pow2; % sqrt(No/2) with Eb=1

pamSyms4 = [-3 -1 1 3];
pow4 = (mean(abs(pamSyms4).^2)*E);
N0{2} = sqrt(10.^(-SNR/10))*pow4; % sqrt(No/2) with Eb=1

pamSyms8 = [-7 -5 -3 -1 1 3 5 7];
pow8 = (mean(abs(pamSyms8).^2))*E;
N0{3} = sqrt(10.^(-SNR/10))*pow8; % sqrt(No/2) with Eb=1 

% variables for sim
sims = 10000; % reduce to 10 for debugging
n = 12000;
BER_pam2 = zeros(1,k);
BER_pam4 = zeros(1,k);
BER_pam8 = zeros(1,k);

for sig = 1:k
    for i = 1:sims
        errs = zeros(1,3);
        for pam = [2 4 8]
            signal = randi([0 1], 1, n);
            % perform modulation
            v = pam_gray(signal, n, pam);
            test = v;
            % up-sample
            N = n/log2(pam);
            v = reshape([v; zeros(m - 1, N)], 1, N * m);
            % pulse shaping
            v = conv(v, pulse);
            v = v(cut+1:end-cut);

            % AWGN
            Nn=length(v);
            r = v + sqrt(m)*N0{log2(pam)}(sig)*randn(1,Nn);
            %r = v;

            % match filter
            r = conv(r, mF);
            r = r(cut+1:end-cut);
            % downsample
            r = r(1:m:end)/m;
            %demodulate
            Nnn = length(r);
            r = pam_gray_inv(r, Nnn, pam);
            % compare, there were issues with the first and last couple 
            % bits, so they are removed
            nErrs = sum(r(6:end-5) ~= signal(6:end-5));
            errs(log2(pam)) = errs(log2(pam)) + (nErrs/(n-12));
        end
        BER_pam2(sig) = BER_pam2(sig) + errs(1);
        BER_pam4(sig) = BER_pam4(sig) + errs(2);
        BER_pam8(sig) = BER_pam8(sig) + errs(3);
    end
end
BER_pam2 = BER_pam2/sims;
BER_pam4 = BER_pam4/sims;
BER_pam8 = BER_pam8/sims;

figure
semilogy(SNR, BER_pam2, '-bx', SNR, BER_pam4, '-gsq', SNR, BER_pam8, '-ro')
legend('PAM2', 'PAM4', 'PAM8')
grid on
xlabel('SNR, dB');
ylabel('BER')