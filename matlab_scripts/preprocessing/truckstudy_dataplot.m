%% Quigg Truck Study Data Importer
% Project Notebook URL:
% web('https://goo.gl/39cK39','-browser')
close all; clear; clc; rng('shuffle');

QuiggDir = '/Users/bradleymonk/Documents/MATLAB/Quigg';
cd(QuiggDir); p=what('Quigg'); mypath{1}=p.path;
mypath{2} = [':' p.path filesep 'quiggsubfunctions'];
mypath{3} = [':' p.path filesep 'quiggdatasets'];
addpath(cell2mat(mypath)); cd(p.path);



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


%% IMPORT ESAL DATASETS (23 TABS)

% TAB  = 3;  % To manually set I-55
% EBWB = 1;  % To manually set NB


for TAB = 1:22
for EBWB = 1:2
%%

filename = 'BMPR Pavement History (ESAL-Summary).xlsx';

[status,sheets] = xlsfinfo(filename);

disp('Loading...')
disp(sheets{TAB})

[ESALN, ~, ESALR] = xlsread(filename,sheets{TAB});



% [ESALN, ESALT, ESALR] = ESALread(filename,sheet,xlRange)
% clearvars -except ESALN ESALR




%% ORGANIZE IMPORTED ESAL DATASET


ESAL.STAT      =  string(  ESALR( 2:end-2 , 3 )  );

ESAL.ROWID     =  ESALN( 2:end-2 , 1);

ESAL.YEAR      =  ESALN( 2:end-2 , 3);

ESAL.DIST      =  ESALN( 1 , 4:end );

ESAL.CONSYEAR  =  ESALN( end-1 , 4:end );

ESAL.CONSDATE  =  ESALN( end   , 4:end );

ESAL.DATA      =  ESALN( 2:end-2 , 4:end );


clearvars -except TAB EBWB ESALN ESALR ESAL




%% PRE-PROCESS ESAL DATA


%--- Get each STAT type

[u,i,j] = unique(ESAL.STAT,'stable');

disp(u)

% u = 
%   8×1 string array
%     "3-PASS"
%     "4-P%"
%     "5-SU"
%     "6-S%"
%     "7-MU"
%     "8-M%"
%     "1-ADT"
%     "2-ADTT"




%--- Determine if ROWID and STAT are always stable pairs

[ru,ri,rj] = unique(ESAL.ROWID,'stable');

disp(ru)

% ru =
%      5
%      6
%      7
%      8
%      9
%     10
%     11
%     12

all(j == rj)  % TRUE



%--- Update corresponding identifier numbers so they make sense

ESAL.ROWID = ESAL.ROWID - 2;

ESAL.ROWID(ESAL.ROWID>=9) = ESAL.ROWID(ESAL.ROWID>=9) - 8;

disp([string(ESAL.ROWID(1:8))  ESAL.STAT(1:8)])

% ans = 
%     "3"    "3-PASS"
%     "4"    "4-P%"  
%     "5"    "5-SU"  
%     "6"    "6-S%"  
%     "7"    "7-MU"  
%     "8"    "8-M%"  
%     "1"    "1-ADT" 
%     "2"    "2-ADTT"


clearvars -except TAB EBWB ESALN ESALR ESAL


%% ORGANIZE ESAL DATA BY STAT SUBTYPE

ROWID = ESAL.ROWID;
YEAR  = ESAL.YEAR;
DATA  = ESAL.DATA;

STATA.ADT   =  DATA( ROWID == 1 , :);  % average daily traffic (PASS+SU+MU)

STATA.ADTT  =   DATA( ROWID == 2 , :);  % average daily truck traffic (SU+MU)

STATA.PASS  =   DATA( ROWID == 3 , :);  % Passenger cars per day

STATA.PPCT  =   DATA( ROWID == 4 , :);  % Pct passenger cars per day

STATA.SU    =   DATA( ROWID == 5 , :);  % Single unit trucks per day

STATA.SUPCT =   DATA( ROWID == 6 , :);  % Pct single unit trucks per day

