function plot_number_hours_patient_group(dirname)
%% plots hours of data recorded per patient

%% we will segragate hours of home recordings data in 4 categories
% 1) DBS off, day
% 2) DBS off, night
% 3) DBS on, day
% 4) DBS on, night
% Note: in patient RCS03 both sides need to be segragated

close all, clear all, clc
fontSize = 22;
patsgp = {'RCS03','RCS09','RCS10'};
dirname = '/Users/juananso/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/';
savedir = '/Users/juananso/Box Sync/RCS_GP_data_analysis_boxshare_juan_cora_phil/databaseoutput';

%% access summary data base file
sensestimdbpath = fullfile(dirname,'sense_stim_database.mat');

%% create folder output, init folder to save intermediate data output
mkdir(savedir,'figures_hours_recording_gp');
saveFigDir = fullfile(savedir,'/figures_hours_recording_gp');

%% get sense-stim data base for each patient's side
dball = load(sensestimdbpath);
db = table();
for ii=1:size(patsgp,2)
    idpats(:,ii) = strcmp(dball.sense_stim_database.patient,char(patsgp(ii)));
    dbpatii = dball.sense_stim_database(idpats(:,ii),:);
    idpatsr250 = contains(dbpatii.chan1,'250Hz');
    dbpatiisr250 = dbpatii(idpatsr250,:);
    
    %% dbs off
    iddbsoff = find(dbpatiisr250.stimulation_on == 0 | dbpatiisr250.amplitude_mA <= 0 | dbpatiisr250.rate_Hz <= 100);
    dbsoff = dbpatiisr250(iddbsoff,:);
    idxday = ~(dbsoff.endTime.Hour < 7);
    dbsoff_day = dbsoff(idxday,:);
    dbsoff_night = dbsoff(~idxday,:);
    db.rcs_Patient(ii) = dbsoff_day.patient(1);
    % separate sides, during day
    idxday_Left = find(strcmp(dbsoff_day.side,'L'));
    dbsoff_day_Left = dbsoff_day(idxday_Left,:);
    idxday_Right = find(strcmp(dbsoff_day.side,'R'));
    dbsoff_day_Right = dbsoff_day(idxday_Right,:);
    db.dbsoff_HoursDay_Left(ii) = sum(dbsoff_day_Left.duration);
    db.dbsoff_HoursDay_Right(ii) = sum(dbsoff_day_Right.duration);
    % separate sides, during night
    idxnight_Left = find(strcmp(dbsoff_night.side,'L'));
    dbsoff_night_Left = dbsoff_night(idxnight_Left,:);
    idxnight_Right = find(strcmp(dbsoff_night.side,'R'));
    dbsoff_night_Right = dbsoff_night(idxnight_Right,:);
    db.dbsoff_HoursNight_Left(ii) = sum(dbsoff_night_Left.duration);
    db.dbsoff_HoursNight_Right(ii) = sum(dbsoff_night_Right.duration);
    
    %% dbs on
    iddbson = find(dbpatiisr250.stimulation_on == 1 & dbpatiisr250.amplitude_mA > 0 & dbpatiisr250.rate_Hz >= 100);
    dbson = dbpatiisr250(iddbson,:);
    idxxday = ~(dbson.endTime.Hour < 7);
    dbson_day = dbson(idxxday,:);
    dbson_night = dbson(~idxxday,:);

    % separate sides, during day
    idxxday_Left = find(strcmp(dbson_day.side,'L'));
    dbson_day_Left = dbson_day(idxxday_Left,:);
    idxday_Right = find(strcmp(dbson_day.side,'R'));
    dbson_day_Right = dbson_day(idxday_Right,:);
    db.dbson_HoursDay_Left(ii) = sum(dbson_day_Left.duration);
    db.dbson_HoursDay_Right(ii) = sum(dbson_day_Right.duration);
    % separate sides, during night
    idxnight_Left = find(strcmp(dbson_night.side,'L'));
    dbson_night_Left = dbson_night(idxnight_Left,:);
    idxnight_Right = find(strcmp(dbson_night.side,'R'));
    dbson_night_Right = dbson_night(idxnight_Right,:);
    db.dbson_HoursNight_Left(ii) = sum(dbson_night_Left.duration);
    db.dbson_HoursNight_Right(ii) = sum(dbson_night_Right.duration);
    
end

%% plot hours in bar plot (each side, Left and Right, separated) & save figures
sides = {'Left','Right'};
x = [1, 2, 3];
xtipoffset = [-0.28,-0.09,0.09,0.28];
figh = zeros(1,size(sides,2));
for sideii=1:length(sides)
    figh(sideii) = figure(sideii); set(figh(sideii), 'Units', 'Normalized', 'OuterPosition', [0, 0, 0.5, 0.75]);
    y = getHoursPerSide(db,sideii);
    b = bar(x,round(hours(y)));
    for ii=1:size(y,2)
        xtips = b(ii).XData+xtipoffset(ii);
        ytips = b(ii).YData;
        labels = string(b(ii).YData);
        text(xtips,ytips,labels,'HorizontalAlignment','center',...
            'VerticalAlignment','bottom')
    end
    legend('DBS OFF awake','DBS OFF sleep','DBS ON awake','DBS ON sleep');
    title([char(sides(sideii)),' side, Hours home recordings Globus Pallidus patients'])
    set(gca, 'XTick', [1 2 3])
    set(gca, 'XTickLabel', patsgp)
    set( findall(figh(sideii), '-property', 'fontsize'), 'fontsize', fontSize);

    % save figures
    figNameFig = [char(sides(sideii)),'Side_HoursRecording_GP_patients.fig'];
    figNamePng = [char(sides(sideii)),'Side_HoursRecording_GP_patients.png'];
    pointFigFig = fullfile(saveFigDir,figNameFig);
    saveas(figh(sideii),pointFigFig)
    pointFigPng = fullfile(saveFigDir,figNamePng);
    saveas(figh(sideii),pointFigPng)
end

%% gets hours per side
function yo = getHoursPerSide(db,idside)
    switch idside
        case 1, yo = [db.dbsoff_HoursDay_Left(1), db.dbsoff_HoursNight_Left(1),db.dbson_HoursDay_Left(1),db.dbson_HoursNight_Left(1);
                        db.dbsoff_HoursDay_Left(2), db.dbsoff_HoursNight_Left(2),db.dbson_HoursDay_Left(2),db.dbson_HoursNight_Left(2);
                            db.dbsoff_HoursDay_Left(3), db.dbsoff_HoursNight_Left(3),db.dbson_HoursDay_Left(3),db.dbson_HoursNight_Left(3)];
        
        case 2, yo = [db.dbsoff_HoursDay_Right(1), db.dbsoff_HoursNight_Right(1),db.dbson_HoursDay_Right(1),db.dbson_HoursNight_Right(1);
                        db.dbsoff_HoursDay_Right(2), db.dbsoff_HoursNight_Right(2),db.dbson_HoursDay_Right(2),db.dbson_HoursNight_Right(2);
                            db.dbsoff_HoursDay_Right(3), db.dbsoff_HoursNight_Right(3),db.dbson_HoursDay_Right(3),db.dbson_HoursNight_Right(3)];
    end
end    

end