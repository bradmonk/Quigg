%####################################################################
%%      SCRIPT FOR IMPORTING MAT FILES AND GENERATING PLOTS
%####################################################################
% Project Notebook URL:
% web('https://goo.gl/39cK39','-browser')

clc; close all; clear;
P.home  = '/Users/bradleymonk/Documents/MATLAB/Quigg'; cd(P.home)
P.funs  = [P.home filesep 'quiggsubfunctions'];
P.data  = [P.home filesep 'generated_datasets'];
P.mats1 = [P.home filesep 'IDOT_MATFILES'];
P.mats2 = [P.home filesep 'IDOT_MATFILES' filesep 'MAT_STEP2'];
P.figs  = [P.home filesep 'figdump'];
addpath(join(string(struct2cell(P)),':',1))
clearvars -except P




%####################################################################
%%                   GET PATHS TO MAT FILES
%####################################################################

% fx='/Users/bradleymonk/Desktop/MAPS WITH HIGHWAY ESTIMATED BY COUNTY LATLON';


%---------------
% FILES.w = what(fx);
FILES.w = what(P.mats2);
FILES.finfo = dir(FILES.w.path);
FILES.finames = {FILES.finfo.name};
c=~cellfun(@isempty,regexp(FILES.finames,'((\S)+(\.mat+))'));
FILES.finames = string(FILES.finames(c)');
FILES.folder = FILES.finfo.folder;
FILES.fipaths = fullfile(FILES.folder,FILES.finames);
disp(FILES.finames);
%---------------


P.fipaths = FILES.fipaths;
P.finames = FILES.finames;

clearvars -except P


%####################################################################
%%                          MAIN LOOP
%####################################################################
for TAB = 1:22
%%

% TAB=13;   %I55
% TAB=22;   %I94
% TAB=14;   %I57
% TAB=16;   %I70
% TAB=18;   %I74
% TAB=19;   %I80
% TAB=15;   %I64


TAB=22;

%--- LOAD MATFILE
MAT = load(P.fipaths(TAB),'ORIG','REHAB','ESAL','IDOT');


ORIG  = MAT.ORIG;
REHAB = MAT.REHAB;
ESAL  = MAT.ESAL;
IDOT  = MAT.IDOT;


head(IDOT,20)



% % i355 has too few datapoints
% if strcmp(IDOT.HIGHWAY(1,:), 'I-355 NB')
% continue
% end


clearvars -except P TAB MAT ORIG REHAB ESAL IDOT










% % PLOT CENTER OF EACH COUNTY ALONG ROUTE USING GEODATA
% XL = xlsread('/Users/bradleymonk/Documents/MATLAB/Quigg/quiggmisc/IDOT SUP DATA/LL.xlsx');
% wm = webmap('World Street Map', 'WrapAround', false);
% wmcenter(wm,40.5,-89.0,12)
% % p1 = wmline(wm,IDOT.LAT,IDOT.LON,'LineWidth',3);
% p1 = wmline(wm,XL(:,2),XL(:,1),'LineWidth',3);
% close all
% figure('Units','pixels','Position',[1065 767 60 50],...
%     'Color','w','MenuBar','none');
% axes('Position',[0 0 1 1],'Color','none');
% text(.2,.5,IDOT.HIGHWAY(1,:),'FontSize',14)





%% REMOVE ZONES BASED ON CRITERIA DEFINED PREVIOUSLY

% REMOVE = (IDOT.TooShort + IDOT.FewRehabs + IDOT.SALnoMATCH)>0;
% 
% IDOT(REMOVE,:) = [];
% 
% RESAL = ESAL;
% RESAL.STAT = [];
% RESAL.ROWID = [];
% RESAL.YEAR = [];
% RESAL.DIST(REMOVE,:) = [];
% RESAL.CONSYEAR(REMOVE,:) = [];
% RESAL.CONSDATE(REMOVE,:) = [];
% RESAL.DATA(REMOVE,:) = [];
% RESAL.ESALS(REMOVE,:) = [];
% RESAL.P_COUNT(REMOVE,:) = [];
% RESAL.S_COUNT(REMOVE,:) = [];
% RESAL.M_COUNT(REMOVE,:) = [];
% RESAL.P_ESAL(REMOVE,:) = [];
% RESAL.S_ESAL(REMOVE,:) = [];
% RESAL.M_ESAL(REMOVE,:) = [];
% 
% 
% clearvars -except P TAB MAT ORIG REHAB ESAL IDOT RESAL



%% DETERMINE *REMAINING* UNIQUE COMBINATIONS OF REHABS
%{.
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




clearvars -except P TAB MAT ORIG REHAB ESAL IDOT RESAL

%}












%% GROUP ORIGINAL PAVEMENT INTO 10-YEAR BINS

minYear = min(IDOT.OYEAR);
modYear = mod(minYear,10);
minYear = minYear - modYear;

maxYear = max(IDOT.OYEAR);
modYear = mod(maxYear,10);
maxYear = maxYear - modYear + 10;


binYear = minYear:10:maxYear;


IDOT.YEARBIN = zeros(size(IDOT,1),1);
IDOT.YEARBINID = zeros(size(IDOT,1),1);

for yy = 2:numel(binYear)


    yr = IDOT.OYEAR >= binYear(yy-1) & IDOT.OYEAR < binYear(yy);

    IDOT.YEARBIN(yr) = binYear(yy-1);
    IDOT.YEARBINID(yr) = yy-1;


end

NOID = IDOT.YEARBINID==0;
IDOT.YEARBIN(NOID)   = binYear(end);
IDOT.YEARBINID(NOID) = yy-1;



clearvars -except P TAB MAT ORIG REHAB ESAL IDOT RESAL


%% DETERMINE NUMBER OF YEARS BETWEEN ORIGIN AND FIRST REHAB


YRS = IDOT.RYEAR(:,1) - IDOT.OYEAR;

IDOT.O2R_YRS = YRS;


% TURN NEGATIVES INTO NAN
IDOT.O2R_YRS(IDOT.O2R_YRS < 1) = NaN;


clearvars -except P TAB MAT ORIG REHAB ESAL IDOT RESAL




%% COMPUTE PAVEMENT LIFETIME TO FIRST REHAB, PER ORIGIN-YEAR-BIN


[yx,yi,yj] = unique(IDOT.YEARBINID);
% ux = IDOT.YEARBINID(ui) ; IDOT.YEARBINID = ux(uj)

YRBIN = IDOT.YEARBIN(yi);   % YEARS WITH DATA





% MAKE ZONES WITHOUT A SURF TYPE 'ZNA'
IDOT.OSURFTYPE(IDOT.OSURFTYPE=='') = 'ZNA';

[sx,si,sj] = unique(IDOT.OSURFTYPE);
disp([sx, accumarray(sj,1)])

SURFBIN = IDOT.OSURFTYPE(si);





MU = zeros(5,numel(YRBIN));
MU(1,:) = YRBIN;

NU = zeros(5,numel(YRBIN));
NU(1,:) = YRBIN;



for yy = 1:numel(YRBIN)

YR = YRBIN(yy);

PAV.CRCP = IDOT(IDOT.OSURFTYPE=="CRCP" & IDOT.YEARBIN==YR, :);
PAV.JRCP = IDOT(IDOT.OSURFTYPE=="JRCP" & IDOT.YEARBIN==YR, :);
PAV.ASPH = IDOT(IDOT.OSURFTYPE=="Full-Depth Asphalt" & IDOT.YEARBIN==YR, :);
PAV.COMP = IDOT(IDOT.OSURFTYPE=="Composite" & IDOT.YEARBIN==YR, :);


MU(2,yy) = nanmean(PAV.CRCP.O2R_YRS);
MU(3,yy) = nanmean(PAV.JRCP.O2R_YRS);
MU(4,yy) = nanmean(PAV.ASPH.O2R_YRS);
MU(5,yy) = nanmean(PAV.COMP.O2R_YRS);

NU(2,yy) = numel(PAV.CRCP.O2R_YRS);
NU(3,yy) = numel(PAV.JRCP.O2R_YRS);
NU(4,yy) = numel(PAV.ASPH.O2R_YRS);
NU(5,yy) = numel(PAV.COMP.O2R_YRS);


end




%% PLOT BAR GRAPHS OF MEAN YEARS TO FIRST REHAB, PER ORIGIN-YEAR-BIN 

c = categorical({'CRCP','JRCP','ASPH','COMP'});

clc; close all;
fh1 = figure('Units','pixels','Position',[10 35 1300 750],...
    'Color','w','MenuBar','none');


for pp = 1:numel(YRBIN)

m = MU(2:end,pp);
ax=subplot(2,ceil(numel(YRBIN)/2),pp); ph=bar(c,m);
title([IDOT.HIGHWAY(1,:) ' ' num2str(YRBIN(pp)) ' - ' num2str(YRBIN(pp)+10)])
% title([num2str(YRBIN(pp)) ' - ' num2str(YRBIN(2))])
ax.YLim = [0 20];

end



%--- SAVE FIGURE TO FIGDUMP FOLDER
pause(.2)
cd(P.figs)
set(fh1, 'PaperPositionMode', 'auto');
saveas(fh1,[IDOT.HIGHWAY(1,:) '_ORIGIN2FIRSTREHAB'],'png');
pause(.5)
cd(P.home)



clearvars -except P TAB MAT ORIG REHAB ESAL IDOT RESAL


%%
clearvars -except FILES TAB
end
disp('FULLY FINISHED!!!')








%% UPSTREAM CODE
%{
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

IDOT(TooShort,:) = [];


clearvars -except FILES TAB MAT ORIG REHAB ESAL IDOT YEAR





%% REMOVE ROWS (ZONES) THAT DONT HAVE 2+ REHABS



if ~strcmp(IDOT.HIGHWAY(1,:), 'I-355 NB')

RYEAR = IDOT.RYEAR;

RYEARnan = isnan(RYEAR);

okNB = sum(~RYEARnan,2) >= 2;

IDOT(~okNB,:) = [];

end

clearvars -except FILES TAB MAT ORIG REHAB ESAL IDOT YEAR





%% REMOVE ROW (ZONES) IF ESAL COUNTS FAR BEFORE/AFTER HW EVEN BUILT


O2EYR1 = IDOT.O2EYR1;

BADROWS = (O2EYR1 > 10) | (O2EYR1 < -5);

IDOT(BADROWS,:) = [];

clearvars -except FILES TAB MAT ORIG REHAB ESAL IDOT YEAR









%% DETERMINE *REMAINING* UNIQUE COMBINATIONS OF REHABS

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









%%
return
%% EXPORT DATASETS


save(['IDOT_TS_' IDOT.HIGHWAY(1,:) '.mat'])
writetable(IDOT,'IDOT_TS.xlsx','Sheet',IDOT.HIGHWAY(1,:));
%}
