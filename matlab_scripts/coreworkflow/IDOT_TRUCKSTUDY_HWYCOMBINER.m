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
%%                       LOADING LOOP
%####################################################################
for TAB = 1:22


% TAB=13;   %I55
% TAB=22;   %I94
% TAB=14;   %I57
% TAB=16;   %I70
% TAB=18;   %I74
% TAB=19;   %I80
% TAB=15;   %I64
% TAB=13;

%--- LOAD MATFILE
MAT{TAB} = load(P.fipaths(TAB),'ORIG','REHAB','ESAL','IDOT');


end





%####################################################################
%%                          DEAL LOOP
%####################################################################
for TAB = 1:22

ORIG{TAB}  = MAT{TAB}.ORIG;
REHAB{TAB} = MAT{TAB}.REHAB;
ESAL{TAB}  = MAT{TAB}.ESAL;
IDOT{TAB}  = MAT{TAB}.IDOT;


% head(IDOT,20)
% % i355 has too few datapoints
% if strcmp(IDOT.HIGHWAY(1,:), 'I-355 NB')
% continue
% end

end
clearvars -except P TAB MAT ORIG REHAB ESAL IDOT




%####################################################################
%%           COMBINE TRAFFIC COUNTS WITH IDOT TABLE
%####################################################################

for i = 1:22

P = table(ESAL{i}.P_COUNT,'VariableNames',{'CARS_COUNTS'});
S = table(ESAL{i}.S_COUNT,'VariableNames',{'TRUCK_COUNTS'});
M = table(ESAL{i}.M_COUNT,'VariableNames',{'SEMI_COUNTS'});

IDOT{i} = [IDOT{i} P S M];


% %------------------------------
% V = IDOT{i}.Properties.VariableNames';
% regexpStr = '((ESAL)+(\d)+)';
% ESALcols = ~cellfun('isempty',regexp(V,regexpStr));
% EYEAR = V(ESALcols);
% YEAR = str2num(char(regexprep(EYEAR,'ESAL','')));
% ES = IDOT{i}(:,ESALcols);
% ESA = ESAL{i}.ESALS(IDOT{i}.ZONE,:);
% ESA = zeros(size(ESA,1),size(ESA,2),7);
% ESA(:,:,1) = ESAL{i}.ESALS(IDOT{i}.ZONE,:);   % ESA(:,:,1)  COMBINED ESALS
% ESA(:,:,2) = ESAL{i}.P_COUNT(IDOT{i}.ZONE,:); % ESA(:,:,2)  CAR    COUNTS
% ESA(:,:,3) = ESAL{i}.S_COUNT(IDOT{i}.ZONE,:); % ESA(:,:,3)  TRUCK  COUNTS
% ESA(:,:,4) = ESAL{i}.M_COUNT(IDOT{i}.ZONE,:); % ESA(:,:,4)  SEMI   COUNTS
% ESA(:,:,5) = ESAL{i}.P_ESAL(IDOT{i}.ZONE,:);  % ESA(:,:,5)  CAR    ESALS
% ESA(:,:,6) = ESAL{i}.S_ESAL(IDOT{i}.ZONE,:);  % ESA(:,:,6)  TRUCK  ESALS
% ESA(:,:,7) = ESAL{i}.M_ESAL(IDOT{i}.ZONE,:);  % ESA(:,:,7)  SEMI   ESALS
% %------------------------------





end


clearvars -except P TAB MAT ORIG REHAB ESAL IDOT

