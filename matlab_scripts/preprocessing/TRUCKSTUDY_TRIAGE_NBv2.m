%% Quigg Truck Study Data Importer
% Project Notebook URL:
% web('https://goo.gl/39cK39','-browser')

clc; close all; clear;
QuiggDir = '/Users/bradleymonk/Documents/MATLAB/Quigg';
cd(QuiggDir)

subfuncpath = [QuiggDir '/quiggsubfunctions'];
datasetpath = [QuiggDir '/generated_datasets'];
gpath = [QuiggDir ':' subfuncpath ':' datasetpath];
addpath(gpath)


clc; close all; clear;
cd(fileparts(which('TRUCKSTUDY_TRIAGE_V1.m')));


%####################################################################
%%        IMPORT AND PRE-PROCESSING OF ESAL DATASET
%####################################################################
%{
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
%}

%% IMPORT ESAL DATASETS (23 TABS)

for TAB = 3:22

filename = 'IDOT.xlsx';

[status,sheets] = xlsfinfo(filename);

disp('Loading...')
disp(sheets{TAB})

[ESALN, ~, ESALR] = xlsread(filename,sheets{TAB});


%% ORGANIZE IMPORTED ESAL DATASET


ESAL.STAT      =  string(  ESALR( 2:end-2 , 3 )  );

ESAL.ROWID     =  ESALN( 2:end-2 , 1);

ESAL.YEAR      =  ESALN( 2:end-2 , 3);

ESAL.DIST      =  ESALN( 1 , 4:end );

ESAL.CONSYEAR  =  ESALN( end-1 , 4:end );

ESAL.CONSDATE  =  ESALN( end   , 4:end );

ESAL.DATA      =  ESALN( 2:end-2 , 4:end );


clearvars -except TAB EBWB ESALN ESALR ESAL NBIDOT SBIDOT




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


clearvars -except TAB EBWB ESALN ESALR ESAL NBIDOT SBIDOT


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




clearvars -except TAB EBWB ESALN ESALR ESAL STATA SYEAR NBIDOT SBIDOT



%####################################################################
%%        IMPORT AND PRE-PROCESSING OF ESAL DATASET
%####################################################################
%{
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
%}

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



ACCORDING TO MAT WE DONT NEED
a) Pavement thickness
b) Orig mill depth
c) Rehab mill depth
d) By PG grade ? a little explanation here.  This column splits out 
   the grades (some performance characteristics) of the liquid asphalt used
e) NDES ? this is how many gyrations it was designed for (an indication 
   of rutting resistance)
f) Thickness
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





%--- Join HMA strings for SURF_HMA_ACPG & SURF_HMA_NDES
% fillmissing(cellstr(REHAB.SURF_HMA_ACPG),'constant',"NA")
% SURF_HMA_ACPG = fillmissing(REHAB.SURF_HMA_ACPG,'constant',"NA");


VALS = REHAB.SURF_HMA_ACPG;
LABS = repmat(" ACPG:",size(VALS));
x = cell(size(VALS,1),size(VALS,2),2);
x(:,:,1) = cellstr(LABS);
x(:,:,2) = cellstr(VALS);
y = string(x);
HMA.ACPG = join(y,3);
HMA.ACPG = regexprep(HMA.ACPG,' ACPG: (.)',' ACPG:*$1');
HMA.ACPG = regexprep(HMA.ACPG,' ACPG: ',' ACPG:?');



VALS = string(REHAB.SURF_HMA_NDES);
LABS = repmat(" NDES:",size(VALS));
x = cell(size(VALS,1),size(VALS,2),2);
x(:,:,1) = cellstr(LABS);
x(:,:,2) = cellstr(VALS);
y = string(x);
HMA.NDES = join(y,3);
HMA.NDES = regexprep(HMA.NDES,' NDES: (.)',' NDES:*$1');
HMA.NDES = regexprep(HMA.NDES,' NDES: ',' NDES:?');




VALS = REHAB.Exist_Pave_Treat;
LABS = repmat(" REM:",size(VALS));
x = cell(size(VALS,1),size(VALS,2),2);
x(:,:,1) = cellstr(LABS);
x(:,:,2) = cellstr(VALS);
y = string(x);
HMA.REM = join(y,3);
HMA.REM = regexprep(HMA.REM,' REM: (.)',' REM:*$1');
HMA.REM = regexprep(HMA.REM,' REM: ',' REM:?');





