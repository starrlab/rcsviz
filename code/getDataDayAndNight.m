function [dbday,dbnight] = getDataDayAndNight(databasein)
% assumes any recording between 12am and 7am is during sleep (defined as night)
% the rest are assumed to not be done during sleep (defined as day)
    idx     = ~(databasein.timeEnd.Hour < 7);
    dbday   = databasein(idx,:);
    dbnight = databasein(~idx,:);
end