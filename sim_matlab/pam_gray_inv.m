function signalOut = pam_gray_inv(signal, signalLength, pamType)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if (pamType == 2) || (pamType == 4) || (pamType == 8)
    
else
    error('Input pam constellation size not supported')
end

pamSyms2 = {0 1};
pamSyms4 = {[0 0] [0 1] [1 1] [1 0]};
pamSyms8 = {[0 0 0] [0 0 1] [0 1 1] [0 1 0] [1 1 0] [1 1 1] [1 0 1] [1 0 0]};

signalOut = zeros(signalLength, log2(pamType));

for i = 1:signalLength
    if pamType == 2
        if signal(i) > 0
            signalOut(i,:) = pamSyms2{2};
        else
            signalOut(i,:) = pamSyms2{1};
        end
    elseif pamType == 4
        if signal(i) > 2
            signalOut(i,:) = pamSyms4{4};
        elseif signal(i) > 0
            signalOut(i,:) = pamSyms4{3};
        elseif signal(i) < -2
            signalOut(i,:) = pamSyms4{1};
        else%if signal(i) < 0
            signalOut(i,:) = pamSyms4{2};
        end
    elseif pamType == 8
        if signal(i) > 6
            signalOut(i,:) = pamSyms8{8};
        elseif signal(i) > 4
            signalOut(i,:) = pamSyms8{7};
        elseif signal(i) > 2
            signalOut(i,:) = pamSyms8{6};
        elseif signal(i) > 0
            signalOut(i,:) = pamSyms8{5};
        elseif signal(i) < -6
            signalOut(i,:) = pamSyms8{1};
        elseif signal(i) < -4
            signalOut(i,:) = pamSyms8{2};
        elseif signal(i) < -2
            signalOut(i,:) = pamSyms8{3};
        else%if signal(i) < 0
            signalOut(i,:) = pamSyms8{4};
        end
    end
end

signalOut = reshape(signalOut', 1, signalLength*log2(pamType));

end