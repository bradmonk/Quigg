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
cd(fileparts(which('IDOT_NB.m')));


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

for TAB = 1:2
EBWB = 1;

filename = 'IDOT_ESAL.xlsx';

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



keyboard
%%


save(['IDOT' IDOT.HIGHWAY(1,:) '.mat'],'ORIG','REHAB','ESAL','IDOT')
writetable(IDOT,'IDOT.xlsx','Sheet',IDOT.HIGHWAY(1,:));


end


clc
disp('-----------------------------------')
disp(' ')
disp('FINISHED EXPORTING ALL DATA TABLES!')
disp(' ')
disp('-----------------------------------')
return
