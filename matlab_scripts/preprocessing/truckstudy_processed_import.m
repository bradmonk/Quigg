clc; close all; clear;
QuiggDir = '/Users/bradleymonk/Documents/MATLAB/Quigg';
cd(QuiggDir)

subfuncpath = [QuiggDir '/quiggsubfunctions'];
datasetpath = [QuiggDir '/quiggdatasets'];
gpath = [QuiggDir ':' subfuncpath ':' datasetpath];
addpath(gpath)


clc; close all; clear;
cd(fileparts(which('truckstudy_processed_import.m')));

%% IMPORT DATASET


filename = 'HWYDATA.xlsx';

[status,sheets] = xlsfinfo(filename);

% disp('Loading...')
% disp(sheets{TAB})
% [ESALN, ~, ESALR] = xlsread(filename,sheets{TAB});

[ESALN, ~, ESALR] = xlsread(filename);



%% SORT AND CLEAN DATA

ESALT = cell2table(ESALR(2:end,:));

NAMES = ESALR(1,:);
NAMES = regexprep(NAMES,' ','');
ESALT.Properties.VariableNames = NAMES;



% SORT BY ZONE LENGTH
[ET,j] = sortrows(ESALT,'MP_DIST','descend');


% REMOVE ANY ZONE LESS THAN 0.5 MILES LONG
ET(ET.MP_DIST < .5 , :) = [];


% REMOVE ROWS WITH MORE THAN 6 NAN
AGE = table2array(ET(:,17:25));
AGEnan = isnan(AGE);
ALLNAN = sum(AGEnan,2) > 6;
ET(ALLNAN , :) = [];




% FIND WORK YEARS AFTER 1990
WORKYR = table2array(ET(:,49:58));
WORKYRnan = isnan(WORKYR);
NEWISH = WORKYR > 1990;

ALLNAN = sum(WORKYRnan,2) > 6;
ET(ALLNAN , :) = [];






















