function updateandcheckdepedencies()
%% This function updates and checks for dependenceis 
system('git pull origin master');

% check if you have turtle json installed 
if ~exist(fullfile(pwd,'toolboxes','turtle_json'),'dir')
    cd(fullfile(pwd,'toolboxes'));
    system('git clone https://github.com/JimHokanson/turtle_json.git');
    cd('..');
    addpath(genpath(fullfile(pwd,'toolboxes')));
end
end