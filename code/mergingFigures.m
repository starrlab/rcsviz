% Load saved figures
c=hgload('PSD_DBS_Off_day_ConfigCh1.fig');
k=hgload('PSD_DBS_On_day.fig');
% Prepare subplots
figure
h(1)=subplot(2,2,1);
h(2)=subplot(2,2,2);
h(3)=subplot(2,2,3);
h(4)=subplot(2,2,4);

% Paste figures on the subplots
copyobj(allchild(get(c,'CurrentAxes')),h(1));
copyobj(allchild(get(k,'CurrentAxes')),h(2));

% Add legends
l(1)=legend(h(1),'LegendForFirstFigure')
l(2)=legend(h(2),'LegendForSecondFigure')