% Join HMA string above with ACOL_TOT_THK
x = cell(size(VALS,1),size(VALS,2),3);
x(:,:,3) = cellstr(HMA.REM);
x(:,:,2) = cellstr(HMA.ACPG);
x(:,:,1) = cellstr(HMA.NDES);
x = string(x);
OVERLAY = join(x,' | ',3);


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



%% COMPLICATED SKIP RESTART CODE
%{

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
%}




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

clearvars -except TAB EBWB ESAL STATA SYEAR ORIG REHAB...
 P S M L LANES PLdiff




% if TAB == 3; disp('returned'); return; end
%####################################
% GET REHAB DATES
RDATE = REHAB.DMYRehab_Date;


%% SET REHAB DATES BEYOND JAN-1-2016 TO DEC-31-2015
YEARS = year(RDATE);
IS2016 = (YEARS>=2016);
RDATE(IS2016) = datetime('30-12-2015','InputFormat','dd-MM-yyyy');


% UPDATE BASED ON TRAFFIC DATA : LANE DATA DIFFERENCE
RDATES = RDATE';
RDATES(:,end+1:end+PLdiff) = repmat(RDATES(:,end),1,PLdiff);
%####################################

clearvars -except TAB EBWB ESAL STATA SYEAR ORIG REHAB...
 P S M L LANES RDATE RDATES




%% MAKE LANES (LDF) MATRIX
%     LDF = 0.45 for 4 lanes or less
%     LDF = 0.40 for 6 lanes or more (rural)
%     LDF = 0.37 for 6 lanes or more (urban) 

LDF = zeros(size(L));
LDF(L<=4) = .45;
LDF(L>=5) = .40;









%% EXECUTE ESAL EQUATION
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


PESAL  = (...  
            ( (0.0004 .* P) ) .*... 
            LDF(1,1:end) .* 365 ...
          ) ./ 1000000;

SESAL  = (...  
            ( (0.3940 .* S) ) .*... 
            LDF(1,1:end) .* 365 ...
          ) ./ 1000000;

MESAL  = (...  
            ( (1.9080 .* M) ) .*... 
            LDF(1,1:end) .* 365 ...
          ) ./ 1000000;



% YEAR = ESAL.YEAR(1:8:end);
% RYEAR = year(RDATE);

DIST = ESAL.DIST';
LENG = ORIG.Length';



ESALEQ(ESALEQ==0) = NaN;


ESAL.ESALS = ESALEQ;

ESAL.P_COUNT  = P;
ESAL.S_COUNT  = S;
ESAL.M_COUNT  = M;

ESAL.P_ESAL  = PESAL;
ESAL.S_ESAL  = SESAL;
ESAL.M_ESAL  = MESAL;



clearvars -except TAB EBWB ESAL ORIG REHAB DIST



%% CREATE COHESIVE SET OF STRUCTURAL ARRAYS

HWYSTART  =  ORIG.Begin_Mile_Post;
HWYSTOP   =  ORIG.End_Mile_Post;
ESLSTART  =  DIST;



[i,j] = ismember(ESLSTART,HWYSTART);

ESAL.DIST       = ESAL.DIST(:,i)';
ESAL.CONSYEAR   = ESAL.CONSYEAR(:,i)';
ESAL.CONSDATE   = ESAL.CONSDATE(:,i)';
ESAL.DATA       = ESAL.DATA(:,i)';
ESAL.ESALS      = ESAL.ESALS(:,i)';

ESAL.P_COUNT     = ESAL.P_COUNT(:,i)';
ESAL.S_COUNT     = ESAL.S_COUNT(:,i)';
ESAL.M_COUNT     = ESAL.M_COUNT(:,i)';
ESAL.P_ESAL      = ESAL.P_ESAL(:,i)';
ESAL.S_ESAL      = ESAL.S_ESAL(:,i)';
ESAL.M_ESAL      = ESAL.M_ESAL(:,i)';