%{
clc

x=[];
y={};

for i = 1:22


x(i) = height(IDOT{i})
y{i} = IDOT{i}.HIGHWAY(1,:)






end
y=y';
x=x';
disp(x)
disp(y)

clearvars -except P TAB MAT ORIG REHAB ESAL IDOT x y







%####################################################################
%%                   CUMULATIVE ZONE LENGTHS
%####################################################################

x=[];
h=[];
y={};



for i = 1:22

    x(i) = height(IDOT{i});
    h(i) = sum(IDOT{i}.MP_DIST);

end
h=h';
x=x';
clearvars -except P TAB MAT ORIG REHAB ESAL IDOT x y h


y = NaN(max(x),22);



for i = 1:22

    y(1:(height(IDOT{i})) , i) = IDOT{i}.MP_DIST;

end

y=y';

close all
fh1 = figure('Units','pixels','Position',[10 35 1100 750],...
    'Color','w','MenuBar','none');
ax1 = axes('Position',[.06 .06 .9 .9],'Color','none');

ph1 = bar(y,'stacked');

t={
'I-155 '
'I-172 '
'I-180 '
'I-190 '
'I-24  '
'I-255 '
'I-270 '
'I-280 '
'I-290 '
'I-355 '
'I-39  '
'I-474 '
'I-55  '
'I-57  '
'I-64  '
'I-70  '
'I-72  '
'I-74  '
'I-80  '
'I-88  '
'I-90  '
'I-94  '};


ax1.XTick = 1:22;
ax1.XTickLabel = cellstr(t);

disp('done')





%####################################################################
%%                          COLD ZONES
%####################################################################

x=[];
h=[];
y={};



for i = 1:22

    x(i) = height(IDOT{i});
    h(i) = sum(IDOT{i}.MP_DIST);

end
h=h';
x=x';
clearvars -except P TAB MAT ORIG REHAB ESAL IDOT x y h


y = NaN(max(x),22);



for i = 1:22

    y(1:(height(IDOT{i})) , i) = IDOT{i}.LAT;

end

% y=y';

close all
fh1 = figure('Units','pixels','Position',[10 35 1100 750],...
    'Color','w');
ax1 = axes('Position',[.06 .06 .9 .9],'Color','none');

ph1 = imagesc(flipud(y));
colormap([1 1 1; flipud(jet)]); colorbar;


t={
'I-155 '
'I-172 '
'I-180 '
'I-190 '
'I-24  '
'I-255 '
'I-270 '
'I-280 '
'I-290 '
'I-355 '
'I-39  '
'I-474 '
'I-55  '
'I-57  '
'I-64  '
'I-70  '
'I-72  '
'I-74  '
'I-80  '
'I-88  '
'I-90  '
'I-94  '};


ax1.XTick = 1:22;
ax1.XTickLabel = cellstr(t);

disp('done')






%####################################################################
%%                          LANES
%####################################################################
KEEP = [9 11 13 14 15 16 17 18 19 20 21 22];


IDOT   = IDOT(KEEP);
ORIG   = ORIG(KEEP);
REHAB  = REHAB(KEEP);
ESAL   = ESAL(KEEP);

%%
x=[];
L=[];
y={};



for i = 1:12

    x(i) = height(IDOT{i});
    L(i) = sum(IDOT{i}.OLANES);

end
L=L';
x=x';
clearvars -except P TAB MAT ORIG REHAB ESAL IDOT x y h


y = NaN(max(x),22);

for i = 1:12

    y(1:(height(IDOT{i})) , i) = IDOT{i}.OLANES;

end

% y=y';

y(y==0) = 4;
y(isnan(y)) = 4;

y = y + rand(size(y)).*.2 - .2;

close all
fh1 = figure('Units','pixels','Position',[10 35 1100 750],...
    'Color','w');
ax1 = axes('Position',[.06 .06 .9 .9],'Color','none');

ph1 = plot(y);
axis tight


t={
'I-290 '
'I-39  '
'I-55  '
'I-57  '
'I-64  '
'I-70  '
'I-72  '
'I-74  '
'I-80  '
'I-88  '
'I-90  '
'I-94  '};


% ax1.XTick = 1:12;
% ax1.XTickLabel = cellstr(t);

disp('done')

%}




