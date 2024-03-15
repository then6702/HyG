clear all
close all

%script to loop through QC'd Q records and calculate daily exceedance
%probability for each one.  Plot should have Q on the x axis, exceedance
%probability on the y axis.  The approach is roughly: sort by Q, then
%plot Q against exceedance probability (n - i + 1)/(n+1)

%string parts
dirStr = 'Q_records_10yr/';
files = dir('Q_records_10yr/*.txt');
Qstart = 'Q_records_10yr/Q_metric_qc_ID';
Qend = '.txt';

%initialize counter
counter = 0;

%open output file for writing
saveFile = 'lists/Q_percentiles_10yr.txt';
fID = fopen(saveFile,'w');

%initialize some output vectors
vec_ID = [];
mat_coeff = [];

%error flag

stn_error_code = zeros(10871,1);
counter = 0;
%start loop
for file = files'
    
    %load file
    fileName = strcat(dirStr,file.name);
%     fileName = strcat(Qstart,ID,Qend);
    fileID = fopen(fileName,'r');
    data = textscan(fileID,'%s %f %*[^\n]');
    Q = data{1,2};
    Q(Q<0) = NaN;
    data = [Q datenum(data{1,1},'yyyy-MM-dd')];
    fileID = fclose(fileID);
    
    %sort on Q
    dataMat = sortrows(data);
    dataMat(isnan(dataMat(:,1)),:) = [];
    dataCDF = dataMat(:,1)./dataMat(end,1);
   

    %Daily exceedance probability
    P = (size(dataMat,1)-(1:size(dataMat,1))+1)/(size(dataMat,1)+1);

    %sample at various points on curve
    percentiles = [0.5 1:5 10:5:90 95:99 99.1:0.1:100]';
    index_ptile = round(size(dataMat,1).*(percentiles./100),0);
    index_ptile(index_ptile==0) = 1;
    Q_ptile = dataMat(index_ptile,1);
    P_ptile = P(index_ptile);
    
    %parse file name for gage ID
    ID = strsplit(file.name,'.');
    ID = strsplit(ID{1},'_');
    
    
    %write to output file
    fprintf(fID,'%15s',ID{4}(3:end));
    for ii = 1:length(Q_ptile)
        fprintf(fID,'%9.2f',Q_ptile(ii));
    end
    fprintf(fID,'\n');

    %test plot
%     hold on;
%     scatter(Q_ptile,P(index_ptile))
%     set(gca,'fontsize',14)
%     xlabel('Q (m^3/s)');
%     ylabel('DEP')
%     title(ID)
    %print counter step
    ID{4}(3:end)
    counter = counter + 1
end
% save('Q_10yr_Coefficients_aexpbx.mat','mat_coeff','vec_ID')

fID = fclose(fID);