[i,j] = ismember(HWYSTART,ESLSTART);


         ORIG.Primary_Route = ORIG.Primary_Route(i,:);
      ORIG.Concurrent_Route = ORIG.Concurrent_Route(i,:);
              ORIG.Contract = ORIG.Contract(i,:);
                ORIG.Suffix = ORIG.Suffix(i,:);
              ORIG.Diretion = ORIG.Diretion(i,:);
       ORIG.Begin_Mile_Post = ORIG.Begin_Mile_Post(i,:);
         ORIG.End_Mile_Post = ORIG.End_Mile_Post(i,:);
              ORIG.DISTRICT = ORIG.DISTRICT(i,:);
                  ORIG.Type = ORIG.Type(i,:);
        ORIG.Primary_County = ORIG.Primary_County(i,:);
      ORIG.Secondary_County = ORIG.Secondary_County(i,:);
       ORIG.Completion_Date = ORIG.Completion_Date(i,:);
           ORIG.ADDED_LANES = ORIG.ADDED_LANES(i,:);
              ORIG.WIDENING = ORIG.WIDENING(i,:);
                 ORIG.LANES = ORIG.LANES(i,:);
                ORIG.DES_YR = ORIG.DES_YR(i,:);
         ORIG.New_Pave_Type = ORIG.New_Pave_Type(i,:);
        ORIG.Pave_Thickness = ORIG.Pave_Thickness(i,:);
       ORIG.Imprv_Subg_Type = ORIG.Imprv_Subg_Type(i,:);
     ORIG.Imprv_Subgr_Thick = ORIG.Imprv_Subgr_Thick(i,:);
            ORIG.Mill_Depth = ORIG.Mill_Depth(i,:);
      ORIG.Exist_Pave_Treat = ORIG.Exist_Pave_Treat(i,:);
         ORIG.SURF_HMA_ACPG = ORIG.SURF_HMA_ACPG(i,:);
         ORIG.SURF_HMA_NDES = ORIG.SURF_HMA_NDES(i,:);
          ORIG.ACOL_TOT_THK = ORIG.ACOL_TOT_THK(i,:);
              ORIG.Comments = ORIG.Comments(i,:);
                ORIG.Length = ORIG.Length(i,:);
    ORIG.DMYCompletion_Date = ORIG.DMYCompletion_Date(i,:);



          REHAB.Rehab_Date = REHAB.Rehab_Date(i,:);
         REHAB.ADDED_LANES = REHAB.ADDED_LANES(i,:);
            REHAB.WIDENING = REHAB.WIDENING(i,:);
               REHAB.LANES = REHAB.LANES(i,:);
              REHAB.DES_YR = REHAB.DES_YR(i,:);
            REHAB.Contract = REHAB.Contract(i,:);
              REHAB.Suffix = REHAB.Suffix(i,:);
          REHAB.Mill_Depth = REHAB.Mill_Depth(i,:);
    REHAB.Exist_Pave_Treat = REHAB.Exist_Pave_Treat(i,:);
       REHAB.SURF_HMA_ACPG = REHAB.SURF_HMA_ACPG(i,:);
       REHAB.SURF_HMA_NDES = REHAB.SURF_HMA_NDES(i,:);
        REHAB.ACOL_TOT_THK = REHAB.ACOL_TOT_THK(i,:);
            REHAB.Comments = REHAB.Comments(i,:);
                 REHAB.HMA = REHAB.HMA(i,:);
             REHAB.OVERLAY = REHAB.OVERLAY(i,:);
       REHAB.DMYRehab_Date = REHAB.DMYRehab_Date(i,:);




clearvars -except TAB EBWB ESAL ORIG REHAB
%-----------------------------------------------------------------
%%                  MAKE FINAL TABLES
%-----------------------------------------------------------------
clc