%####################################################################
%%                 CREATE ONE SINGLE TABLE
%####################################################################


T = IDOT{1}(1:5,82);
IDOT{10} = [IDOT{10}(:,1:81) T IDOT{10}(:,82:end)];


for i = 1:22

    IDOT{i}.HIGHWAY = string(IDOT{i}.HIGHWAY);

end



clear RYEAR REHAB NY NR
NY=0; NR=0;
for i = 1:22

    RYEAR{i} = IDOT{i}.RYEAR;
    REHAB{i} = IDOT{i}.REHAB;

    NY = max([size(RYEAR{i},2)  NY]);
    NR = max([size(REHAB{i},2)  NR]);

end


for i = 1:22
clear NAR NYR

    NAR = repmat({' NDES:? |  ACPG:? |  REM:?'},size(IDOT{i},1),NR);
    NAR(1:size(REHAB{i},1),1:size(REHAB{i},2) ) = REHAB{i};
    IDOT{i}.REHAB = NAR;

    NYR = NaN(size(IDOT{i},1),NY);
    NYR(1:size(REHAB{i},1),1:size(REHAB{i},2) ) = RYEAR{i};
    IDOT{i}.RYEAR = NYR;

end












DOT = [IDOT{1};IDOT{2};IDOT{3};IDOT{4};IDOT{5};IDOT{6};IDOT{7};IDOT{8};...
IDOT{9};IDOT{10};IDOT{11};IDOT{12};IDOT{13};IDOT{14};IDOT{15};IDOT{16};...
IDOT{17};IDOT{18};IDOT{19};IDOT{20};IDOT{21};IDOT{22}];





% for i = 2:22
% 
% P = table(ESAL{i}.P_COUNT,'VariableNames',{'CARS_COUNTS'});
% S = table(ESAL{i}.S_COUNT,'VariableNames',{'TRUCK_COUNTS'});
% M = table(ESAL{i}.M_COUNT,'VariableNames',{'SEMI_COUNTS'});
% 
% IDOT{i} = [IDOT{i} P S M];
% 
% end


IDOT = DOT;
clearvars -except TAB ESAL IDOT

%%

save('IDOT_FORSTEP4.mat','IDOT','ESAL');

writetable(IDOT,'IDOTTABLE.xlsx');


return
%####################################################################
%%                          MAIN LOOP
%####################################################################
for TAB = 1:22











%% TAG HIGHWAY ZONES BUILT AFTER 1999

IDOT.afterY2K = IDOT.OYEAR >= 2000;








%% REMOVE ZONES BASED ON CRITERIA DEFINED PREVIOUSLY

% REMOVE = (IDOT.TooShort + IDOT.FewRehabs + IDOT.SALnoMATCH + IDOT.afterY2K)>0;
% REMOVE = (IDOT.TooShort + IDOT.SALnoMATCH + IDOT.afterY2K)>0;
% REMOVE = (IDOT.SALnoMATCH + IDOT.afterY2K)>0;
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


return
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



% TAG SURFACE TYPES NOT IN BIG-4 AS "OTHER"
OTHR = (IDOT.OSURFTYPE~="CRCP"                 &...
        IDOT.OSURFTYPE~="JRCP"                 &...
        IDOT.OSURFTYPE~="Full-Depth Asphalt"   &...
        IDOT.OSURFTYPE~="Composite");

IDOT.OSURFTYPE(OTHR) = "OTHER";






MU = zeros(6,numel(YRBIN));
MU(1,:) = YRBIN;

NU = zeros(6,numel(YRBIN));
NU(1,:) = YRBIN;



for yy = 1:numel(YRBIN)

YR = YRBIN(yy);

