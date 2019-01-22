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
P.mats2 = [P.home filesep 'IDOT_MATFILES' filesep 'MAT_STEP4'];
P.figs  = [P.home filesep 'figdump'];
addpath(join(string(struct2cell(P)),':',1))
clearvars -except P




%####################################################################
%%                   LOAD STEP4 DATA
%####################################################################

load('IDOT_FORSTEP4.mat','ESAL','IDOT');

clearvars -except P IDOT ESAL






%####################################################################
%%                   ASSIGN UNIQUE ID TO EACH HIGHWAY
%####################################################################


[~,~,HIGHWAYID] = unique(IDOT.HIGHWAY);


T = IDOT(:,2);
T.Properties.VariableNames{1} = 'HWID';
T.HWID = HIGHWAYID;

IDOT = [IDOT(:,1) T  IDOT(:,2:end)];


% SORT HIGHWAY DATA TABLE BY HIGHWAY NAME THEN ZONE NUMBER
IDOT = sortrows(IDOT,{'HIGHWAY','ZONE'},{'ascend','ascend'});

clearvars -except P IDOT ESAL




%####################################################################
%%            DETERMINE ALL PAVEMENT SURFACE TYPES
%####################################################################


[OSURF,ia,ic] = unique(IDOT.OSURFTYPE);

SURFN = accumarray(ic,1);


S1 = char(num2str(SURFN));
S3 = char(OSURF);
S2 = repmat('    ',size(S3,1),1);
S = [S1 S2 S3];


disp('---------------------------------------------------------')
fprintf('Original Pavement Types \n')
disp(S)
disp('---------------------------------------------------------')



clearvars -except P IDOT ESAL

























%####################################################################
%%         TAG HIGHWAY ZONES BUILT AFTER 1999
%####################################################################

IDOT.afterY2K = IDOT.OYEAR >= 2000;


clearvars -except P IDOT ESAL REHAB



%####################################################################
%%       GROUP ORIGINAL PAVEMENT INTO N-YEAR BINS
%####################################################################

ny = 5;

minYear = min(IDOT.OYEAR);
modYear = mod(minYear,ny);
minYear = minYear - modYear;

maxYear = max(IDOT.OYEAR);
modYear = mod(maxYear,ny);
maxYear = maxYear - modYear + ny;


binYear = minYear:ny:maxYear;


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



clearvars -except P IDOT ESAL REHAB




%####################################################################
%%    DETERMINE NUMBER OF YEARS BETWEEN ORIGIN AND FIRST REHAB
%####################################################################


YRS = IDOT.RYEAR(:,1) - IDOT.OYEAR;

IDOT.O2R_YRS = YRS;


% TURN NEGATIVES INTO NAN
IDOT.O2R_YRS(IDOT.O2R_YRS < 1) = NaN;


clearvars -except P IDOT ESAL REHAB



%####################################################################
%%    MAKE HISTOGRAM OF NUMBER OF YEARS TO FIRST REHAB
%####################################################################

close all; clc;
fh1 = figure('Units','pixels','Position',[10 35 1400 700],...
    'Color','w','MenuBar','none');
ax1 = axes('Position',[.06 .06 .9 .9],'Color','none');


ph1 = histogram(IDOT.O2R_YRS);

ax1.FontSize = 16;



DISTYR = zeros(max(IDOT.O2R_YRS),1);
for nn = 1:max(IDOT.O2R_YRS)

    DISTYR(nn) = sum(IDOT.MP_DIST(IDOT.O2R_YRS == nn));

end


hold on;
plot(DISTYR)



%####################################################################
%%  COMPUTE PAVEMENT LIFETIME TO FIRST REHAB, PER ORIGIN-YEAR-BIN
%####################################################################
clc

[yx,yi,yj] = unique(IDOT.YEARBINID);
% ux = IDOT.YEARBINID(ui) ; IDOT.YEARBINID = ux(uj)

YRBIN = IDOT.YEARBIN(yi);   % YEARS WITH DATA


IDOT.OSURFTYPE(IDOT.OSURFTYPE=="Full-Depth Asphalt") = "ASPH";


