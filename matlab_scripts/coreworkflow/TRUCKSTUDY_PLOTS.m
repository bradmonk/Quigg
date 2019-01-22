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
gpath = [QuiggDir ':' p1 ':' p2 ':' p3];
addpath(gpath)


clc; close all; clear;
cd(fileparts(which('TRUCKSTUDY_PLOTS.m')));




%####################################################################
%%                   GET PATHS TO MAT FILES
%####################################################################

%---------------
FILES.w = what('IDOT_MATFILES');
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

IDOT(TooShort,:) = [];


clearvars -except FILES TAB MAT ORIG REHAB ESAL IDOT YEAR





%% REMOVE ROWS (ZONES) THAT DONT HAVE 2+ REHABS


RYEAR = IDOT.RYEAR;

RYEARnan = isnan(RYEAR);

okNB = sum(~RYEARnan,2) >= 2;

IDOT(~okNB,:) = [];

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


clc;disp('---------------------------------------------------------')
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
% return
%% DETERMINE IF ANY ROWS HAVE BEEN MARKED FOR PAVEMENT REMOVAL
%{
REM = IDOT.PAVEREMOVE;

HASREM = REM == 2;

ANYREM = sum(HASREM,2)>0;


IDOT = IDOT(ANYREM,:);


rx1 = '((ESAL)+(\d)+)';
V = IDOT.Properties.VariableNames';
ECOLS = ~cellfun('isempty',regexp(V,rx1));

clearvars -except FILES TAB MAT ORIG REHAB ESAL IDOT YEAR


%}











clearvars -except FILES TAB MAT ORIG REHAB ESAL IDOT YEAR




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
clearvars -except FILES TAB MAT ORIG REHAB ESAL IDOT YEAR ES ESA



%% PTYPE: SURF:>CRCP |  NDES:>

unique(IDOT.OSURFTYPE)

%--- GET ROWS MATCHING PTYPE
PTY1 = 'SURF:>CRCP |  NDES:>';
PTY2 = 'SURF:>JRCP |  NDES:>';
PTY3 = 'SURF:>Full-Depth Asphalt |  NDES:>';
PTY4 = 'SURF:>Composite |  NDES:>';
PTYPE = {PTY1,PTY2,PTY3,PTY4};

DATA = {};
PT = {};





for nn = 1:numel(PTYPE)

c = contains(REHAB.REHABTYPES,PTYPE{nn});

s = sum(REHAB.REHABINDEX(:,:,c),3);


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




clearvars -except FILES TAB MAT ORIG REHAB ESAL IDOT YEAR...
 ES ESA DATA PT PTYPE

disp('returned'); return
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