PAV.CRCP = IDOT(IDOT.OSURFTYPE=="CRCP" & IDOT.YEARBIN==YR, :);
PAV.JRCP = IDOT(IDOT.OSURFTYPE=="JRCP" & IDOT.YEARBIN==YR, :);
PAV.ASPH = IDOT(IDOT.OSURFTYPE=="Full-Depth Asphalt" & IDOT.YEARBIN==YR, :);
PAV.COMP = IDOT(IDOT.OSURFTYPE=="Composite" & IDOT.YEARBIN==YR, :);
PAV.OTHR = IDOT(IDOT.OSURFTYPE=="OTHER" & IDOT.YEARBIN==YR, :);


MU(2,yy) = nanmean(PAV.CRCP.O2R_YRS);
MU(3,yy) = nanmean(PAV.JRCP.O2R_YRS);
MU(4,yy) = nanmean(PAV.ASPH.O2R_YRS);
MU(5,yy) = nanmean(PAV.COMP.O2R_YRS);
MU(6,yy) = nanmean(PAV.OTHR.O2R_YRS);


NU(2,yy) = numel(PAV.CRCP.O2R_YRS);
NU(3,yy) = numel(PAV.JRCP.O2R_YRS);
NU(4,yy) = numel(PAV.ASPH.O2R_YRS);
NU(5,yy) = numel(PAV.COMP.O2R_YRS);
NU(6,yy) = numel(PAV.OTHR.O2R_YRS);


end




%% PLOT BAR GRAPHS OF MEAN YEARS TO FIRST REHAB, PER ORIGIN-YEAR-BIN 

c = categorical({'CRCP','JRCP','ASPH','COMP','OTHR'});

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
% pause(.2)
% cd(P.figs)
% set(fh1, 'PaperPositionMode', 'auto');
% saveas(fh1,[IDOT.HIGHWAY(1,:) '_ORIGIN2FIRSTREHAB'],'png');
% pause(.5)
% cd(P.home)



clearvars -except P TAB MAT ORIG REHAB ESAL IDOT RESAL MU NU

return







%% PREPARE DATASETS FOR PLOTTING

%------------------------------
V = IDOT.Properties.VariableNames';
regexpStr = '((ESAL)+(\d)+)';
ESALcols = ~cellfun('isempty',regexp(V,regexpStr));
EYEAR = V(ESALcols);
YEAR = str2num(char(regexprep(EYEAR,'ESAL','')));

ES = IDOT(:,ESALcols);

ESA = ESAL.ESALS(IDOT.ZONE,:);
ESA = zeros(size(ESA,1),size(ESA,2),7);
ESA(:,:,1) = ESAL.ESALS(IDOT.ZONE,:);   % ESA(:,:,1)  COMBINED ESALS
ESA(:,:,2) = ESAL.P_COUNT(IDOT.ZONE,:); % ESA(:,:,2)  CAR    COUNTS
ESA(:,:,3) = ESAL.S_COUNT(IDOT.ZONE,:); % ESA(:,:,3)  TRUCK  COUNTS
ESA(:,:,4) = ESAL.M_COUNT(IDOT.ZONE,:); % ESA(:,:,4)  SEMI   COUNTS
ESA(:,:,5) = ESAL.P_ESAL(IDOT.ZONE,:);  % ESA(:,:,5)  CAR    ESALS
ESA(:,:,6) = ESAL.S_ESAL(IDOT.ZONE,:);  % ESA(:,:,6)  TRUCK  ESALS
ESA(:,:,7) = ESAL.M_ESAL(IDOT.ZONE,:);  % ESA(:,:,7)  SEMI   ESALS
%------------------------------

clearvars -except P TAB MAT ORIG REHAB ESAL IDOT RESAL ...
ESA ES YEAR



%% PTYPE: SURF:>CRCP |  NDES:>


PAV.CRCP = IDOT(IDOT.OSURFTYPE=="CRCP", :);
PAV.JRCP = IDOT(IDOT.OSURFTYPE=="JRCP", :);
PAV.ASPH = IDOT(IDOT.OSURFTYPE=="Full-Depth Asphalt", :);
PAV.COMP = IDOT(IDOT.OSURFTYPE=="Composite", :);
PAV.OTHR = IDOT(IDOT.OSURFTYPE=="OTHER", :);


