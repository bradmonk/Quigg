%% Quigg Truck Study Data Importer
% Project Notebook URL:
% web('https://goo.gl/39cK39','-browser')

clc; close all; clear;
QuiggDir = '/Users/bradleymonk/Documents/MATLAB/Quigg';
cd(QuiggDir)

subfuncpath = [QuiggDir '/quiggsubfunctions'];
datasetpath = [QuiggDir '/quiggdatasets'];
csvtabspath = [QuiggDir '/csvtables'];
gpath = [QuiggDir ':' subfuncpath ':' datasetpath ':' csvtabspath];
addpath(gpath)


%####################################################################
%%        IMPORT AND PRE-PROCESSING OF ESAL DATASET
%####################################################################
% XLSX document contains 23 tabs organized by interstate route.
%
% ESAL : EQUIVALENT SINGLE AXEL LOAD
% 
% 
% COLS : distance in miles from zero through end of route
% 
%     COL 1     blank
%     COL 2     generic numeric value
%     COL 3     type of vehicle for that ROW
%     COL 4     year traffic data corresponds to
%     COL 5-j   mileage increments
% 
% 
% 
% ROWS : average daily traffic (ADT) per year
% 
%     ROW 1     header for columns
%     ROW 2-i   traffic data:
% 
%         11) 1-ADT   average daily traffic (P + SU + MU)
%         12) 2-ADTT  average daily truck traffic (SU + MU)
%         05) 3-Pass  passenger cars per day
%         06) 4-P%    percent passenger cars per day
%         07) 5-SU    single unit trucks per day
%         08) 6-S%    percent single unit trucks per day
%         09) 7-MU    multi-unit trucks per day
%         10) 8-M%    percent multi-unit trucks per day
%
%
%
% First processing step is to determine ESAL's (equivalent single axle 
% loads) in millions summarized for each year by mile (basically condense 
% the 8 rows per year into a single row per year, converted to ESAL's).  
%
% In order to calculate ESAL's (in millions), use the following equation:
%
% ESALS = (((0.0004 * P) + (0.3940 * SU) + (1.9080 * MU)) *... 
%         LDF * 365) / 1,000,000
%
% Where, 
%     P = 5 - 3-Pass
%     SU = 7 - 5-SU
%     MU = 9 - 7-MU
%     LDF = 0.45 for 4 lanes or less
%     LDF = 0.40 for 6 lanes or more (rural)
%     LDF = 0.37 for 6 lanes or more (urban) 
%
% working on determining urban areas, so just use rural for all of 
% it for now
%
% You will find the number of lanes in the other spreadsheet as 
% column O for originals 
% If lanes added, look for Y in ADDED_LANES column for new lanes
%
% What I would like from this data is a new spreadsheet summarizing all 
% of the ESAL's by mile per every year ADT data is available for each 
% tab by interstate.
%



clc; close all; clear;
cd(fileparts(which('truckstudy_minimport_v1.m')));



filename = 'REHAB_ESAL_PROCESSED_MINI.xlsx';

[status,sheets] = xlsfinfo(filename);


disp('Loading...')
disp(sheets{1})

[ESALN, ~, ESALR] = xlsread(filename,sheets{1});



T = cell2table(ESALR(2:end,:));

T.Properties.VariableNames = ESALR(1,:);

T(559:end,:) = [];

regexpi(T.SURF_4{1} , '| [1-9]') 

%%
TAB = T;




% TAB(isnan(TAB.ESALs_2) | (TAB.ESALs_2<.01),:) = [];
TAB.REPTY2 = split(TAB.SURF_2,"|");
TAB.RT2 = str2double(TAB.REPTY2(:,3));
TAB.RT2(isnan(TAB.RT2))=0;
TAB((TAB.RT2<.01),:) = [];


TAB(isnan(TAB.ESALs_3) | (TAB.ESALs_3<.01),:) = [];
TAB.REPTY3 = split(TAB.SURF_3,"|");
TAB.RT3 = str2double(TAB.REPTY3(:,3));
TAB.RT3(isnan(TAB.RT3))=0;
TAB((TAB.RT3<.01),:) = [];


TAB(isnan(TAB.ESALs_4) | (TAB.ESALs_4<.01),:) = [];
% TAB.REPTY4 = split(TAB.SURF_4,"|");
% TAB.RT4 = str2double(TAB.REPTY4(:,3));
% TAB.RT4(isnan(TAB.RT4))=0;
% TAB((TAB.RT4<.01),:) = [];



u = unique(TAB.RT2)

THICKNESS_ESALS = zeros(size(u));

for i = 1:numel(u)

    THICKNESS_ESALS(i) = mean(TAB.ESALs_3(TAB.RT2==u(i)));


end








%%
map =  [
        .0  .7  .1 ;
        .9  .5  .1 ;
        .9  .1  .6 ;
        .1  .5  .6 ;
        ];

Ci = {map(4,:), map(2,:)};

close all
fh1=figure('Units','normalized','OuterPosition',[.05 .05 .8 .7],'Color','w','MenuBar','none');
hax1 = axes('Position',[.1 .1 .8 .8],'Color','none');

h = superbar(THICKNESS_ESALS', 'BarFaceColor', Ci, 'BarEdgeColor', [.5  .5  .5]);
for i = 1:numel(hax1.Children)
% hax1.Children(i).EdgeColor = [.5  .5  .5];
hax1.Children(i).LineWidth = 3;
end

hax1.XTick = 1:8
hax1.XTickLabel = u
hax1.FontSize = 16;
title('Mean Cumulative ESALs Per Overlay Thickness ')