STATA.MU    =   DATA( ROWID == 7 , :);  % Multi unit trucks per day

STATA.MUPCT =   DATA( ROWID == 8 , :);  % Pct multi unit trucks per day



SYEAR.ADT   =   YEAR( ROWID == 1 , :);  % average daily traffic (PASS+SU+MU)
SYEAR.ADTT  =   YEAR( ROWID == 2 , :);  % average daily truck traffic (SU+MU)
SYEAR.PASS  =   YEAR( ROWID == 3 , :);  % Passenger cars per day
SYEAR.PPCT  =   YEAR( ROWID == 4 , :);  % Pct passenger cars per day
SYEAR.SU    =   YEAR( ROWID == 5 , :);  % Single unit trucks per day
SYEAR.SUPCT =   YEAR( ROWID == 6 , :);  % Pct single unit trucks per day
SYEAR.MU    =   YEAR( ROWID == 7 , :);  % Multi unit trucks per day
SYEAR.MUPCT =   YEAR( ROWID == 8 , :);  % Pct multi unit trucks per day




clearvars -except TAB EBWB ESALN ESALR ESAL STATA SYEAR






%####################################################################
%%        IMPORT AND PRE-PROCESSING OF ESAL DATASET
%####################################################################
% BMPR Pavement History (Summary)
% 
% This spreadsheet contatins 46 tabs by interstate route in each direction of traffic
% 
% 
% ROWS : contain the information by distance in miles
% 
%     Row 1    : work history event 
%                Originals is when the road was first constructed
%                1st Rehab and so on are maintenance or rehabilitation events 
% 
%     Row 2    : header for columns 
% 
%     Row 3-i  : data per mile
% 
% 
% COLS : contains various categories of pavement history information
% 
% 
% 
% 
% What needs processed out of this data is as follows for each tab:
% 
%     Length 
%         Calculate the length of each section from the distance in
%         miles Subtract Column G - Column F (End Milepost - Begin Milepost)
% 
%     Age1, Age 2, etc., AgeCurrent -
%         Calculate the age per mileage at work events date (divide all
%         Ages by 365 to get value in years) Subtract the Original date
%         from the rehab date
% 
%         If the asphalt/concrete overlay thickness (in inches) column: 
%             ACOL_TOT_THK  ==  blank  |  zero  
%         skip this date as a work event (skip that Age calculation)
%
%         
%         Keep summing up the age under "Existing Pavement Treatment" 
%         states: "Pavement Removal"
%         Then start again from zero so the next age will simply be that
%         event date minus the pavement removal date.


%         
% 
%     Surf0, Surf1, Surf2, etc. - 
%         Calculate the surface for each age.
%         List the original surface type from Originals from New Pavement Type
%         column as Surf0 When a work event gets triggered, list ACOL as
%         surface for Surf1, etc., unless Pavement Removal was triggered, then
%         list surface as New HMA
% 
%     Example 
%         Original date 6/1/1980, Surf0 is CRCP 1st Rehab does not
%         trigger event since no ACOL_TOT_THK, so Age1 will be blank and Surf1
%         will be blank 2nd Rehab date 6/1/2000, so Age 2 = 20 and Surf2 =
%         ACOL 3rd Rehab date 6/1/2005 but has Pavement Removal, so Age 3 = 25
%         and Surf3 = New HMA (this will reset age to zero) 4th Rehab date is
%         6/1/2015, so Age4 = 10 and Surf4 = ACOL Current Age will = 1.5 using
%         12/31/16
%


%% IMPORT BMPR DATASETS (46 TABS)


% FIRST  LOOP DO EB/NB
% SECOND LOOP DO WB/SB

if EBWB == 1
    TABHWY = TAB*2-1;
else
    TABHWY = TAB*2;
end

%------------------

filename = 'BMPR Pavement History (Summary).xlsx';

[status,sheets] = xlsfinfo(filename);

[BMPRN, ~, BMPRR] = xlsread(filename,sheets{TABHWY});

BMPRR = BMPRR(1:size(BMPRN,1)+1,:);


