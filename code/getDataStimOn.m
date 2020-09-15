function dbstimon = getDataStimOn(databasein)
    idx     = ( databasein.stimulation_on == 1  & ...
                    databasein.amplitude_mA  > 0    & ...
                        databasein.rate_Hz >= 100         );

    dbstimon = databasein(idx,:);
end