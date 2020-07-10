function plotRawDataSegment(dataSegment,timemarker,markerstr)
%% plots 4 channels of neural data segment passed as argument
figure
        for ii=1:4
            subplot(4,1,ii)
            switch ii
                case 1
                    plot(dataSegment.neural.derivedTimes,dataSegment.neural.key0);
                    hold on; plot([timemarker timemarker],[min(dataSegment.neural.key0) max(dataSegment.neural.key0)],'r')
                    legend('td0',markerstr)
                case 2
                    plot(dataSegment.neural.derivedTimes,dataSegment.neural.key1);
                    hold on; plot([timemarker timemarker],[min(dataSegment.neural.key1) max(dataSegment.neural.key1)],'r')
                    legend('td1',markerstr)
                case 3
                    plot(dataSegment.neural.derivedTimes,dataSegment.neural.key2);
                    hold on; plot([timemarker timemarker],[min(dataSegment.neural.key2) max(dataSegment.neural.key2)],'r')
                    legend('td2',markerstr)
                case 4
                    plot(dataSegment.neural.derivedTimes,dataSegment.neural.key3);
                    hold on; plot([timemarker timemarker],[min(dataSegment.neural.key3) max(dataSegment.neural.key3)],'r')
                    legend('td3',markerstr)
            end
        end

end