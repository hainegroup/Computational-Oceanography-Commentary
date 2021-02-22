function supercomputerhistory = import_top500_history_file(filename)
%IMPORTFILE Import data from a text file

%% Input handling
dataLines = [4, Inf];
fprintf(1,' Reading file [%s] rows [%d]-[%d]...',filename,dataLines(1),dataLines(2)) ;

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 7);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["VarName1", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7"];
opts.VariableTypes = ["double", "string", "double", "double", "double", "string", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["VarName2", "VarName6", "VarName7"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["VarName2", "VarName6", "VarName7"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, ["VarName1", "VarName3", "VarName4", "VarName5"], "ThousandsSeparator", ",");

% Import the data
data = readtable(filename, opts);

%% Create output variable
supercomputerhistory.times        = datetime(table2array(data(:,1)),7,1) ;
supercomputerhistory.Machine_name = table2cell( data(:,2)) ;
supercomputerhistory.cores        = table2array(data(:,3)) ;
supercomputerhistory.Rmax         = table2array(data(:,4)).*1e9 ;   % Units are GFLOPs
supercomputerhistory.Rpeak        = table2array(data(:,5)).*1e9 ;   % Units are GFLOPs

% For exponential fit
inds                                    = year(supercomputerhistory.times) > 1990 ;
supercomputerhistory.recent_times       = supercomputerhistory.times(inds) ;
supercomputerhistory.recent_Speed_flops = supercomputerhistory.Rmax( inds) ;

supercomputerhistory.color = [0.0000 0.4470 0.7410] ;

fprintf(1,'done.\n\n') ;

end