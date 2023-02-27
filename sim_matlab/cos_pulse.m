function [gT,EgT,gR]=cos_pulse(T,m,K,alpha)

Ts=T/m;
Ns=K*m;
N1=floor((1-alpha)/(2*T)/(1/(K*T)));
N2=floor((1+alpha)/(2*T)/(1/(K*T)));
N3=Ns/2-1;
c=1;
GT=sqrt(c*T)*[ones(1,N1+1)...        
    cos((2*pi*[N1+1:N2]/(K*T)*T-pi)/4/alpha+pi/4)...              
    zeros(1,N3-N2)];
GT=[GT 0 fliplr(GT(2:end))]; 
gT=fftshift(real(ifft(GT)/Ts));
gT=[gT(1)/2 gT(2:end) gT(1)/2];
EgT=sum(gT.^2)*Ts;
gR=fliplr(gT)/sqrt(EgT);