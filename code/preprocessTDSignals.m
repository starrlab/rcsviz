function [t,Y] = preprocessTDSignals(outdatcomplete)

%% removes DC and transforms to mV to microvolts and puts the neural signals into a matrix 4xm (m number of samples of the time domain signal)

y0 = outdatcomplete.key0; y0 = (y0-mean(y0))*1e3; 
y1 = outdatcomplete.key1; y1 = (y1-mean(y1))*1e3;
y2 = outdatcomplete.key2; y2 = (y2-mean(y2))*1e3;
y3 = outdatcomplete.key3; y3 = (y3-mean(y3))*1e3;

Y(1,:) = y0;
Y(2,:) = y1;
Y(3,:) = y2;
Y(4,:) = y3;

t = outdatcomplete.derivedTimes;

end