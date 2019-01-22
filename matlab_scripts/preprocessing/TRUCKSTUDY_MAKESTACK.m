%% Quigg Truck Study Data Post Processing
% Project Notebook URL:
% web('https://goo.gl/39cK39','-browser')
close all; clear; clc; rng('shuffle');

QuiggDir = '/Users/bradleymonk/Documents/MATLAB/Quigg';
cd(QuiggDir); p=what('Quigg'); mypath{1}=p.path;
mypath{2} = [':' p.path filesep 'quiggsubfunctions'];
mypath{3} = [':' p.path filesep 'quiggdatasets'];
addpath(cell2mat(mypath)); cd(p.path);



% /Users/bradleymonk/Documents/MATLAB/Quigg/generated_datasets/BMPR_ESAL.xlsx
% /Users/bradleymonk/Documents/MATLAB/Quigg/generated_datasets/PAVEMENT.xlsx


%%
%{
Matt?s Notes


Service Life of ?Pavement? ? Years & ESALS 
---------------
To determine LIFE (years) and ESALS (single axel loads) requires...
TIME     (a calculation)
PAVEMENT (from BMPR_Pavement_History)
ESALS    (from BMPR_Pavement_History_ESAL)



Time ? service life of: 
---------------
a) 	original pavement (AA minus L) 
b) 	1st rehab (AN minus AA) 
c) 	2nd rehab (BA minus AN) 
d) 	Etc
 


L ? Completion Date
---------------
AA ? Rehab Date (1st rehab)
AN ? Rehab Date (2nd rehab)
BA ? Rehab Date (3rd rehab)
BN ? Rehab Date (4th rehab)
CA ? Rehab Date (5th rehab)
CN ? Rehab Date (6th rehab)
DA ? Rehab Date (7th rehab)
DN ? Rehab Date (8th rehab)
EA ? Rehab Date (9th rehab)
EN ? Rehab Date (10th rehab)
FA ? Rehab Date (11th rehab)
 
 
Pavement Type ? Q
---------------
Q ? New Pavement Type
AJ ? 1st Rehab pavement type ? (HMA Overlay ? any listing for ?PG?)
AW ? 2 nd Rehab pavement type ? (HMA Overlay ? any listing for ?PG?)
BJ ? 3 th Rehab pavement type ? (HMA Overlay ? any listing for ?PG?)
BW ? 4 th Rehab pavement type ? (HMA Overlay ? any listing for ?PG?)
CJ ? 5 th Rehab pavement type ? (HMA Overlay ? any listing for ?PG?)
CX ? 6 th Rehab pavement type ? (HMA Overlay ? any listing for ?PG?)
DJ ? 7 th Rehab pavement type ? (HMA Overlay ? any listing for ?PG?)
DW ? 8 th Rehab pavement type ? (HMA Overlay ? any listing for ?PG?)
EJ ? 9 th Rehab pavement type ? (HMA Overlay ? any listing for ?PG?)
EW ? 10 th Rehab pavement type ? (HMA Overlay ? any listing for ?PG?)
FJ ? 11 th Rehab pavement type ? (HMA Overlay ? any listing for ?PG?)
 
 
3 Pavement Types 
---------------
CRCP
Thickened Edge JRCP
JRCP
Hinge-Jointed
JPCP

 
Full-Depth HMA
---------------
Full-Depth Asphalt
 
HMA Overlay
---------------
Composite




%}
%%


%% IMPORT EXCEL SHEETS
% for XLi = 1:22
% for XLj = 1:2
XLi = 1;
XLj = 1;


XLSFILENAME = 'PROCESSED_DATA_EXPANDED.xlsx';
% XLSFILENAME = 'PROCESSED_DATA.xlsx';
[status,XS] = xlsfinfo(XLSFILENAME);
% [status,sheets] = xlsfinfo('PROCESSED_DATA.xlsx');



if XLj == 1
    XLij = XLi*2-1;
else
    XLij = XLi*2;
end