MU(1) = nanmean(PAV.CRCP.O2R_YRS);
MU(2) = nanmean(PAV.JRCP.O2R_YRS);
MU(3) = nanmean(PAV.ASPH.O2R_YRS);
MU(4) = nanmean(PAV.COMP.O2R_YRS);
MU(5) = nanmean(PAV.OTHR.O2R_YRS);



unique(IDOT.OSURFTYPE)

% %--- GET ROWS MATCHING PTYPE
% PTY1 = 'SURF:>CRCP |  NDES:>';
% PTY2 = 'SURF:>JRCP |  NDES:>';
% PTY3 = 'SURF:>Full-Depth Asphalt |  NDES:>';
% PTY4 = 'SURF:>Composite |  NDES:>';
% PTYPE = {PTY1,PTY2,PTY3,PTY4};

DATA = {};
PT = {};





for nn = 1:5

c = contains(REHAB.REHABTYPES,PTYPE{nn});

s = nansum(REHAB.REHABINDEX(:,:,c),3);


%--- GET ORIGINAL YEAR AND FIRST REHAB DATE OF THOSE ROWS
isPTYPE = s(:,1);

OPYEAR = IDOT.OYEAR      .* isPTYPE;
RPYEAR = IDOT.RYEAR(:,1) .* isPTYPE;


%--- GET ESALS FOR THOSE ROWS BETWEEN THOSE YEARS

ROWYEARS = [OPYEAR RPYEAR  (RPYEAR - OPYEAR)];

ESALYEARS = zeros(size(ROWYEARS,1),7);

LATLON = zeros(size(ROWYEARS,1),1);

Y = YEAR;

%--- GET SUM OF EACH ESAL CATEGORY BETWEEN ORIGIN YEAR AND 1ST REHAB YEAR
for i = 1:length(OPYEAR)

    if OPYEAR(i)>0

        [a,b] = ismember(OPYEAR(i):RPYEAR(i),Y);
        ESALYEARS(i,1) = nanmean(ESA(i,b,1));
        ESALYEARS(i,2) = nanmean(ESA(i,b,2));
        ESALYEARS(i,3) = nanmean(ESA(i,b,3));
        ESALYEARS(i,4) = nanmean(ESA(i,b,4));
        ESALYEARS(i,5) = nanmean(ESA(i,b,5));
        ESALYEARS(i,6) = nanmean(ESA(i,b,6));
        ESALYEARS(i,7) = nanmean(ESA(i,b,7));
        LATLON(i,1) = nanmean(IDOT.LAT(b));

    else

        ESALYEARS(i,1) = NaN;
        ESALYEARS(i,2) = NaN;
        ESALYEARS(i,3) = NaN;
        ESALYEARS(i,4) = NaN;
        ESALYEARS(i,5) = NaN;
        ESALYEARS(i,6) = NaN;
        ESALYEARS(i,7) = NaN;

    end
end

ESAL.ESALYEARS = ESALYEARS;
ESAL.ROWYEARS  = ROWYEARS;


t1 = table(repmat(string(PTYPE{nn}),size(ROWYEARS,1),1));
t1.Properties.VariableNames = {'PTYPE'};
t2 = table(ROWYEARS(:,1),ROWYEARS(:,2),ROWYEARS(:,3));
t2.Properties.VariableNames = {'OYEAR', 'RYEAR', 'ETIME'};
t3=array2table(ESALYEARS);
t3.Properties.VariableNames = {'ESALS',...
    'COUNTS_CAR','COUNTS_TRUCK','COUNTS_SEMI',...
    'ESAL_CAR','ESAL_TRUCK','ESAL_SEMI'};



T = [t1 t2 t3];

DATA{nn} = T;

