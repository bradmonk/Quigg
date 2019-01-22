%####################################################################
%%      SCRIPT FOR IMPORTING MAT FILES AND GENERATING PLOTS
%####################################################################
% Project Notebook URL:
% web('https://goo.gl/39cK39','-browser')

clc; close all; clear;
QuiggDir = '/Users/bradleymonk/Documents/MATLAB/Quigg';
cd(QuiggDir)
p1 = [QuiggDir '/quiggsubfunctions'];
p2 = [QuiggDir '/generated_datasets'];
p3 = [QuiggDir '/IDOT_MATFILES'];
p4 = [QuiggDir '/IDOT_MATFILES/MAT_STEP1'];
gpath = [QuiggDir ':' p1 ':' p2 ':' p3 ':' p4];
addpath(gpath)


clc; close all; clear;
cd(fileparts(which('IDOT_TRUCKSTUDY_STEP1.m')));




%####################################################################
%%                   GET PATHS TO MAT FILES
%####################################################################

%---------------
FILES.w = what('MAT_STEP1');
FILES.finfo = dir(FILES.w.path);
FILES.finames = {FILES.finfo.name};
c=~cellfun(@isempty,regexp(FILES.finames,'((\S)+(\.mat+))'));
FILES.finames = string(FILES.finames(c)');
FILES.folder = FILES.finfo.folder;
FILES.fipaths = fullfile(FILES.folder,FILES.finames);
disp(FILES.fipaths); disp(FILES.finames);
%---------------



%####################################################################
%%                          MAIN LOOP
%####################################################################
for TAB = 1:22
%%


TAB=13;

% TAB=13;   %I55
% TAB=22;   %I94
% TAB=14;   %I57
% TAB=16;   %I70
% TAB=18;   %I74
% TAB=19;   %I80
% TAB=15;   %I64


%--- LOAD MATFILE

MAT = load(FILES.fipaths(TAB),'ORIG','REHAB','ESAL','IDOT');




ORIG  = MAT.ORIG;
REHAB = MAT.REHAB;
ESAL  = MAT.ESAL;
IDOT  = MAT.IDOT;




clearvars -except FILES TAB MAT ORIG REHAB ESAL IDOT








%-----------------------------------------------------------------
%%   CHECK IF ORIGINAL CONSTRUCTION YEAR IS AFTER ESAL FIRST YEAR
%-----------------------------------------------------------------
% BUT DO NOT REMOVE ANYTHING YET...


%------------------------------
V = IDOT.Properties.VariableNames';
regexpStr = '((ESAL)+(\d)+)';
ESALcols = ~cellfun('isempty',regexp(V,regexpStr));
EYEAR = V(ESALcols);
YEAR = str2num(char(regexprep(EYEAR,'ESAL','')));
%------------------------------


ESALS = ESAL.ESALS;

YEARMX = repmat(YEAR',size(ESALS,1),1);

ESALNAN = ~isnan(ESALS);

YEARN = YEARMX.*ESALNAN;

YEARN(YEARN==0) = NaN;

[M,Mi] = min(YEARN',[],1,'omitnan');


YEAR1ESAL = [M; Mi]' ;


OYR2EYR1 = YEAR1ESAL(:,1) - IDOT.OYEAR;

T = array2table([YEAR1ESAL OYR2EYR1]);

T.Properties.VariableNames = {'ESALYR1';'SKIPTO';'O2EYR1'};

IDOT = [IDOT(:,~ESALcols) T IDOT(:,ESALcols)];






clearvars -except FILES TAB MAT ORIG REHAB ESAL IDOT YEAR











%% DETERMINE *ALL* UNIQUE COMBINATIONS OF REHABS

PAVE = IDOT.REHAB;

%-------------------------
VALS = IDOT.OSURFTYPE;
LABS = repmat(" SURF:",size(VALS));
x = cell(size(VALS,1),size(VALS,2),2);
x(:,:,1) = cellstr(LABS);
x(:,:,2) = cellstr(VALS);
y = string(x);
SURF = join(y,3);
SURF = regexprep(SURF,' SURF: (.)',' SURF:*$1');
SURF = regexprep(SURF,' SURF: ',' SURF:?');
SURF = repmat(SURF,1,size(PAVE,2));

% Join string above
x = cell(size(PAVE,1),size(PAVE,2),2);
x(:,:,2) = cellstr(PAVE);
x(:,:,1) = cellstr(SURF);
x = string(x);
%-----------
ROAD = join(x,' | ',3);
%-------------------------


ROADS = ROAD;
ROADS = regexprep(ROADS,'\*','>');
ROADS = regexprep(ROADS,'\?','<');
ROAD = ROADS;

% ALLREHABTYPES = REHAB.ALLREHABTYPES;
% ALLREHABTYPES = regexprep(ALLREHABTYPES,'\*','>');
% ALLREHABTYPES = regexprep(ALLREHABTYPES,'\?','<');
% REHAB.ALLREHABTYPES = ALLREHABTYPES;












[REHABTYPES,ia,ic] = unique(ROAD);

a_counts = accumarray(ic,1);


clc;disp('---------------------------------------------------------')
fprintf('All rehab types for %s \n---------\n',IDOT.HIGHWAY(1,:))
disp([num2str(a_counts) char(REHABTYPES)])
disp('---------------------------------------------------------')


REHABINDEX = zeros(size(ROAD,1), size(ROAD,2), size(REHABTYPES,1));

for i = 1:size(REHABTYPES,1)

    REHABINDEX(:,:,i) = contains(ROAD,REHABTYPES{i});

end



REHAB.ALLREHABTYPES = REHABTYPES;

REHAB.ALLREHABINDEX = REHABINDEX;




clearvars -except FILES TAB MAT ORIG REHAB ESAL IDOT YEAR















%% REMOVE ZONES SHORTER THAN m MILES

MILES = .1;

TooShort = IDOT.MP_DIST < MILES;

IDOT.TooShort = TooShort;


clearvars -except FILES TAB MAT ORIG REHAB ESAL IDOT YEAR





%% REMOVE ROWS (ZONES) THAT DONT HAVE 2+ REHABS



if ~strcmp(IDOT.HIGHWAY(1,:), 'I-355 NB')

RYEAR = IDOT.RYEAR;

RYEARnan = isnan(RYEAR);

okNB = sum(~RYEARnan,2) >= 2;

IDOT.FewRehabs = ~okNB;

end

clearvars -except FILES TAB MAT ORIG REHAB ESAL IDOT YEAR





%% REMOVE ROW (ZONES) IF ESAL COUNTS FAR BEFORE/AFTER HW EVEN BUILT


O2EYR1 = IDOT.O2EYR1;

BADROWS = (O2EYR1 > 10) | (O2EYR1 < -5);

IDOT.SALnoMATCH = BADROWS;

clearvars -except FILES TAB MAT ORIG REHAB ESAL IDOT YEAR









%% DETERMINE *REMAINING* UNIQUE COMBINATIONS OF REHABS
%{
PAVE = IDOT.REHAB;

%-------------------------
VALS = IDOT.OSURFTYPE;
LABS = repmat(" SURF:",size(VALS));
x = cell(size(VALS,1),size(VALS,2),2);
x(:,:,1) = cellstr(LABS);
x(:,:,2) = cellstr(VALS);
y = string(x);
SURF = join(y,3);
SURF = regexprep(SURF,' SURF: (.)',' SURF:*$1');
SURF = regexprep(SURF,' SURF: ',' SURF:?');
SURF = repmat(SURF,1,size(PAVE,2));

% Join string above
x = cell(size(PAVE,1),size(PAVE,2),2);
x(:,:,2) = cellstr(PAVE);
x(:,:,1) = cellstr(SURF);
x = string(x);
%-----------
ROAD = join(x,' | ',3);
%-------------------------


ROADS = ROAD;
ROADS = regexprep(ROADS,'\*','>');
ROADS = regexprep(ROADS,'\?','<');
ROAD = ROADS;

% ALLREHABTYPES = REHAB.ALLREHABTYPES;
% ALLREHABTYPES = regexprep(ALLREHABTYPES,'\*','>');
% ALLREHABTYPES = regexprep(ALLREHABTYPES,'\?','<');
% REHAB.ALLREHABTYPES = ALLREHABTYPES;






[REHABTYPES,ia,ic] = unique(ROAD);

a_counts = accumarray(ic,1);


disp('---------------------------------------------------------')
fprintf('Remaining rehab types for %s \n---------\n',IDOT.HIGHWAY(1,:))
disp([num2str(a_counts) char(REHABTYPES)])
disp('---------------------------------------------------------')


REHABINDEX = zeros(size(ROAD,1), size(ROAD,2), size(REHABTYPES,1));

for i = 1:size(REHABTYPES,1)

    REHABINDEX(:,:,i) = contains(ROAD,REHABTYPES{i});

end



REHAB.REHABTYPES = REHABTYPES;

REHAB.REHABINDEX = REHABINDEX;




clearvars -except FILES TAB MAT ORIG REHAB ESAL IDOT YEAR

%}





%% EXPORT DATASETS

save(['IDOT_TS_' IDOT.HIGHWAY(1,:) '.mat'])
% writetable(IDOT,'IDOT_TS.xlsx','Sheet',IDOT.HIGHWAY(1,:));

clearvars -except FILES TAB
end
