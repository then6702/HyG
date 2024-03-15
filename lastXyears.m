%function to get the last X years of data from a channel measurement data
%set

function [X_d,X_w,X_v,X_Q] = lastXyears(stn_d,stn_w,stn_v,stn_Q,stn_date,X)

%convert datenum to date vector
datevector = datevec(stn_date);

%how many years does the data span?
yearRange = max(datevector(:,1)) - min(datevector(:,1));

%flag all measurements from the most recent X years
flag = datevector(:,1)>=(datevector(end,1)-(X-1));

%if the data span less than X years, take all of it
if yearRange<X
%     X_A = stn_A;
    X_d = stn_d;
    X_w = stn_w;
    X_v = stn_v;
    X_Q = stn_Q;
    
%if there are <10 measurements in the most recent X years, take the most
%recent 10 measurements
elseif sum(flag)<10
    X_d = stn_d((end-9):end);
    X_w = stn_w((end-9):end);
    X_v = stn_v((end-9):end);
    X_Q = stn_Q((end-9):end);
    
%otherwise, take the flagged measurements (from the most recent X years)
else
%     X_A = stn_A(flag==1);
    X_d = stn_d(flag==1);
    X_w = stn_w(flag==1);
    X_v = stn_v(flag==1);
    X_Q = stn_Q(flag==1);
  end