disp('Loading...')
disp(XS{XLij})

[XLSN, XLST, XLSR] = xlsread(XLSFILENAME,XS{XLij});


% [T] = readtable('HWYDATA.xlsx');
% T.Properties.VariableDescriptions{16}
% ESALR(1,:)'
% char(string(T.Properties.VariableNames)')

NANCOLS = isnan(XLSN(1,:));


ESAL = cell2table(XLSR(2:end,:));


colnames = XLSR(1,:);
colnames = regexprep(colnames,' ','');
ESAL.Properties.VariableNames=colnames;

clearvars -except XLi XLj XLij XS ESAL 



%% PLOT AVERAGE AGE
clc;

% FIND COLUMNS THAT BEGIN WITH "WORK_YR_" 
v = ESAL.Properties.VariableNames;
v = string(v)';
r = regexp(v,'(WORK).+');
c = ~cellfun(@isempty,r);


AGE = cell2mat(table2cell(ESAL(:,c)));

AGEmu = nanmean(AGE);
AGEsd = nanstd(AGE);
AGEse = AGEsd./sqrt(sum(~isnan(AGE)));

ok = ~isnan(AGEmu);
AGEmu = AGEmu(ok);
AGEsd = AGEsd(ok);
AGEse = AGEse(ok);


YR1=AGE;
YR1(:,end)=[];
YR2 = circshift(AGE,[0 -1]);
YR2(:,end)=[];

DURA = YR2-YR1;

DURAmu = nanmean(DURA);
DURAsd = nanstd(DURA);
DURAse = DURAsd./sqrt(sum(~isnan(DURA)));

ok = ~isnan(DURAmu);
DURAmu = DURAmu(ok);
DURAsd = DURAsd(ok);
DURAse = DURAse(ok);



for i=1:size(DURA,1)/10
j=10*i-9;
    DURAS(i,:) = nanmean(DURA(j:j+10,:));
end

DURASmu = nanmean(DURAS);
DURASsd = nanstd(DURAS);
DURASse = DURASsd./sqrt(sum(~isnan(DURAS)));

ok = ~isnan(DURASmu);
DURASmu = DURASmu(ok);
DURASsd = DURASsd(ok);
DURASse = DURASse(ok);








%% ################   TWO PACK   ################
clc; close all;
fh1 = figure('Units','normalized','OuterPosition',[.14 .06 .9 .7],...
    'Color','w','MenuBar','none');
ax1 = axes('Position',[.05 .09 .42 .83],'Color','none');
ax2 = axes('Position',[.55 .09 .42 .83],'Color','none');


axes(ax1)
C = [.4 .4 .4];
CE = [.5 .1 .5];
superbar(DURAmu, 'BarFaceColor', C, 'E', DURAse, 'ErrorbarColor', CE);
title([XS{XLij} ': Average Years Between Major Rehabs'])
ylabel('Years'); xlabel('Rehab')

axes(ax2)
imagesc(DURAS)
c=colorbar('westoutside');
c.Label.String = 'Years Between Major Rehabs';


set(gcf,'PaperPositionMode','auto')
print(['YR_' XS{XLij}],'-dpng','-r0')
print(['YR_' XS{XLij}],'-depsc','-tiff')

pause(1)

%% ################   TWO PACK   ################
clc; close all;
fh1 = figure('Units','normalized','OuterPosition',[.14 .06 .9 .7],...
    'Color','w','MenuBar','none');
ax1 = axes('Position',[.05 .09 .85 .83],'Color','none');


bh1 = bar(nanmean(DURAS,2),.90);
title([XS{XLij} ': Average Years Between Major Rehabs'])
ylabel('Years'); xlabel('Mile Post')
ax1.XTickLabel = str2num(char(string(ax1.XTickLabel))).*10;


set(gcf,'PaperPositionMode','auto')
print(['MP_' XS{XLij}],'-dpng','-r0')
print(['MP_' XS{XLij}],'-depsc','-tiff')

pause(1)



end
end
%%




















