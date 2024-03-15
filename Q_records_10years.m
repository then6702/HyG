clear all
close all
warning('off','all')

%loop through all Q records, identify those w/ >=10 years worth of data,
%<10% data gaps

%string parts
Qstart = 'Q_records/data_USGS_ID';
Qend = '.txt';
IDfile = 'lists/usgs_IDs_Q.txt';
saveStart = 'Q_records_all/Q_metric_qc_ID';
saveEnd = '.txt';

%load all Q record IDs
fileID = fopen(IDfile,'r');
data = textscan(fileID,'%s %*[^\n]','HeaderLines',1);
ID_all = data{1,1};
fileID = fclose(fileID);

%flag vector
flagVec = ones(size(ID_all));
noDischarge = 0;

%start loop
for ii = 1:length(ID_all)
    
    %load Q file
    Qfile = strcat(Qstart,ID_all{ii},Qend);
    existence = exist(Qfile,'file');
    if existence==0
        strcat(Qfile,' does not exist')
        flagVec(ii) = 0;
        noDischarge = noDischarge + 1;
        continue;
    end
    data = readtable(Qfile,'DatetimeType','text');
    date = table2array(data(2:end,3));
    Q = str2double(table2array(data(2:end,4)));
    
    %run through Q values, snip out missing data sections longer than 6
    %months
    counter_nanblock = 0;
    flagger = 2;
    nan_index = isnan(Q);
    nan_flag = zeros(size(nan_index));
    for jj = 1:length(Q)
        %first iteration. 
        if jj==1 
            if nan_index(jj)==1
                counter_nanblock = counter_nanblock+1;
                nan_flag(jj) = nan_index(jj)*flagger;
            end
            
        elseif nan_index(jj)==1 && nan_index(jj-1)==0
            counter_nanblock = counter_nanblock+1;
            nan_flag(jj) = nan_index(jj)*flagger;
            
        %criterion for if we are within a block of nan's
        elseif nan_index(jj)==1 && nan_index(jj-1)==1
            counter_nanblock = counter_nanblock+1;
            nan_flag(jj) = nan_index(jj)*flagger;
            
        %riterion for exiting the block of nan's
        elseif nan_index(jj-1)==1 && nan_index(jj)==0
            
            %flag the block as negative if it is longer than 6 months (365/2 days)
            if counter_nanblock > (182)
                nan_flag(nan_flag==flagger) = -1;
            end
            flagger = flagger + 1;
            counter_nanblock = 0;
        end
    end
    
    %remove big (>6 months) sections of NaN;
    Q(nan_flag==-1) = [];
    
     %check (again) if date range is >=10 year
     if length(Q) < 3650
         strcat(Qfile, ' has too few measurements')
         flagVec(ii) = 0;
         continue;
     end
    
    %check that >=90% of data is present
    dataFrac = (sum(isnan(Q))/length(Q))*100;
    if dataFrac >= 10
        strcat(Qfile,' is <90% complete')
        flagVec(ii) = 0;
        continue;
    end
    
    %if criteria are met, convert to metric and save
    if flagVec(ii)==1
        
        %convert to metric
        Q = Q.*(0.3048^3);
    
    %write and save a new Q file
    
        saveFile = strcat(saveStart,ID_all{ii},saveEnd);
        fileID = fopen(saveFile,'w');
        for jj = 1:length(Q)
            fprintf(fileID,'%10s',date{jj});
            fprintf(fileID,'%10.2f\n',Q(jj));
        end
        fileID = fclose(fileID);
    end
    ii
end