%------ MAKE PAVEMENT SUMMARY TABLE ---------
clear IDOT DOT
IDOT.HIGHWAY     = repmat(ORIG.SHEET,size(ORIG.Primary_Route));
IDOT.ZONE        = (1:size(ORIG.Primary_Route,1))';
IDOT.COUNTY      = ORIG.Primary_County;
IDOT.MP_START    = ORIG.Begin_Mile_Post;
IDOT.MP_END      = ORIG.End_Mile_Post;
IDOT.MP_DIST     = ORIG.Length;
IDOT.OLANES      = ORIG.LANES;
IDOT.OSURFTYPE   = ORIG.New_Pave_Type;
IDOT.OSURFTHICK  = ORIG.Pave_Thickness;
IDOT.OYEAR       = year(ORIG.DMYCompletion_Date);
IDOT.RYEAR       = year(REHAB.DMYRehab_Date); % RYEAR;
% IDOT.RREPAVE     = cellstr(REHAB.Exist_Pave_Treat);
% IDOT.RACPG       = cellstr(REHAB.SURF_HMA_ACPG);
% IDOT.RNDES       = REHAB.SURF_HMA_NDES;
IDOT.REHAB       = cellstr(REHAB.OVERLAY);


DOT = struct2table(IDOT);


%------ MAKE ESAL SUMMARY TABLE -------
ESAL_TABLE = array2table(ESAL.ESALS);

YEAR = char(string(ESAL.YEAR(1:8:end)));
YR = repmat('ESAL',size(YEAR,1),1);
YEARLABELS = cellstr([YR YEAR]);

ESAL_TABLE.Properties.VariableNames = YEARLABELS;






% ------------- FINAL TABLE IS NAMED IDOT ------------------
clear IDOT
IDOT = [DOT ESAL_TABLE];






clearvars -except TAB EBWB ORIG REHAB ESAL IDOT YEAR

%%

% Vars = char(fieldnames(REHAB));
% disp(Vars)
% REHAB.LANES = fillmissing(REHAB.LANES,'constant',0);
% REHAB.DES_YR = fillmissing(REHAB.DES_YR,'constant',0);
% REHAB.Mill_Depth = fillmissing(REHAB.Mill_Depth,'constant',0);
% REHAB.SURF_HMA_NDES = fillmissing(REHAB.SURF_HMA_NDES,'constant',0);
% REHAB.ACOL_TOT_THK = fillmissing(REHAB.ACOL_TOT_THK,'constant',0);
% DT = datetime(datestr(datenum('2020','yyyy')),'InputFormat','dd-MM-yyyy');
% REHAB.DMYRehab_Date = fillmissing(REHAB.DMYRehab_Date,'constant',DT);
% REHAB.YEAR = year(REHAB.DMYRehab_Date);
% 
% 
% unique(REHAB.Rehab_Date      )
% unique(REHAB.ADDED_LANES     )
% unique(REHAB.WIDENING        )
% unique(REHAB.LANES           )
% unique(REHAB.DES_YR          )
% unique(REHAB.Contract        )
% unique(REHAB.Suffix          )
% unique(REHAB.Mill_Depth      )
% unique(REHAB.Exist_Pave_Treat)
% unique(REHAB.SURF_HMA_ACPG   )
% unique(REHAB.SURF_HMA_NDES   )
% unique(REHAB.ACOL_TOT_THK    )
% unique(REHAB.Comments        )
% unique(REHAB.HMA             )
% unique(REHAB.OVERLAY         )
% unique(REHAB.DMYRehab_Date   )
% unique(REHAB.YEAR            )














%% ASSIGN LAT/LONG COORDINATES TO COUNTIES


T = readtable('/Users/bradleymonk/Documents/MATLAB/Quigg/generated_datasets/IL_LATLON_COUNTY.csv');

T = sortrows(T,'COUNTY');

[C,i,j] = unique(T.COUNTY);

COUNTYj = accumarray(j,1);% > 1;

nC = size(C,1);

LL = zeros(nC,2);

muLAT = nanmean(T.LAT);
muLON = nanmean(T.LON);

for i = 1:nC

    LAT = nanmean(T.LAT(j==i));
    LON = nanmean(T.LON(j==i));
    

    LL(i,1) = LAT;
    LL(i,2) = LON;
    
end


[C,i,j] = unique(T.COUNTY);

LATLON = T(i,:);
LATLON.CITY = [];

LATLON.LAT = LL(:,1);
LATLON.LON = LL(:,2);



clearvars -except TAB EBWB ORIG REHAB ESAL IDOT YEAR LATLON

DOT = IDOT;
DOT.COUNTY = regexprep(DOT.COUNTY,' ','');
LATLON.COUNTY = regexprep(LATLON.COUNTY,' ','');
DOT.COUNTY = regexprep(DOT.COUNTY,'\.','');
LATLON.COUNTY = regexprep(LATLON.COUNTY,'\.','');