clc
%% ORGANIZE BMPR DATASET


% Pavement History Excel File Column Descriptions
%{
% 
% ORIGINALS
% -------------------------------------------------------------------------
% Primary Route
% 	Highway name
% 
% 
% Concurrent Route
% 	If segment is within a concurrency, name the other route
% 
% 
% Contract
% 	Work Contract ID
% 
% 
% Suffix
% 	Contract suffix used to break out various parts of a contract containing 
%   various work activities. 
% 
% 
% Diretion (Sic)
% 	Direction of Contract: (E)ast, (W)est, (N)orth, (S)outh, (B)oth, (R)eversible
% 
% 
% Begin Mile Post
% 	Mile post following primary route; in event of concurrency where the 
%   mile posts for that route cease within the currency, this is the 
%   equivelent if it were marked along this route
% 
% 
% End Mile Post
% 	Downstream mile post
% 
% 
% DISTRICT
% 	IDOT District
% 
% 
% Type
% 	Contract type. (O) = Original; (R) = Rehab
% 
% 
% 
% Primary County	
% 	County containing the highway segment at those begin/end mileposts
% 
% 
% Secondary County	
% 	Secondary County (if applicable)
% 
% 
% Completion Date	
% 	Date contracted projected was completed
% 
%
% ADDED_LANES	
% 	If contract was rehab, were lanes added?
% 
% 
% WIDENING	
% 	If contract was rehab, were any lanes widened?
% 
% 
% LANES	
% 	Number of new lanes paved
% 
% 
% DES_YR	
% 	Design Year
% 
% 
% New Pavement Type	
% 	Pavement type (Not always applicable)
% 
% 
% Pavement Thickness	
% 	Inches
% 
% 
% Improved Subgrade Type	
% 	None Given
% 
% 
% Improved Subgrade Thickness	
% 	In inches, if applicable
% 
% 
% Mill Depth	
% 	In Inches
% 
% 
% Existing Pavement Treatment	
% 	What was done to the existing pavement during the rehab
% 
% 
% SURF_HMA_ACPG	
% 	Surface HMA PG spec
% 
% 
% SURF_HMA_NDES	
% 	HMA Surface N-design for Superpave mixes
% 
% 
% ACOL_TOT_THK	
% 	Overlay thickness in inches
% 
% 
% Comments	
% 	None Given
% 
% 
% 
% 
% REHABS
% -------------------------------------------------------------------------
% Rehab Date	
% 	None Given
% 
% 
% ADDED_LANES	
% 	If contract was rehab, were lanes added?
% 
% 
% WIDENING	
% 	If contract was rehab, were any lanes widened?
% 
% 
% LANES	
% 	Number of new lanes paved
% 
% 
% DES_YR	
% 	Design Year
% 
% 
% Contract	
% 	None Given
% 
% 
% Suffix	
% 	Contract suffix used to break out various parts of a contract 
%   containing various work activities. 
% 
% 
% Mill Depth	
% 	In inches
% 
% 
% Existing Pavement Treatment	
% 	For rehab contracts, what happened to previous pavement
% 
% 
% SURF_HMA_ACPG	
% 	Surface HMA PG spec
% 
% 
% SURF_HMA_NDES	
% 	HMA Surface N-design for Superpave mixes
% 
% 
% ACOL_TOT_THK	
% 	Overlay thickness in inches
% 
% Comments	
% 	None Given
%}