PT{nn} = T(T.OYEAR>0,:);

% LAT{nn} = XX;
end


clearvars -except P TAB MAT ORIG REHAB ESAL IDOT RESAL ...
ESA ES YEAR DATA PT PTYPE



%% PLOT: AMOUNT OF TIME TO FIRST REHAB BASED ON PAVEMENT TYPE
clc


close all
fh1 = figure('Units','normalized','OuterPosition',[.01 .06 .9 .8],'Color','w');
ax1 = axes('Position',[.1 .15 .38 .80],'Color','none');
ax2 = axes('Position',[.55 .15 .38 .80],'Color','none');



axes(ax1)

c = [...
.9 .2 .2;
.0 .9 .0;
.0 .0 .9;
.9 .1 .9;
]



for ii = 1:4
r1=rand(size(PT{ii}.ESALS)).*.3
r2=rand(size(PT{ii}.ESALS)).*.3

ph1 = scatter(PT{ii}.ESALS+r1, PT{ii}.ETIME+r2);
ph1.SizeData = 80;
% ph1.MarkerFaceColor = c(ii,:);
% ph1.MarkerEdgeColor = [0 0 0];
hold on
end
xlabel('ESALS (YEARLY MEAN)')
ylabel('YEARS BETWEEN ORIGIN AND 1ST REHAB')
lh1 = legend(ax1);
lh1.String = PTYPE;


axes(ax2)
for ii = 1:4
ph2 = scatter3(PT{ii}.COUNTS_SEMI, PT{ii}.COUNTS_CAR, PT{ii}.ETIME);
ph2.SizeData = 80;
ph2.MarkerFaceColor = c(ii,:);
ph2.MarkerEdgeColor = [0 0 0];
hold on
end
xlabel('SEMI COUNTS (YEARLY MEAN)')
ylabel('CAR COUNTS (YEARLY MEAN)')
zlabel('YEARS BETWEEN ORIGIN AND 1ST REHAB')
axis vis3d


set(fh1,'PaperPositionMode','auto')
print(['SCATTER_' IDOT.HIGHWAY(1,:)],'-dpng','-r0')




%%
f = fitlm(PT.CRCP.ETIME, PT.CRCP.ESALS);

cftool

x = PT.CRCP.ETIME;
y = PT.CRCP.ESALS;


%%
close all
bar(CRCP.ETIME)



close all
fh1 = figure('Units','normalized','OuterPosition',[.01 .06 .9 .7],'Color','w','MenuBar','none');
ax1 = axes('Position',[.05 .09 .42 .83],'Color','none');
ax2 = axes('Position',[.55 .09 .42 .83],'Color','none');


axes(ax1)
imagesc(table2array(IDOT(:,ECOLS)))
colormap(ax1,[0 0 0; parula])
ax1.YDir='normal';
ax1.XTickLabel = EYEAR(ax1.XTick);


axes(ax2)
ph1=surfl(table2array(IDOT(:,ECOLS)));
ph1.LineStyle='-';
% ph1.EdgeColor=[.9 .4 .7];
ph1.EdgeColor=[.5 .5 .5];
% ph1.EdgeColor='flat';
% ph1.EdgeColor='interp';

ph1.FaceColor = 'interp';
% ph1.FaceColor = 'texturemap';

ph1.FaceAlpha = .9;
colormap(ax2,bone)










clearvars -except FILES TAB MAT ORIG REHAB ESAL IDOT YEAR



%% GENERATE PLOTS
V = IDOT.Properties.VariableNames';
regexpStr = '((ESAL)+(\d)+)';
ESALcols = ~cellfun('isempty',regexp(V,regexpStr));
EYEAR = V(ESALcols);
EYEAR = str2num(char(regexprep(EYEAR,'ESAL','')));
AXL = IDOT{:,ESALcols};