DT = DOT(:,1:3);


COUNTY = string(LATLON.COUNTY);

[Ai,Bi] = ismember(DT.COUNTY,COUNTY);
all(Ai)


LLC = LATLON(Bi(Ai),:);


DOT = [DOT(:,1:3) LLC(:,1:3) DOT(:,4:end)];


% rx1 = '((ESAL)+(\d)+)';
% V = DOT.Properties.VariableNames';
% ECOLS = ~cellfun('isempty',regexp(V,rx1));

IDOT = DOT;

clearvars -except TAB EBWB ORIG REHAB ESAL IDOT YEAR

%%

writetable(IDOT,'IDOT.xlsx','Sheet',DOT.HIGHWAY(1,:));





%-----------------------------------------------------------------
%%   CHECK IF ORIGINAL CONSTRUCTION YEAR IS AFTER ESAL FIRST YEAR
%-----------------------------------------------------------------

V = IDOT.Properties.VariableNames';
regexpStr = '((ESAL)+(\d)+)';
ESALcols = ~cellfun('isempty',regexp(V,regexpStr));

ESALS = table2array(IDOT(:,ESALcols));

YEAR = str2num(YEAR)';

YEARMX = repmat(YEAR,size(ESALS,1),1);

ESALNAN = ~isnan(ESALS);

YEARN = YEARMX.*ESALNAN;

YEARN(YEARN==0) = NaN;