% MAKE ZONES WITHOUT A SURF TYPE 'ZNA'
IDOT.OSURFTYPE(IDOT.OSURFTYPE=='') = 'ZNA';

[sx,si,sj] = unique(IDOT.OSURFTYPE);
disp([sx, accumarray(sj,1)])

SURFBIN = IDOT.OSURFTYPE(si);



% TAG SURFACE TYPES NOT IN BIG-3 AS "OTHER"
OTHR = (IDOT.OSURFTYPE~="CRCP"                 &...
        IDOT.OSURFTYPE~="JRCP"                 &...
        IDOT.OSURFTYPE~="ASPH");

IDOT.OSURFTYPE(OTHR) = "OTHER";


disp(' ')
[sx,si,sj] = unique(IDOT.OSURFTYPE);
disp([sx, accumarray(sj,1)])




MU = zeros(5,numel(YRBIN));
MU(1,:) = YRBIN;

MI = zeros(5,numel(YRBIN));
MI(1,:) = YRBIN;

NU = zeros(5,numel(YRBIN));
NU(1,:) = YRBIN;

SU = zeros(5,numel(YRBIN));
SU(1,:) = YRBIN;



for yy = 1:numel(YRBIN)

YR = YRBIN(yy);

PAV.CRCP = IDOT(IDOT.OSURFTYPE=="CRCP" & IDOT.YEARBIN==YR, :);
PAV.JRCP = IDOT(IDOT.OSURFTYPE=="JRCP" & IDOT.YEARBIN==YR, :);
PAV.ASPH = IDOT(IDOT.OSURFTYPE=="ASPH" & IDOT.YEARBIN==YR, :);
PAV.OTHR = IDOT(IDOT.OSURFTYPE=="OTHER" & IDOT.YEARBIN==YR, :);


MI(2,yy) = nanmedian(PAV.CRCP.O2R_YRS); disp(min(PAV.CRCP.O2R_YRS))
MI(3,yy) = nanmedian(PAV.JRCP.O2R_YRS); disp(min(PAV.JRCP.O2R_YRS))
MI(4,yy) = nanmedian(PAV.ASPH.O2R_YRS); disp(min(PAV.ASPH.O2R_YRS))
MI(5,yy) = nanmedian(PAV.OTHR.O2R_YRS); disp(min(PAV.OTHR.O2R_YRS))


MU(2,yy) = nanmean(PAV.CRCP.O2R_YRS); disp(min(PAV.CRCP.O2R_YRS))
MU(3,yy) = nanmean(PAV.JRCP.O2R_YRS); disp(min(PAV.JRCP.O2R_YRS))
MU(4,yy) = nanmean(PAV.ASPH.O2R_YRS); disp(min(PAV.ASPH.O2R_YRS))
MU(5,yy) = nanmean(PAV.OTHR.O2R_YRS); disp(min(PAV.OTHR.O2R_YRS))


SD(2,yy) = nanstd(PAV.CRCP.O2R_YRS); disp(min(PAV.CRCP.O2R_YRS))
SD(3,yy) = nanstd(PAV.JRCP.O2R_YRS); disp(min(PAV.JRCP.O2R_YRS))
SD(4,yy) = nanstd(PAV.ASPH.O2R_YRS); disp(min(PAV.ASPH.O2R_YRS))
SD(5,yy) = nanstd(PAV.OTHR.O2R_YRS); disp(min(PAV.OTHR.O2R_YRS))



SU(2,yy) = nansum(PAV.CRCP.MP_DIST);
SU(3,yy) = nansum(PAV.JRCP.MP_DIST);
SU(4,yy) = nansum(PAV.ASPH.MP_DIST);
SU(5,yy) = nansum(PAV.OTHR.MP_DIST);


NU(2,yy) = numel(PAV.CRCP.O2R_YRS);
NU(3,yy) = numel(PAV.JRCP.O2R_YRS);
NU(4,yy) = numel(PAV.ASPH.O2R_YRS);
NU(5,yy) = numel(PAV.OTHR.O2R_YRS);


