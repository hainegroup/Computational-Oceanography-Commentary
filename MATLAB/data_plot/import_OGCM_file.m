function data = import_OGCM_file(filename)
% Imports data from OGCM_data_history.numbers

%% Input handling

% If dataLines is not specified, define defaults
dataLines = [4, Inf];
fprintf(1,' Reading file CGCM [%s] rows [%d]-[%d]...',filename,dataLines(1),dataLines(2)) ;

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 9);

% Specify range and delimiter
opts.DataLines = [4, 8];        % Specify rows of the csv file to read here
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["VarName1", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9"];
opts.VariableTypes = ["string", "double", "double", "double", "double", "double", "string", "categorical", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["VarName1", "VarName7", "VarName9"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["VarName1", "VarName7", "VarName8", "VarName9"], "EmptyFieldRule", "auto");

% Import the data
in_data = readtable(filename, opts);

%% Create output variable
data.names        = table2cell( in_data(:,1)) ;
data.times        = datetime(table2array(in_data(:,2)),7,1) ;
data.lat_spacing  = table2cell( in_data(:,3)) ;
data.lon_spacing  = table2array(in_data(:,4)) ;
data.Nlevels      = table2array(in_data(:,5)) ;
data.Ngridpts     = table2array(in_data(:,6)) ;
%data.color        = [ 0.8500 0.3250 0.0980 ] ;
data.color        = 'k' ;

fprintf(1,'done.\n') ;

end