ORIG.SHEET                 =  sheets{TABHWY};
ORIG.Primary_Route         =  string(   BMPRR(3:end, 1 ));
ORIG.Concurrent_Route      =  string(   BMPRR(3:end, 2 ));
ORIG.Contract	           =  string(   BMPRR(3:end, 3 ));
ORIG.Suffix	               =  string(   BMPRR(3:end, 4 ));
ORIG.Diretion	           =  string(   BMPRR(3:end, 5 ));
ORIG.Begin_Mile_Post       =  cell2mat( BMPRR(3:end, 6 ));
ORIG.End_Mile_Post	       =  cell2mat( BMPRR(3:end, 7 ));
ORIG.DISTRICT	           =  cell2mat( BMPRR(3:end, 8 ));
ORIG.Type	               =  string(   BMPRR(3:end, 9 ));
ORIG.Primary_County	       =  string(   BMPRR(3:end, 10));
ORIG.Secondary_County      =  string(   BMPRR(3:end, 11));
ORIG.Completion_Date	   =  cell2mat( BMPRR(3:end, 12));
ORIG.ADDED_LANES	       =  string(   BMPRR(3:end, 13));
ORIG.WIDENING	           =  string(   BMPRR(3:end, 14));
ORIG.LANES	               =  cell2mat( BMPRR(3:end, 15));
ORIG.DES_YR	               =  cell2mat( BMPRR(3:end, 16));
ORIG.New_Pave_Type	       =  string(   BMPRR(3:end, 17));
ORIG.Pave_Thickness	       =  cell2mat( BMPRR(3:end, 18));
ORIG.Imprv_Subg_Type	   =  string(   BMPRR(3:end, 19));
ORIG.Imprv_Subgr_Thick	   =  cell2mat( BMPRR(3:end, 20));
ORIG.Mill_Depth	           =  cell2mat( BMPRR(3:end, 21));
ORIG.Exist_Pave_Treat	   =  string(   BMPRR(3:end, 22));
ORIG.SURF_HMA_ACPG	       =  string(   BMPRR(3:end, 23));
ORIG.SURF_HMA_NDES	       =  string(   BMPRR(3:end, 24));
ORIG.ACOL_TOT_THK	       =  string(   BMPRR(3:end, 25));
ORIG.Comments              =  string(   BMPRR(3:end, 26));


%     Length 
%         Calculate the length of each section from the distance in
%         miles Subtract Column G - Column F (End Milepost - Begin Milepost)

ORIG.Length = ORIG.End_Mile_Post - ORIG.Begin_Mile_Post;


REHAB.Rehab_Date	       =  string(BMPRR(3:end, 27:13:end));
REHAB.ADDED_LANES	       =  string(BMPRR(3:end, 28:13:end));
REHAB.WIDENING	           =  string(BMPRR(3:end, 29:13:end));
REHAB.LANES	               =  string(BMPRR(3:end, 30:13:end));
REHAB.DES_YR	           =  string(BMPRR(3:end, 31:13:end));
REHAB.Contract	           =  string(BMPRR(3:end, 32:13:end));
REHAB.Suffix	           =  string(BMPRR(3:end, 33:13:end));
REHAB.Mill_Depth	       =  string(BMPRR(3:end, 34:13:end));
REHAB.Exist_Pave_Treat	   =  string(BMPRR(3:end, 35:13:end));
REHAB.SURF_HMA_ACPG	       =  string(BMPRR(3:end, 36:13:end));
REHAB.SURF_HMA_NDES	       =  string(BMPRR(3:end, 37:13:end));
REHAB.ACOL_TOT_THK	       =  string(BMPRR(3:end, 38:13:end));
REHAB.Comments	           =  string(BMPRR(3:end, 39:13:end));


% Convert some stuff to numeric class;
REHAB.LANES                = double(REHAB.LANES);
REHAB.DES_YR               = double(REHAB.DES_YR);
REHAB.Mill_Depth           = double(REHAB.Mill_Depth);
REHAB.SURF_HMA_NDES        = double(REHAB.SURF_HMA_NDES);
REHAB.ACOL_TOT_THK         = double(REHAB.ACOL_TOT_THK);




% Clean and refactor
REHAB.Rehab_Date(ismissing(REHAB.Rehab_Date)) = "";


% Join HMA strings for SURF_HMA_ACPG & SURF_HMA_NDES
SURF1 = REHAB.SURF_HMA_ACPG;
SURF2 = string(REHAB.SURF_HMA_NDES);
x = cell(size(SURF1,1),size(SURF1,2),2);
x(:,:,1) = cellstr(SURF1);
x(:,:,2) = cellstr(SURF2);
y = string(x);

