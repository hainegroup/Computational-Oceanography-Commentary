function data = import_CGCM_file(filename)

%% Initialize variables.
delimiter = ',';
startRow = 5;
endRow = 155;
fprintf(1,' Reading file CGCM [%s] rows [%d]-[%d]...',filename,startRow,endRow) ;

%% Read columns of data as text:
formatSpec = '%s%s%s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[3,4,5,6,7,8]
    % Converts text in the input cell array to numbers. Replaced non-numeric
    % text with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1)
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData(row), regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if numbers.contains(',')
                thousandsRegExp = '^[-/+]*\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'))
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric text to numbers.
            if ~invalidThousandsSeparator
                numbers = textscan(char(strrep(numbers, ',', '')), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch
            raw{row, col} = rawData{row};
        end
    end
end


%% Split data into numeric and string columns.
rawNumericColumns = raw(:, [3,4,5,6,7,8]);
rawStringColumns = string(raw(:, [1,2,9]));


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%% Make sure any text containing <undefined> is properly converted to an <undefined> categorical
idx = (rawStringColumns(:, 2) == "<undefined>");
rawStringColumns(idx, 2) = "";

%% Create output variable
data.name = rawStringColumns(:, 1);
data.assessment = categorical(rawStringColumns(:, 2));
data.year = cell2mat(rawNumericColumns(:, 1));
data.times = datetime(data.year,7,1) ;
data.lat_spacing = cell2mat(rawNumericColumns(:, 2));
data.lat_spacing = cell2mat(rawNumericColumns(:, 3));
data.Nlevels = cell2mat(rawNumericColumns(:, 4));
data.Ngridpts = cell2mat(rawNumericColumns(:, 5));
data.Nmodels = numel(data.name) ;

data.assessment_colours = [
    0.0000 0.4470 0.7410 ; ...
    0.8500 0.3250 0.0980 ; ...
    0.9290 0.6940 0.1250 ; ...
    0.4940 0.1840 0.5560 ; ...
    0.4660 0.6740 0.1880 ; ...
    0.6350 0.0780 0.1840 ] ;
data.assessment_colours(6,:) = [128,205,193]./256 ;         % To match the scales diagram colour
data.assessment_names = {'FAR','SAR','TAR','AR4','AR5','AR6'} ;
for rr = 1:numel(data.assessment_names)
    data.assessment_times(rr) = mean(data.times(data.assessment == data.assessment_names(rr))) ;
end % rr

data.colour = zeros(data.Nmodels,3) ;
for mm = 1:data.Nmodels
    data.colour(mm,:) = data.assessment_colours(data.assessment(mm) == data.assessment_names,:) ;
end % mm

% Extract highest resolution models for each assessment
for aa = 1:numel(data.assessment_names)
    these_model_inds = find(data.assessment == data.assessment_names(aa)) ;
    best_model_ind = min(find(data.Ngridpts(these_model_inds) == max(data.Ngridpts(these_model_inds)))) ;
    data.assessment_best_times(aa)    = data.times(these_model_inds(best_model_ind)) ;
    data.assessment_best_Ngridpts(aa) = data.Ngridpts(these_model_inds(best_model_ind)) ;
end % aa

fprintf(1,'done.\n') ;
end