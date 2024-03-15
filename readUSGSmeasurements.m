function [ID_str,meas_no,GH,Q_m,w_m,A_m,v_m,dist_m,rating] = ...
    readUSGSmeasurements(dataFile,ID)

%script to read in USGS measurements from text file (and maybe save as mat
%file?) and convert discharge, width, area, and velocity to metric

%open file 
fileName = dataFile;
% fileName = 'usgs_measurements.txt';
fileID = fopen(fileName,'r');

%read in data
%%% For now, we are reading in site number(2), measurement number(3),
%%% date(4), gage height (10), measurement rating (good/fair/poor) (11),...
%%% and channel discharge (cfs)(21), width(ft)(22), area(sq.ft.)(23), velocity(ft/s)(24).  Column numbers in parenthesis
data = textscan(fileID,...
    '%*s %s %s %s %*s %*s %*s %*s %s %*s %s %*s %*s %*s %*s %*s %*s %*s %*s %*s %s %s %s %s %*s %*s %*s %*s %*s %*s %*s %s %*[^\n]','headerlines',66846,'delimiter','\t');
% data = textscan(fileID,'%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %*[^\n]','headerlines',66846);
% data = textscan(fileID,'%s %s %f %s %s %s %s %f %f %s %f %f %s %s %f %s %s %s %s %s %s %f %f %f %f %s %s %s %s %s %s %s','headerlines',66846);
fileID = fclose(fileID);

%name variables
ID_str = data{1,1};
meas_no = data{1,2};
date = data{1,3};
GH = str2double(data{1,4});
rating = data{1,5};
Q = str2double(data{1,6});
w = str2double(data{1,7});
A = str2double(data{1,8});
v = str2double(data{1,9});
dist = str2double(data{1,10});

%convert to metric
Q_m = Q.*(0.3048^3); %from cfs to cms
w_m = w.*0.3048;     %from ft to m
A_m = A.*(0.3048^2); %from ft^2 to m^2
v_m = v.*0.3048;     %from ft/s to m/s
dist_m = dist.*0.3048; %from ft to m (I assume, can't find units anywhere)

%account for unreasonable values
Q_m(Q_m<=0) = NaN;
w_m(w_m<=0) = NaN;
A_m(A_m<=0) = NaN;
v_m(v_m<=0) = NaN;

%pull out ID of interest
ind = strcmp(ID_str,ID);
Q_m = Q_m(ind);
w_m = w_m(ind);
A_m = A_m(ind);
v_m = v_m(ind);
end