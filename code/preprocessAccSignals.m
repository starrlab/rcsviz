function [tacc,accSig] = preprocessAccSignals(outdatcompleteAcc)

%% gets accelerometer x,y,z and the compound signals, and acc time
accSig.x = outdatcompleteAcc.XSamples-mean(outdatcompleteAcc.XSamples);
accSig.y = outdatcompleteAcc.YSamples-mean(outdatcompleteAcc.YSamples);
accSig.z = outdatcompleteAcc.ZSamples-mean(outdatcompleteAcc.ZSamples);
accSig.norm = sqrt(accSig.x.^2+accSig.y.^2+accSig.z.^2);
tacc = outdatcompleteAcc.derivedTimes;

end

