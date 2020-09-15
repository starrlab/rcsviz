function montages = getDiffMontages(databasein)
    montages.ch1 = unique(databasein.chan1);
    montages.ch2 = unique(databasein.chan2);
    montages.ch3 = unique(databasein.chan3);
    montages.ch4 = unique(databasein.chan4);
end