REHAB.HMA = join(y,3);



% Join HMA string above with ACOL_TOT_THK
ACOL = REHAB.ACOL_TOT_THK;

x(:,:,3) = cellstr(string(ACOL));
y = string(x);
c = cellstr(y);
c(cellfun('isempty',c)) = {'.'};
c = string(c);
OVERLAY = join(c,' | ',3);

REHAB.OVERLAY = OVERLAY;





clearvars -except TAB EBWB ESAL STATA SYEAR ORIG REHAB


%% CALCULATE DATES
clc;


% NOTE: The code below for formatting dates is a hack. I've rarely worked
% with proper datetime arrays and date representations in MATLAB/OCTAVE.
% For all I know, this could be done in a single step. If you are reading
% this message, and know a more direct implementation, please take the
% liberty to optimize the code.


% ORIG.DMYCompletion_Date
% 
% The imported excel sheets provide 2-digit years for dates. Merp.
% I'm going to add 1900 to the date string. Excel time is represented
% as a numeric value, based on the number of days since 0-Jan-1900.
% I'm going 1900 years in this conversion value to all the dates.
%
% UPDATE ON THAT: There is no such thing as 0-Jan, and it keeps
% adding two extra days during this conversion so I'm going to add
% 1900 years by adding the date "30-12-1899".
% If a date is empty, I'm going to set it to 1-Jan-1800 or "NaT"
% (Not a Time), which is like the NaN of datetime class arrays.



% Convert Dates to Proper Dates
Year1800dn = datenum('01-01-1800','dd-mm-yyyy');
Year1900dn = datenum('30-12-1899','dd-mm-yyyy');
Year1800dt = datetime(datestr(Year1800dn),'InputFormat','dd-MM-yyyy');
Year1900dt = datetime(datestr(Year1900dn),'InputFormat','dd-MM-yyyy');


ORIG.DMYCompletion_Date = datetime(datestr(ORIG.Completion_Date+Year1900dn),...
                          'InputFormat','dd-MM-yyyy');



% disp(' '); 
% disp(ORIG.DMYCompletion_Date(1:5))





% REHAB.DMYRehab_Date
% 
% There are missing values for the Rehab_Date, so I'm going to perform
% the same actions as above, except using a for-loop.


D = repmat(Year1800dt,size(REHAB.Rehab_Date));

for nn = 1:numel(REHAB.Rehab_Date)

    x = REHAB.Rehab_Date(nn);

    if (x~="") && ~ismissing(x)

        a = double(REHAB.Rehab_Date(nn)) + Year1900dn;

        b = datestr(a);

        D(nn) = datetime(b,'InputFormat','dd-MM-yyyy');

    else

        D(nn) = NaT;
        % NaT = NaN for dates

    end

end

REHAB.DMYRehab_Date = D;



% disp(' '); 
% disp(REHAB.DMYRehab_Date(1:5,1:6))


clearvars -except TAB EBWB ESAL STATA SYEAR ORIG REHAB








% 2. DETERMINE WHETHER ELAPSED-TIME SHOULD BE MARKED FOR A WORK-EVENT
%    (PAVEMENT WAS PATCHED/OVERLAID) OR WHETHER IT SHOULD BE LEFT BLANK. 
%
% 3. DETERMINE WHETHER THE ELAPSED-TIME STOPWATCH SHOULD BE RESTARTED DUE
%    TO PAVEMENT REMOVAL-AND-REPLACEMENT


% If REHAB.ACOL_TOT_THK (Pavement Overlay Thickness) is either 
% zero or NaN then elapsed-time should not be quantified for that event.

SKIP = ((REHAB.ACOL_TOT_THK == 0) | isnan(REHAB.ACOL_TOT_THK));


% If REHAB.Exist_Pave_Treat (Existing Pavement Treatment) is annotated
% as "Pavement Removal", perform both a quantification of elapsed-time
% and restart the elapsed-time stopwatch.

RESTART = strcmp(REHAB.Exist_Pave_Treat,"Pavement Removal");