close all;
if DOTdo
%################   TWO PACK   ################
fh1 = figure('Units','normalized','OuterPosition',[.01 .06 .9 .7],'Color','w','MenuBar','none');
ax1 = axes('Position',[.05 .09 .42 .83],'Color','none');
ax2 = axes('Position',[.55 .09 .42 .83],'Color','none');

axes(ax1)
imagesc(table2array(IDOT(:,ECOLS)))
colormap(ax1,[0 0 0; parula])
ax1.YDir='normal';
ax1.XTickLabel = EYEAR(ax1.XTick);


axes(ax2)
ph1=surfl(table2array(IDOT(:,ECOLS)));
ph1.LineStyle='-';
% ph1.EdgeColor=[.9 .4 .7];
ph1.EdgeColor=[.5 .5 .5];
% ph1.EdgeColor='flat';
% ph1.EdgeColor='interp';

ph1.FaceColor = 'interp';
% ph1.FaceColor = 'texturemap';

ph1.FaceAlpha = .9;
colormap(ax2,bone)


nr = size(IDOT,1);
if nr < 10
n=1;
elseif (nr >= 10) && (nr < 20)
n=2;
elseif (nr >= 20) && (nr < 50)
n=4;
elseif (nr >= 50) && (nr < 100)
n=6;
elseif (nr >= 100) && (nr < 300)
n=10;
else
n=20;
end




Yt = ax2.YTick;
Yt = 1:n:height(IDOT);
ax2.YTick = Yt;

Ystr = cellstr(IDOT.COUNTY)';
ax2.YTickLabel = Ystr(Yt);



EC = table2array(IDOT(:,ECOLS));
YR = EYEAR(min(IDOT.SKIPTO):end);
Xt = ax2.XTick;
X = YR(round(linspace(1,numel(YR),numel(Xt))));
ax2.XTickLabel = X;

ylabel('\fontsize{18} County')
xlabel('\fontsize{18} Year')
zlabel('\fontsize{18} ESALs')

view([-40,50])



set(fh1,'PaperPositionMode','auto')
print(['ESAL_Heatmap_' IDOT.HIGHWAY(1,:)],'-dpng','-r0')



end
%-----------------------------------------------------------------
%%                  GENERATE PLOTS
%-----------------------------------------------------------------
if IDOTdo


rx1 = '((ESAL)+(\d)+)';
VI = IDOT.Properties.VariableNames';
ICOLS = ~cellfun('isempty',regexp(VI,rx1));


close all;
%################   TWO PACK   ################
fh1 = figure('Units','normalized','OuterPosition',[.01 .06 .9 .7],'Color','w');
ax1 = axes('Position',[.05 .09 .42 .83],'Color','none');
ax2 = axes('Position',[.55 .09 .42 .83],'Color','none');

axes(ax1)
imagesc(table2array(IDOT(:,ICOLS)))
colormap(ax1,[0 0 0; parula])
ax1.YDir='normal';


axes(ax2)
ph1=surfl(table2array(IDOT(:,ICOLS)));
ph1.LineStyle='-';
% ph1.EdgeColor=[.9 .4 .7];
ph1.EdgeColor=[.5 .5 .5];
% ph1.EdgeColor='flat';
% ph1.EdgeColor='interp';

ph1.FaceColor = 'interp';
% ph1.FaceColor = 'texturemap';

ph1.FaceAlpha = .9;
colormap(ax2,bone)








end
%-----------------------------------------------------------------
%%                  GENERATE PLOTS
%-----------------------------------------------------------------
if DOTdo

V = IDOT.Properties.VariableNames';
regexpStr = '((ESAL)+(\d)+)';
ESALcols = ~cellfun('isempty',regexp(V,regexpStr));
EYEAR = V(ESALcols);
EYEAR = str2num(char(regexprep(EYEAR,'ESAL','')));
AXL = IDOT{:,ESALcols};



%% SURF ESALS X COUNTY X DATE

