tt = tic;
allon = true;

clearvars -except tt allon
w = 2; b = 7;
disp(['plotting w = ' num2str(w) ' b = ' num2str(b) ...
    ' after ' num2str(toc(tt),2) ' s'])
timeseriesComparison
clearvars -except tt allon
w = 3; b = 7;
disp(['plotting w = ' num2str(w) ' b = ' num2str(b) ...
    ' after ' num2str(toc(tt),2) ' s'])
timeseriesComparison
clearvars -except tt allon
w = 4; b = 7;
disp(['plotting w = ' num2str(w) ' b = ' num2str(b) ...
    ' after ' num2str(toc(tt),2) ' s'])
timeseriesComparison
clearvars -except tt allon
w = 3; b = 3;
disp(['plotting w = ' num2str(w) ' b = ' num2str(b) ...
    ' after ' num2str(toc(tt),2) ' s'])
timeseriesComparison
clearvars -except tt allon
w = 4; b = 3;
disp(['plotting w = ' num2str(w) ' b = ' num2str(b) ...
    ' after ' num2str(toc(tt),2) ' s'])
timeseriesComparison

clear all