REHAB.SKIP = SKIP;
REHAB.RESTART = RESTART;


% disp(' ');disp('SKIP');
% disp(SKIP(1:5, 1:4))
% 
% disp(' ');disp('RESTART');
% disp(RESTART(1:5, 1:4))






clearvars -except TAB EBWB ESAL STATA SYEAR ORIG REHAB





%% CALCULATE EQUIVALENT SINGLE AXEL LOAD

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




% ESALS = (((0.0004 * P) + (0.3940 * S) + (1.9080 * M)) *... 
%         LDF * 365) / 1,000,000




% GET TRAFFIC STATS
P = STATA.PASS;
S = STATA.SU;
M = STATA.MU;





% GET NUMBER OF LANES
clearvars -except TAB EBWB ESAL STATA SYEAR ORIG REHAB P S M
ORIGLANE = ORIG.LANES;
ADDLANES = strcmp(REHAB.ADDED_LANES,"Y");
ORIGLANES = repmat(ORIG.LANES,1,size(ADDLANES,2));
L = REHAB.LANES;
L(isnan(L)) = 0;
LANES = ORIGLANES + L;

L = LANES';





% SOMETIMES (MAYBE ALWAYS) THE NUMBER OF MILE POSTS IN THE ESAL SHEET
% DOES NOT MATCH THE MILE POST NUMBER IN THE BMPR ORIG/REHAB SHEET.
% IN THAT CASE, REPLICATE THE LAST ROW OF LANE DATA TO COMPENSATE FOR
% THE MISSING ROWS.
szP = size(P,2);
szL = size(L,2);
PLdiff = szP-szL;
L(:,end+1:end+PLdiff) = repmat(L(:,end),1,PLdiff);

clearvars -except TAB EBWB ESAL STATA SYEAR ORIG REHAB P S M L LANES PLdiff




% if TAB == 3; disp('returned'); return; end
%####################################
% GET REHAB DATES
RDATE = REHAB.DMYRehab_Date;


% SET REHAB DATES BEYOND JAN-1-2016 TO DEC-31-2015
YEARS = year(RDATE);
IS2016 = (YEARS>=2016);
RDATE(IS2016) = datetime('30-12-2015','InputFormat','dd-MM-yyyy');


% UPDATE BASED ON TRAFFIC DATA : LANE DATA DIFFERENCE
RDATES = RDATE';
RDATES(:,end+1:end+PLdiff) = repmat(RDATES(:,end),1,PLdiff);
%####################################

clearvars -except TAB EBWB ESAL STATA SYEAR ORIG REHAB P S M L LANES RDATE RDATES




% MAKE LANES (LDF) MATRIX
%     LDF = 0.45 for 4 lanes or less
%     LDF = 0.40 for 6 lanes or more (rural)
%     LDF = 0.37 for 6 lanes or more (urban) 

LDF = zeros(size(L));
LDF(L<=4) = .45;
LDF(L>=5) = .40;









% EXECUTE ESAL EQUATION
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


ESALEQ  = (...  
            ( (0.0004 .* P)+(0.3940 .* S)+(1.9080 .* M) ) .*... 
            LDF(1,1:end) .* 365 ...
          ) ./ 1000000;



YEAR = ESAL.YEAR(1:8:end);

RYEAR = year(RDATE);

DIST = ESAL.DIST';
LENG = ORIG.Length';



ESALEQ(ESALEQ==0) = NaN;



%% MATCH HIGHWAY MILE MAPS BETWEEN ESAL AND CONSTRUCTION DATASETS



HWYSTART  =  ORIG.Begin_Mile_Post;
HWYSTOP   =  ORIG.End_Mile_Post;
ESLSTART  =  DIST;


ESLxHWY = zeros(length(ESLSTART) , length(HWYSTART));

Di = zeros(size(HWYSTART));

for i = 1:length(HWYSTART)

    ESLxHWY(:,i) = (ESLSTART >= HWYSTART(i)) & (ESLSTART < HWYSTOP(i));

    Di(i) = find(ESLxHWY(:,i),1);

