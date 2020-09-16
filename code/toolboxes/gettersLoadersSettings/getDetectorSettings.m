function out = getDetectorSettings(fn)

    warning('off','MATLAB:table:RowsAddedExistingVars');
    DeviceSettings = jsondecode(fixMalformedJson(fileread(fn),'DeviceSettings'));
    
    f = 1;
    detectorSettings = table();
    cntChangeTemp = 1;
    while f<length(DeviceSettings)
        curStr = DeviceSettings{f};
        det_fiels = {'blankingDurationUponStateChange',...
        'detectionEnable','detectionInputs','fractionalFixedPointValue',...
        'holdoffTime','onsetDuration','terminationDuration','updateRate'};
        if isfield(curStr,'DetectionConfig')
            % start time and host unix time
            timenum = curStr.RecordInfo.HostUnixTime;
            t =  datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS'); 
            detectorSettings.changeNum(cntChangeTemp) = cntChangeTemp;
            detectorSettings.timeChange(cntChangeTemp) = t;
            lds_fn = {'Ld0','Ld1'};
            for ll = 1:length(lds_fn)
%                 ldTable = table();
                if isfield(curStr.DetectionConfig,lds_fn{ll})
                    LD = curStr.DetectionConfig.(lds_fn{ll});
                    detectorSettings.([lds_fn{ll} '_' 'biasTerm']){cntChangeTemp} = LD.biasTerm';
                    detectorSettings.([lds_fn{ll} '_' 'normalizationMultiplyVector']){cntChangeTemp} = [LD.features.normalizationMultiplyVector];
                    detectorSettings.([lds_fn{ll} '_' 'normalizationSubtractVector']){cntChangeTemp} = [LD.features.normalizationSubtractVector];
                    detectorSettings.([lds_fn{ll} '_' 'weightVector']){cntChangeTemp} = [LD.features.weightVector];
                    for d = 1:length(det_fiels)
                        detectorSettings.([lds_fn{ll} '_' det_fiels{d}]){cntChangeTemp} =  LD.(det_fiels{d});
                    end
                else % fill in previous settings.
                    warning('missing field on first itiration');
                end
            end    
            
        cntChangeTemp = cntChangeTemp + 1;
        end
        f = f +1;
    end
    out = detectorSettings;
end