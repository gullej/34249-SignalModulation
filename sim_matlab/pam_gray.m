function signalOut = pam_gray(signal, signalLength, pamType)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if (pamType == 2) || (pamType == 4) || (pamType == 8)
    
else
    error('Input pam constellation size not supported')
end

pamSyms2 = [-1 1];
pamSyms4 = [-3 -1 3 1];
%pamSyms4 = [-3 -1 1 3];
pamSyms8 = [-7 -5 -1 -3 7 5 1 3];
%pamSyms8 = [-7 -5 -3 -1 1 3 5 7];

bitSize = log2(pamType);
n = signalLength/bitSize;
signal = reshape(signal, [bitSize n])';
%signal = xor([zeros(n,1) signal(:,1:end-1)], signal);

signalOut = zeros(1,n);

for i = 1:n
    idx = polyval(signal(i,:),2)+1;
    if pamType == 2 
        signalOut(i) = pamSyms2(idx);
    elseif pamType == 4
        signalOut(i) = pamSyms4(idx);
    elseif pamType == 8
        signalOut(i) = pamSyms8(idx);
    end
end

end