clc; close all
fh1 = figure('Units','pixels','Position',[10 35 1300 750],'Color','w');
ax1 = axes('Position',[.1 .06 .80 .85],'Color','none');

ph1 = surf(AXL);
title(['\fontsize{20} ' IDOT.HIGHWAY(1,:) ' \fontsize{12}  (ESALS by COUNTY and DATE)'])
axis tight;

nr = size(IDOT,1);
if nr < 10
n=1;
elseif (nr >= 10) && (nr < 20)
n=2;
elseif (nr >= 20) && (nr < 50)
n=4;
elseif (nr >= 50) && (nr < 100)
n=6;
elseif (nr >= 100) && (nr < 300)
n=10;
else
n=20;
end




Yt = ax1.YTick;
Yt = 1:n:height(IDOT);
ax1.YTick = Yt;

Ystr = cellstr(IDOT.COUNTY)';
ax1.YTickLabel = Ystr(Yt);

% Xt = ax1.XTick;
% ax1.XTickLabel = EYEAR(Xt);

EC = table2array(IDOT(:,ECOLS));
YR = EYEAR(min(IDOT.SKIPTO):end);
Xt = ax1.XTick;
X = YR(round(linspace(1,numel(YR),numel(Xt))));
ax1.XTickLabel = X;

ylabel('\fontsize{18} County')
xlabel('\fontsize{18} Year')
zlabel('\fontsize{18} ESALs')

view([-40,50])



set(fh1,'PaperPositionMode','auto')
print(['ESALS_by_COUNTY_and_DATE ' IDOT.HIGHWAY(1,:)],'-dpng','-r0')




end



%------------------------------------------------------
end  % for TAB = 1:22
%------------------------------------------------------
%% ############################################################


clc
disp('-----------------------------------')
disp(' ')
disp('FINISHED EXPORTING ALL DATA TABLES!')
disp(' ')
disp('-----------------------------------')
return


%% PLOT ON OPENMAPS
%{
wm = webmap('World Street Map', 'WrapAround', false);
wmcenter(wm,40.5,-89.0,12)


p = shaperead('usastatelo.shp','UseGeoCoords',true);
p = geoshape(p);
colors = polcmap(length(p));
wmpolygon(p,'FaceColor',colors,'FaceAlpha',.5,'EdgeColor','k', ...
      'EdgeAlpha',.5,'OverlayName','USA Boundary','FeatureName',p.Name)


I55LL = [
40.53914 -89.0171;
40.53895 -88.9572
]

p1 = wmline(wm,I55LL(:,1),I55LL(:,2),'LineWidth',3);



latlim = [39 41]
lonlim = [-90 -88]

layers = wmsfind('highway','latlim',latlim,'lonlim',lonlim);


[A,R,mapRequestURL] = wmsread(layers(1));

geoshow(A, R)

% 40.5 x -89

% USGS Topographic Imagery
% World Street Map
% Open Street Map


layers = wmsfind('highway','latlim',latlim,'lonlim',lonlim);

serverURL = 'http://basemap.nationalmap.gov/ArcGIS/services/USGSImageryOnly/MapServer/WMSServer?';
info = wmsinfo(serverURL);
orthoLayer = info.Layer(1);



close all;
imageLength = 1024;
[A, R] = wmsread(layers(7), 'Latlim', latlim, 'Lonlim', lonlim, ...
    'ImageHeight', imageLength, 'ImageWidth', imageLength);

[C, D] = wmsread(orthoLayer, 'Latlim', latlim, 'Lonlim', lonlim, ...
    'ImageHeight', imageLength, 'ImageWidth', imageLength);


figure
axesm('utm', 'Zone', utmzone(latlim, lonlim), ...
    'MapLatlimit', latlim, 'MapLonlimit', lonlim, ...
    'Geoid', wgs84Ellipsoid)

geoshow(C,D); hold on
geoshow(A,R);


%}