end

% add ones to all mile flags in ESAL that go beyond the last HWY flag...
ESLxHWY( find(ESLxHWY(:,end),1):end , end) = 1;



ESALDAT = zeros(size(ESALEQ,1),length(HWYSTART));

for i = 1:length(HWYSTART)

    j = find(ESLxHWY(:,i));

    ESALDAT(:,i) = nanmean(ESALEQ( : , j) , 2);

end






%% MAKE FINAL TABLES TABLES

HIGHWAY = repmat(ORIG.SHEET,size(HWYSTART,1),1);


% MAKE ESAL TABLE
HEADER     = [0 HWYSTART'];
EFULL      = [HEADER; YEAR ESALDAT];
EDATA      = EFULL(2:end,2:end)';
ESAL_TABLE = array2table(EDATA);

YYYY   = char(string(EFULL(2:end,1)));
YR     = repmat('YR',size(YYYY,1),1);
YRYYYY = cellstr([YR YYYY]);

ESAL_TABLE.Properties.VariableNames = YRYYYY;




% MAKE PAVEMENT TABLE
PAVE_TABLE = table(...
                HIGHWAY,...
                (1:size(HIGHWAY,1))',...
                ORIG.Begin_Mile_Post,...
                ORIG.End_Mile_Post,...
                ORIG.Length,...
                LANES,...
                year(ORIG.DMYCompletion_Date),...
                RYEAR,...
                ORIG.New_Pave_Type,...
                ORIG.Pave_Thickness,...
                REHAB.OVERLAY,...
                cellstr(REHAB.Exist_Pave_Treat),...
                REHAB.SKIP,...
                REHAB.RESTART);


PAVE_TABLE.Properties.VariableNames =...
                {...
                'HIGHWAY',...
                'MP',...
                'MP_START',...
                'MP_END',...
                'MP_DIST',...
                'LANES',...
                'WORK_YR_0',...
                'WORK_YR',...
                'SURF_O',...
                'SURF_O_THICK',...
                'SURF_RE',...
                'SURF_RE_TYPE',...
                'SKIP',...
                'RESET',...
                 };







%% MAKE COMBINED PAVEMENT-ESAL TABLE

PAVE_ESAL = [PAVE_TABLE(:,1:5)  ESAL_TABLE  PAVE_TABLE(:,6:end)];


clearvars -except TAB EBWB PAVE_ESAL HIGHWAY







%#################################################
%%          COMPUTE PAVEMENT AGE
%#################################################
% if TAB == 3; disp('return (line 1002)'); return; end

T = PAVE_ESAL;
ORIG_YR = T.WORK_YR_0;
REHAB_YR = T.WORK_YR;
CURRENT_YR = zeros(size(ORIG_YR)) + 2016;
SKIP_YR = T.SKIP;
REHAB_YR(SKIP_YR) = NaN;
YEARS = [ORIG_YR REHAB_YR CURRENT_YR];

AGE = zeros(size(YEARS));

YEARS(isnan(YEARS)) = 0;

r = size(AGE,1);
c = size(AGE,2);
for i = 1:r
for j = 1:c

    m = r-i+1;
    n = c-j+1;

    B=0;
    if YEARS(m,n) ~=0
    

        A = YEARS(m,n);

        [~,~,v] = find(YEARS(m,1:n-1),1,'last');

        if ~isempty(v)

            B = A - v;

        end

    end

    AGE(m,n) = B;


end
end


AGE(AGE==0) = NaN;


PAVE_ESAL.AGE = AGE;




clearvars -except TAB EBWB PAVE_ESAL HIGHWAY












%%  COMPUTE ESAL COUNT FOR EACH AGE MEASUREMENT



T = PAVE_ESAL;
ORIG_YR = T.WORK_YR_0;
REHAB_YR = T.WORK_YR;
CURRENT_YR = zeros(size(ORIG_YR)) + 2016;
SKIP_YR = T.SKIP;
REHAB_YR(SKIP_YR) = NaN;
YEARS = [ORIG_YR REHAB_YR CURRENT_YR];


ESALave = zeros(size(YEARS));
ESALsum = zeros(size(YEARS));

YEARS(isnan(YEARS)) = 0;

AGE = PAVE_ESAL.AGE;

clc
clearvars -except TAB EBWB PAVE_ESAL ESALave ESALsum YEARS AGE HIGHWAY







ESAL = PAVE_ESAL(:,6:67);
ESAL = table2array(ESAL);
Ys = 1955:2016;


r = size(ESALsum,1);
c = size(ESALsum,2);
for i = 1:r
for j = 1:c

    m = r-i+1;
    n = c-j+1;

    B=0;
    if AGE(m,n) ~=0
    

        A = YEARS(m,n);

        [~,~,v] = find(YEARS(m,1:n-1),1,'last');

        if ~isempty(v)


            x = find(Ys == v);
            y = find(Ys == A);

            Eave = nanmean(ESAL(m,x:y));

            Esum = Eave .* numel(ESAL(m,x:y));

        end

    end

    ESALave(m,n) = Eave;
    ESALsum(m,n) = Esum;


end
end

% NESAL(AGE==0) = NaN;


PAVE_ESAL.ESALave = ESALave;
PAVE_ESAL.ESALsum = ESALsum;

% CODE ABOVE SETS ESAL0=ESAL1; BUT NO TIME ELAPSES @ESAL0; MAKE ESAL0=NaN
PAVE_ESAL.ESALave(:,1) = NaN;
PAVE_ESAL.ESALsum(:,1) = NaN;


clearvars -except TAB EBWB PAVE_ESAL HIGHWAY



%% CREATE TABLE OF JUST THE ESSENTAILS

HWYDATA = PAVE_ESAL(:,[1:5 71 72 73 77 79 78 69 70]);

HWYDATA.Properties.VariableNames =...
                {...
                'HIGHWAY',...
                'MP',...
                'MP_START',...
                'MP_END',...
                'MP_DIST',...
                'SURF_0',...
                'SURF_0_THK',...
                'SURF',...
                'AGE',...
                'ESALs',...
                'ESALm',...
                'WORKYR_0',...
                'WORKYR',...
                 };



% CAT ORIGINAL SURF TYPE & THICKNESS
%   HWYDATA.SURF_0
%   HWYDATA.SURF_0_THK

SURF1 = HWYDATA.SURF_0;
SURF2 = string(HWYDATA.SURF_0_THK);

x = cell(size(SURF1,1),size(SURF1,2),3);
x(:,:,1) = cellstr(SURF1);
x(:,:,2) = cellstr("|");
x(:,:,3) = cellstr(SURF2);
y = string(x);

SURF_0 = join(y,3);

HWYDATA.SURF_0 = SURF_0;

HWYDATA.SURF_0_THK = [];















%% WRITE TABLES TO AN EXCEL SHEET NAMED-TAB



% h=pwd; cd([h filesep 'csvtables'])
% writetable(PAVE_ESAL ,  [HIGHWAY(1,:) '.csv'])
% writetable(PAVE_ESAL,'REHAB_ESAL.xlsx','Sheet',HIGHWAY(1,:));
% writetable(HWYDATA,'HWYDATA.xlsx','Sheet',HIGHWAY(1,:));
% cd(h)
%%

disp(HIGHWAY(1,:))
if strcmp(HIGHWAY(1,:),'I-55 NB')
return

ESAL = PAVE_ESAL(:,6:67);
ESAL = table2array(ESAL);


clc; close all;
fh1 = figure('Units','normalized','Position',[.05 .04 .9 .9],'Color','w');
ax1 = axes('Position',[.06 .06 .9 .9],'Color','none');


ph1 = surf(ESAL);

% ax1.XLim = [1 numel(1955:2016)]
ax1.XTick = 1:5:numel(1955:2016);
ax1.XTickLabel = [1956:5:2016]



end






%% ------------------------------------------------------
end  % for EBWB = 1:2 
%------------------------------------------------------

% if TAB == 3; disp('return line 1225'); return; end

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