[M,Mi] = min(YEARN',[],1,'omitnan');


YEAR1ESAL = [M; Mi]' ;


OYR2EYR1 = YEAR1ESAL(:,1) - IDOT.OYEAR;

T = array2table([YEAR1ESAL OYR2EYR1]);

T.Properties.VariableNames = {'ESALYR1';'SKIPTO';'O2EYR1'};

IDOT = [IDOT(:,~ESALcols) T IDOT(:,ESALcols)];

%------------------------------




clearvars -except TAB EBWB ORIG REHAB ESAL IDOT YEAR

%% SAVE WHICH COLUMNS ARE FOR ESALS AND ALL TABLE COLUMN NAMES


rx1 = '((ESAL)+(\d)+)';
V = IDOT.Properties.VariableNames';
ECOLS = ~cellfun('isempty',regexp(V,rx1));



clearvars -except TAB EBWB ORIG REHAB ESAL IDOT YEAR ECOLS V


%% REMOVE ZONES SHORTER THAN A HALF MILE

TooShort = DOT.MP_DIST < .2;

DOT(TooShort,:) = [];


clearvars -except TAB YEAR DOT ECOLS V



%% REMOVE ROWS (ZONES) WHERE NB&SB DONT MATCH EXACTLY FOR VARS...
%{
rx1 = 'OYEAR';
rx2 = 'ESALYR1';
rx3 = 'SKIPTO';
rx4 = 'O2EYR1';
rx5 = '((ESAL)+(\d)+)';

cols1 = ~cellfun('isempty',regexp(V,rx1));
cols2 = ~cellfun('isempty',regexp(V,rx2));
cols3 = ~cellfun('isempty',regexp(V,rx3));
cols4 = ~cellfun('isempty',regexp(V,rx4));
cols5 = ~cellfun('isempty',regexp(V,rx5));


% % get an esal col from somewhere in the middle
% c = round(mean([find(cols5,1,'first') find(cols5,1,'last')]));
% cols5 = cols5.*0; cols5(c) = 1; cols5 = cols5>0;

NB=[DOT(:,cols1) DOT(:,cols2) DOT(:,cols3) DOT(:,cols4) DOT(:,cols5)];

NBL = table2array(NB);

NBL(isnan(NBL)) = 0;

BADROWS = sum(~NBL,2) > 0;

DOT(BADROWS,:) = [];

clearvars -except TAB EBWB IDOT YEAR DOT SBIDOT ECOLS NBV SBV
%}

%% REMOVE ROWS (ZONES) WHERE NB|SB DONT HAVE 2+ REHABS


RYEAR = DOT.RYEAR;

RYEARnan = isnan(RYEAR);

okNB = sum(~RYEARnan,2) > 1;

DOT(~okNB,:) = [];

clearvars -except TAB YEAR DOT ECOLS V



%% REMOVE NB|SB ROWS (ZONES) IF ESAL COUNTS ARE BEFORE HW EVEN BUILT??


O2EYR1 = DOT.O2EYR1;

BADROWS = (O2EYR1 > 5) | (O2EYR1 < 0);

DOT(BADROWS,:) = [];

clearvars -except TAB YEAR DOT ECOLS V









%% DETERMINE WHETHER PAVEMENT WAS REMOVED / REMAINED / UNMARKED


RREPAVE = DOT.RREPAVE;

rx1 = 'Remain in Place';
rx2 = 'Pavement Removal';
REMAIN = ~cellfun('isempty',regexp(RREPAVE,rx1));
REMOVE = ~cellfun('isempty',regexp(RREPAVE,rx2));
UNKNOW = (REMAIN + REMOVE)<1;

REM = zeros(size(RREPAVE));

REM(UNKNOW) = 0;
REM(REMAIN) = 1;
REM(REMOVE) = 2;



% SAVE RIGHT AFTER 'RYEAR'
rx1 = 'RYEAR';
RY = DOT.Properties.VariableNames';
RYEARCOL = find(~cellfun('isempty',regexp(RY,rx1)));



DOT.PAVEREMOVE = REM;

DOT = [DOT(:,1:RYEARCOL) DOT(:,end) DOT(:,(RYEARCOL+1):(end-1))];




rx1 = '((ESAL)+(\d)+)';
V = DOT.Properties.VariableNames';
ECOLS = ~cellfun('isempty',regexp(V,rx1));

clearvars -except TAB YEAR DOT ECOLS V



% return





%% DETERMINE IF ANY ROWS HAVE BEEN MARKED FOR PAVEMENT REMOVAL

REM = DOT.PAVEREMOVE;

HASREM = REM == 2;

ANYREM = sum(HASREM,2)>0;


IDOT = DOT(ANYREM,:);


rx1 = '((ESAL)+(\d)+)';
V = DOT.Properties.VariableNames';
ECOLS = ~cellfun('isempty',regexp(V,rx1));

clearvars -except TAB YEAR DOT ECOLS V LATLON IDOT

%% ADD OYEAR TO RYEAR LIST & DETERMINE NUMBER OF YEARS BETWEEN RYEARS
%{
RYEAR = DOT.RYEAR;
RYEAR = [DOT.OYEAR RYEAR];

DOT.RYEAR = RYEAR;

YRDIF = zeros(size(RYEAR));
YRDIF(:,end)=[];

j=1;
for i = 2:size(RYEAR,2)


    YRDIF(:,j) = RYEAR(:,i) - RYEAR(:,j);

j=j+1;
end


% YRDIF LESS THAN 5 IS NOT A MAJOR REHAB

YRDIF(YRDIF < 5) = 0;


find(YRDIF==0)
%}



% PR = IDOT.PAVEREMOVE;
% 
% RYEAR = IDOT.RYEAR;
% 
% [r,c,v] = find(PR==2)
% 
% 
% s = sub2ind(size(RYEAR),r,c);
% 
% RYEAR(s)
% 
% r



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


%%
%{
YRDIF

RREPAVE = DOT.RREPAVE;

REM = DOT.REM;

RACPG = DOT.RACPG;

RNDES = DOT.RNDES;



Z_RREPAVE = cell(size(RREPAVE));
Z_REM     = NaN(size(REM));
Z_RACPG   = cell(size(RACPG));
Z_RNDES   = NaN(size(RNDES));
Z_YRDIF   = NaN(size(YRDIF));


for i = 1:size(YRDIF,1)
for j = 1:size(YRDIF,2)


    k = YRDIF(i,j);
    if k==0

    
    end



end
end









clearvars -except TAB YEAR DOT ECOLS V
%}


DOTdo=0;
IDOTdo=0;

if ~isempty(DOT)
if size(DOT,1)>3
DOTdo=1;
end
end

if ~isempty(IDOT)
if size(IDOT,1)>3
IDOTdo=1;
end
end


%% GENERATE PLOTS
V = DOT.Properties.VariableNames';
regexpStr = '((ESAL)+(\d)+)';
ESALcols = ~cellfun('isempty',regexp(V,regexpStr));
EYEAR = V(ESALcols);
EYEAR = str2num(char(regexprep(EYEAR,'ESAL','')));
AXL = DOT{:,ESALcols};


close all;
if DOTdo
%################   TWO PACK   ################
fh1 = figure('Units','normalized','OuterPosition',[.01 .06 .9 .7],'Color','w','MenuBar','none');
ax1 = axes('Position',[.05 .09 .42 .83],'Color','none');
ax2 = axes('Position',[.55 .09 .42 .83],'Color','none');

axes(ax1)
imagesc(table2array(DOT(:,ECOLS)))
colormap(ax1,[0 0 0; parula])
ax1.YDir='normal';
ax1.XTickLabel = EYEAR(ax1.XTick);


axes(ax2)
ph1=surfl(table2array(DOT(:,ECOLS)));
ph1.LineStyle='-';
% ph1.EdgeColor=[.9 .4 .7];
ph1.EdgeColor=[.5 .5 .5];
% ph1.EdgeColor='flat';
% ph1.EdgeColor='interp';

ph1.FaceColor = 'interp';
% ph1.FaceColor = 'texturemap';

ph1.FaceAlpha = .9;
colormap(ax2,bone)


nr = size(DOT,1);
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
Yt = 1:n:height(DOT);
ax2.YTick = Yt;

Ystr = cellstr(DOT.COUNTY)';
ax2.YTickLabel = Ystr(Yt);



EC = table2array(DOT(:,ECOLS));
YR = EYEAR(min(DOT.SKIPTO):end);
Xt = ax2.XTick;
X = YR(round(linspace(1,numel(YR),numel(Xt))));
ax2.XTickLabel = X;

ylabel('\fontsize{18} County')
xlabel('\fontsize{18} Year')
zlabel('\fontsize{18} ESALs')

view([-40,50])



set(fh1,'PaperPositionMode','auto')
print(['ESAL_Heatmap_' DOT.HIGHWAY(1,:)],'-dpng','-r0')



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

V = DOT.Properties.VariableNames';
regexpStr = '((ESAL)+(\d)+)';
ESALcols = ~cellfun('isempty',regexp(V,regexpStr));
EYEAR = V(ESALcols);
EYEAR = str2num(char(regexprep(EYEAR,'ESAL','')));
AXL = DOT{:,ESALcols};



%% SURF ESALS X COUNTY X DATE

clc; close all
fh1 = figure('Units','pixels','Position',[10 35 1300 750],'Color','w');
ax1 = axes('Position',[.1 .06 .80 .85],'Color','none');

ph1 = surf(AXL);
title(['\fontsize{20} ' DOT.HIGHWAY(1,:) ' \fontsize{12}  (ESALS by COUNTY and DATE)'])
axis tight;

nr = size(DOT,1);
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
Yt = 1:n:height(DOT);
ax1.YTick = Yt;

Ystr = cellstr(DOT.COUNTY)';
ax1.YTickLabel = Ystr(Yt);

% Xt = ax1.XTick;
% ax1.XTickLabel = EYEAR(Xt);

EC = table2array(DOT(:,ECOLS));
YR = EYEAR(min(DOT.SKIPTO):end);
Xt = ax1.XTick;
X = YR(round(linspace(1,numel(YR),numel(Xt))));
ax1.XTickLabel = X;

ylabel('\fontsize{18} County')
xlabel('\fontsize{18} Year')
zlabel('\fontsize{18} ESALs')

view([-40,50])



set(fh1,'PaperPositionMode','auto')
print(['ESALS_by_COUNTY_and_DATE ' DOT.HIGHWAY(1,:)],'-dpng','-r0')




end

%% WRITE TABLES TO AN EXCEL SHEET NAMED-TAB

if DOTdo
writetable(DOT,'DOT.xlsx','Sheet',DOT.HIGHWAY(1,:));
end

if IDOTdo
writetable(IDOT,'IDOT.xlsx','Sheet',IDOT.HIGHWAY(1,:));
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


%% MAKE FINAL TABLES TABLES
%{
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

%}