SE(2,yy) = SD(2,yy) ./ sqrt(NU(2,yy))
SE(3,yy) = SD(3,yy) ./ sqrt(NU(3,yy))
SE(4,yy) = SD(4,yy) ./ sqrt(NU(4,yy))
SE(5,yy) = SD(5,yy) ./ sqrt(NU(5,yy))



end

STATS.MU = MU;  % MEAN
STATS.MI = MI;  % MEDIAN
STATS.NU = NU;  % NUMBER COUNT
STATS.SD = SD;  % STANDARD DEVIATION
STATS.SE = SE;  % STANDARD ERROR
STATS.SU = SU;  % SUM


clearvars -except P IDOT ESAL REHAB STATS


%####################################################################
%%   PLOT RISE AND FALL OF DIFFERENT PAVEMENT TYPES (TOTAL ZONES)
%####################################################################


Y = STATS.NU(2:4,:)'; 
Ya = find(sum(Y,2) > 0,1,'first');
Y = Y(Ya:end,:);

X = repmat(STATS.NU(1,Ya:end)',1,3);



close all; clc;
fh1 = figure('Units','pixels','Position',[10 35 1400 700],...
    'Color','w','MenuBar','none');
ax1 = axes('Position',[.06 .06 .9 .9],'Color','none');

ph1 = plot(X,Y,'LineWidth',8,'Marker','.','MarkerSize',45);
ax1.FontSize = 16;
legend('CRCP','JRCP','ASPH')


clearvars -except P IDOT ESAL REHAB STATS


%####################################################################
%%   PLOT RISE AND FALL OF DIFFERENT PAVEMENT TYPES (TOTAL MILES)
%####################################################################


Y = STATS.SU(2:4,:)'; 
Ya = find(sum(Y,2) > 0,1,'first');
Y = Y(Ya:end,:);

X = repmat(STATS.SU(1,Ya:end)',1,3);



close all; clc;
fh1 = figure('Units','pixels','Position',[10 35 1400 700],...
    'Color','w','MenuBar','none');
ax1 = axes('Position',[.06 .06 .9 .9],'Color','none');

ph1 = plot(X,Y,'LineWidth',8,'Marker','.','MarkerSize',45);
ax1.FontSize = 16;
legend('CRCP','JRCP','ASPH')



clearvars -except P IDOT ESAL REHAB STATS


%####################################################################
%%   PLOT PAVEMENT LONGETIVITY (ORIGIN ---> FIRST REHAB)
%####################################################################
clearvars -except P IDOT ESAL REHAB STATS

Y = STATS.MU(2:4,:)'; 
Ya = find(sum(Y,2) > 0,1,'first');
Y = Y(Ya:end,:);

X = repmat(STATS.MU(1,Ya:end)',1,3);

E = STATS.SE(2:4,:)';
E = E(Ya:end,:);



close all; clc;
fh1 = figure('Units','pixels','Position',[10 35 1400 700],...
    'Color','w','MenuBar','none');
ax1 = axes('Position',[.06 .06 .9 .9],'Color','none');

ph1 = plot(X,Y,'LineWidth',8,'Marker','.','MarkerSize',45);
ax1.FontSize = 16;
legend('CRCP','JRCP','ASPH')




% ph1 = bar(X,Y,'LineWidth',3);
% ax1.FontSize = 16;
% legend('CRCP','JRCP','ASPH')




% --- SUPERBAR ---------------------------------------------
 
fh1 = figure('Units','pixels','Position',[10 35 1400 700],...
    'Color','w','MenuBar','none');
hax1 = axes('Position',[.10 .10 .85 .80],'Color','none','XTick',[]); 
 
% X = [ 1 2 3 ;  
%       5 6 7]; 
%  
% Y = [14 13 12; 
%      16 15 13]; 
%  
% E = [ .8  .6  .7; 
%       .6  .5  .9]; 
%  
% C = nan(2, 3, 3); 
% C(1, 1, :) = [.99 .44 .44]; 
% C(1, 2, :) = [.44 .99 .44]; 
% C(1, 3, :) = [.22 .55 .99]; 
% C(2, 1, :) = [.88 .22 .22]; 
% C(2, 2, :) = [.44 .88 .22]; 
% C(2, 3, :) = [.11 .44 .88]; 


XG = findgroups(X(:));
 
% ph1 = superbar(X(:) , Y(:), 'E', E(:), 'BaseValue', 0,'BarEdgeColor', 'k'); 

ph1 = superbar(Y(:) , XG, 'BaseValue', 0,'BarEdgeColor', 'k'); 
 
% title('This plot requires SUPERBARS file exchange'); 
% hax1.XTick = [1 2 3 5 6 7]; 
% hax1.XTickLabel = {'A' , 'B' , 'C' , 'D' , 'E' , 'F'}; 

% Bars with errorbars
% clear;
% clf;
% Y = [11 14 13;
%      15 12 16];
% E = [ 3  4  2;
%       5  2  3];
% C = [.8 .2 .2;
%      .2 .2 .8];
superbar(Y, 'E', E,'C',jet(3));
title('Bars with errorbars');











%####################################################################
%%          DETERMINE UNIQUE COMBINATIONS OF REHABS
%####################################################################


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

SURFN = accumarray(ic,1);


disp('---------------------------------------------------------')
fprintf('Remaining rehab types for %s \n---------\n',IDOT.HIGHWAY(1,:))
disp([num2str(SURFN) char(REHABTYPES)])
disp('---------------------------------------------------------')


REHABINDEX = zeros(size(ROAD,1), size(ROAD,2), size(REHABTYPES,1));

for i = 1:size(REHABTYPES,1)

    REHABINDEX(:,:,i) = contains(ROAD,REHABTYPES{i});

end



REHAB.REHABTYPES = REHABTYPES;

REHAB.REHABINDEX = REHABINDEX;

REHAB.SURFN = SURFN;

REHAB.ROAD = ROAD;



clearvars -except P IDOT ESAL REHAB

%}



%####################################################################
%%      CALCULATE MEAN AND SUM ESALS BETWEEN ORIGIN AND REHAB#1
%####################################################################


% IDOT TABLE COLUMN 20 IS THE FIRST ESAL YEAR ON RECORD: 1955
% IDOT TABLE COLUMN 81 IS THE LAST  ESAL YEAR ON RECORD: 2016
%-----------------
V = string((IDOT.Properties.VariableNames)');
N = string(num2str((1:numel(V))'))
clc; disp([N V])
%-----------------





% CREATE TEMP TABLE 'DOT' WITHOUT ZONES WITH ZERO REHABS
%---------------------------------------------------
DOT = IDOT;

ok = DOT.RYEAR(:,1) > 1;

DOT = DOT(ok,:);








% ONLY KEEP ZONES THAT HAVE ESAL COUNTS BEFORE REHAB-1
%---------------------------------------------------

ESALYR1 = DOT.ESALYR1;

REHABYR1 = DOT.RYEAR(:,1);

ok = ESALYR1 < REHABYR1;

DOT = DOT(ok,:);


clearvars -except P IDOT ESAL REHAB DOT






% GET MEAN ESALS BETWEEN ORIGIN YEAR AND REHAB YEAR-1
%---------------------------------------------------

OYEAR = DOT.OYEAR;

RYEAR = DOT.RYEAR(:,1);


ESALCOLS = table2array(DOT(:,20:81));
ESALYEAR = [1:size(ESALCOLS,2); 1955:2016]';



for i = 1:size(OYEAR,1)

    YRS = OYEAR(i):RYEAR(i);
    [Ai,Bi] = ismember(ESALYEAR(:,2),YRS);
    ECOL = ESALYEAR(Ai,1);
    ES = ESALCOLS(i,ECOL);

    Enan = isnan(ES);
    Emu = nanmean(ES);

    Esum = ES;
    Esum(Enan) = Emu;
    Esum = sum(Esum);

    Enumnans  = sum(Enan);
    Enumesals = numel(ES);
    Epctnans  = Enumnans / Enumesals;
    


    O2R.ESALS{i} = ES;
    O2R.Emu(i)   = Emu;
    O2R.Esum(i)  = Esum;

    O2R.Enumnans(i)  = Enumnans;
    O2R.Enumesals(i) = Enumesals;
    O2R.Epctnans(i)  = Epctnans;
end

O2R.ESALS = O2R.ESALS';
O2R.Emu   = O2R.Emu';
O2R.Esum  = O2R.Esum';
O2R.Enumnans  = O2R.Enumnans';
O2R.Enumesals = O2R.Enumesals';
O2R.Epctnans  = O2R.Epctnans' .* 100;


                                % BETWEEN ORIGIN & REHAB1...
DOT.O2R_ESALS     = O2R.ESALS;      % RAW ESALS {CELL ARRAY}
DOT.O2R_EMU       = O2R.Emu;        % MEAN ESALS
DOT.O2R_ESUM      = O2R.Esum;       % SUM ESALS
DOT.O2R_ENUMNANS  = O2R.Enumnans;   % NUMBER OF CELLS CONTAINING NaNs
DOT.O2R_ENUMESAL  = O2R.Enumesals;  % NUMBER OF TOTAL CELLS
DOT.O2R_EPCTNANS  = O2R.Epctnans;   % PCT OF CELLS CONTAINING NaNs
% THE PCT OF CELLS CONTAINING NaNs IS IMPORTANT BECAUSE WHEREVER A NaN
% IS PRESENT INSTEAD OF AN ACTUAL ESAL VALUE, THE ESAL MEAN WAS USED
% TO FILL-IN THAT DATAPOINT (TO, FOR EXAMPLE COMPUTE THE ESAL SUM).


clearvars -except P IDOT ESAL REHAB DOT





%####################################################################
%%      REMOVE ZONES FROM DOT BASED ON SOME ESAL COUNT CRITERIA
%####################################################################



% REMOVE ZONES WHERE OVER 75% OF ESAL SUMS ARE FROM EXTRAPOLATED DATA
%---------------------------------------------------
ok = DOT.O2R_EPCTNANS < 75;

DOT = DOT(ok,:);




% REMOVE ZONES WITH LESS THAN 5 ESAL COUNT YEARS
%---------------------------------------------------
ok = DOT.O2R_ENUMESAL > 4;

DOT = DOT(ok,:);


clearvars -except P IDOT ESAL REHAB DOT







%####################################################################
%%    MAKE HISTOGRAM ESAL MEAN AND SUM VALUES 
%####################################################################

close all; clc;
fh1 = figure('Units','pixels','Position',[5 33 1400 700],...
    'Color','w','MenuBar','none');
ax1 = axes('Position',[.06 .06 .9 .9],'Color','none');


ph1 = histogram(DOT.O2R_EMU);
title('MEAN ESALS BETWEEN PAVEMENT ORIGIN AND FIRST REHAB')

ax1.FontSize = 16;




fh2 = figure('Units','pixels','Position',[20 65 1400 700],...
    'Color','w','MenuBar','none');
ax2 = axes('Position',[.06 .06 .9 .9],'Color','none');


ph2 = histogram(DOT.O2R_ESUM);
title('CUMULATIVE ESALS (OCCURRING BETWEEN PAVEMENT ORIGIN AND FIRST REHAB)')

ax2.FontSize = 16;




close all
fh3 = figure('Units','pixels','Position',[30 85 1400 700],...
    'Color','w','MenuBar','none');
ax3 = axes('Position',[.06 .06 .9 .9],'Color','none');

cens = (DOT.O2R_ESUM>100);
ecdf(DOT.O2R_ESUM,'censoring',cens,'bounds','on')
ph3 = ax3.Children;

ph3(1).LineWidth = 2;
ph3(2).LineWidth = 2;
ph3(3).LineWidth = 5;

hold on
xx = 0:.1:100;
yy = 1-exp(-xx/mean(DOT.O2R_ESUM));
ph4 = plot(xx,yy,'g-','LineWidth',2);

ph4.LineWidth = 5;

axis([0 100 0 1])
legend('Empirical','LCB','UCB','Theoretical Dist (Exponential)',...
       'Location','SE')

ax3.FontSize = 16;
hold off



% DISTYR = zeros(max(DOT.O2R_YRS),1);
% for nn = 1:max(DOT.O2R_YRS)
% 
%     DISTYR(nn) = sum(IDOT.MP_DIST(IDOT.O2R_YRS == nn));
% 
% end
% hold on;
% plot(DISTYR)


clearvars -except P IDOT ESAL REHAB DOT



%####################################################################
%%  PLOT CUMULATIVE ESALs BY PAVEMENT LIFETIME & OTHER METRICS
%####################################################################


close all; clc;
fh1 = figure('Units','pixels','Position',[5 20 1100 800],...
    'Color','w','MenuBar','none');
ax1 = axes('Position',[.06 .06 .9 .9],'Color','none');


ph1 = scatter(DOT.O2R_ESUM , DOT.O2R_ENUMESAL, 'filled');

axis([0 90 0 55])
title('CUMULATIVE ESALS BY PAVEMENT LIFETIME')
xlabel('Cumulative ESALS')
ylabel('Time elapsed before first rehab (Years)')

ax1.FontSize = 16;






fh2 = figure('Units','pixels','Position',[15 35 1100 800],...
    'Color','w','MenuBar','none');
ax2 = axes('Position',[.06 .06 .9 .9],'Color','none');


ph2 = scatter(DOT.O2R_EMU , DOT.O2R_ENUMESAL, 'filled');

axis([0 5 0 55])
title('AVERAGE ESALS BY PAVEMENT LIFETIME')
xlabel('Average ESALS per year')
ylabel('Time elapsed before first rehab (Years)')

ax2.FontSize = 16;













clearvars -except P IDOT ESAL REHAB DOT










%####################################################################
%%      Which rehab was pavement removed
%####################################################################
clc; clearvars -except P IDOT ESAL REHAB DOT

REROAD = REHAB.ROAD;


% REMOVAL: CONVERT REM INTO SINGLE COLUMNS OF NUMERIC VALUES
Pn = REROAD(:,4); unique(Pn)
Pa = regexp(REROAD,'Removal');
REMO = ~cellfun('isempty',Pa);

removalsPerRehab = sum(REMO);
i = find(removalsPerRehab>0,1,'last');
removalsPerRehab = removalsPerRehab(1:i);


rehabsPerRemoval = sum(REMO,2);
nMultiRemovals = numel(find(rehabsPerRemoval>1));





bar(removalsPerRehab)
title('Which rehab was pavement removed?')
ylabel('Number of zones')
xlabel('The Rehab of Pavement Removal')
ax2.FontSize = 20;



clearvars -except P IDOT ESAL REHAB DOT











return
%####################################################################
%%      BUILD DETAILED REHAB INFO TABLE
%####################################################################
clc; clearvars -except P IDOT ESAL REHAB DOT

% REHAB.REHABINDEX(1:10,1:11,1)

% [REHABTYPES,ia,ic] = unique(ROAD);

% SURFN = accumarray(ic,1);





% REMOVAL: CONVERT REM INTO SINGLE COLUMNS OF NUMERIC VALUES
Pn = RETYPES.RESPLIT(:,4); unique(Pn)
Pa = regexp(Pn,'Removal');
REMO = ~cellfun('isempty',Pa)









Ta.REHABCOUNT = REHAB.SURFN;
Ta.REHABTYPE = REHAB.REHABTYPES;
Tb = struct2table(Ta);
RETYPES = sortrows(Tb,1,'descend')

head(RETYPES,20)


REHAB.REHABINDEX(1:20,1:11,1)




% SPLIT REHAB TYPES BACK INTO [SURF, NDES, ACPG, REMOVAL]
RETYPES.RESPLIT = split(RETYPES.REHABTYPE,'|');
Pa = RETYPES.RESPLIT;


% ACPG: CONVERT ACPG INTO TWO COLUMNS OF NUMERIC VALUES
Pb = regexprep(Pa,'(  ACPG:>PG)( )+','');
Pc = regexprep(Pb,'  ACPG:< ','0-0');
Pd = regexprep(Pc,'/.+','')
Pe = regexprep(Pd,' ','')
AC = Pe(:,3)
AC = split(AC,'-');
ACPG = str2double(AC)



% NDES: CONVERT NDES INTO SINGLE COLUMNS OF NUMERIC VALUES
Pn = Pa(:,2);
Pb = regexprep(Pn,'(  NDES:< )','0');
Pb = regexprep(Pb,'(  NDES:>)','');
Pc = regexprep(Pb,' ','');
NDES = str2double(Pc)


% REMOVAL: CONVERT REM INTO SINGLE COLUMNS OF NUMERIC VALUES
Pn = RETYPES.RESPLIT(:,4); unique(Pn)
Pa = regexp(Pn,'Removal');
REMO = ~cellfun('isempty',Pa)



% CREATE A COMBINED TABLE OF THESE REHAB SUMMARY DATA
RESURF.REHABCOUNT = RETYPES.REHABCOUNT
RESURF.NDES = NDES
RESURF.ACPG = ACPG
RESURF.REMO = REMO
RESURF.REHABTYPE = RETYPES.REHABTYPE
RESURF.RESPLIT = RETYPES.RESPLIT
RESURF = struct2table(RESURF)

clearvars -except P IDOT ESAL REHAB RESURF



% IDENTIFY (TO COLLAPSE ACROSS) NON-UNIQUE COMBINATIONS OF ACPG

[ACPGa,ai,aj] = unique(RESURF.ACPG(:,1));
[ACPGb,bi,bj] = unique(RESURF.ACPG(:,2));
[ACPGc,ci,cj] = unique(RESURF.ACPG,'rows')
clc
disp('ALL UNIQUE ACPG t1:')
disp(ACPGa)
disp('ALL UNIQUE ACPG t2:')
disp(ACPGb)
disp('ALL UNIQUE ACPG t1-t2:')
disp(ACPGc)



RESURF.ACPGTYPE = cj;



% IDENTIFY (TO COLLAPSE ACROSS) NON-UNIQUE COMBINATIONS OF NDES

[NDESa,ni,nj] = unique(RESURF.NDES(:,1));
disp('ALL UNIQUE NDES:')
disp(NDESa)

RESURF.NDESTYPE = nj;



% for ij = 1:numel(ACPGc)
% RESURF(cj==ij,:)
% end

clearvars -except P IDOT ESAL REHAB RESURF



%####################################################################
%%      
%####################################################################

clc; clearvars -except P IDOT ESAL REHAB RESURF

[i,j,k] = unique(RESURF.ACPGTYPE);
ACPG = RESURF.ACPG(j,:);

[a,b,c] = unique(RESURF.NDESTYPE);
NDES = RESURF.NDES(b);


disp(' --NDES--')
disp([NDES])

disp(' --ACPG--')
disp([ACPG])


Yrs = {}; sumRehabCount = []; muYrs = [];
for i = 1:max(RESURF.ACPGTYPE)

    sumRehabCount(i) = sum(RESURF.REHABCOUNT(RESURF.ACPGTYPE == i));

    disp(['ACPG: ' num2str(ACPG(i,:))])
    disp(sumRehabCount(i))


    R = REHAB.REHABINDEX(:,:,RESURF.ACPGTYPE == i);
    R = sum(R,3)>0;

    S = IDOT.RYEAR(R);
    Yrs{i} = S(~isnan(S));

    muYrs(i) = nanmedian(Yrs{i});
 
end



[unique(RESURF.ACPG,'rows') sumRehabCount' muYrs']
Yrs



close all; clc;
fh1 = figure('Units','pixels','Position',[10 35 600 600],...
    'Color','w','MenuBar','none');
ax1 = axes('Position',[.06 .06 .9 .9],'Color','none');
ph1 = histogram(Yrs,'BinWidth',5,'NumBins',10);
ax1.FontSize = 16;



TF = (sumRehabCount>10);
TF(1) = 0;

close all; clc;
fh1 = figure('Units','pixels','Position',[10 35 600 600],...
    'Color','w','MenuBar','none');
ax1 = axes('Position',[.09 .09 .85 .85],'Color','none');
ph1 = scatter(muYrs(TF)',sumRehabCount(TF)',250,'filled');
ax1.FontSize = 16;
ax1.XLim = [1985 2015]


% 'BinCounts',Yrs,
% 'BinEdges',[1950 1960 1970 1980 1990 2000 2010 2020]




