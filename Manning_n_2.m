% clear all
% close all

%script to run through all USGS gages for which the requisite parameters
%exist (S = slope [=] m/m, R = depth [=] m, V = velocity [=] m/s), and 
%calculate Manning's n [=] s/m^(1/3) according to the equation 
%V = (R^(2/3)*S^(1/2))/n 

%a new method to QC Manning n: sort v,d,Q on Q.  The idea is to find the
%threshold (percentage based) above which calculated n doesn't have crazy
%spread
function [n,nVar,wd_med,wd_var,Q_sort,nVals,uncertainty] = ...
    Manning_n_2(gage_ID,stn_d,stn_w,stn_v,stn_Q,slope)

%assemble [Q d v]
tmp = [stn_Q stn_d stn_v];

%sort on Q
sorted = sortrows(tmp);
logQ = log10(sorted(:,1));

%remove any measurements <threshold% of Qmax
threshold = 50;
Qmax = logQ(end);
flag = logQ < (Qmax*(threshold/100));
sorted(flag==1,:) = [];
%get QC'd Manning n
nVec = ((sorted(:,2).^(2/3)).*(slope^(1/2)))./sorted(:,3);

%return sorted Q
Q_sort = sorted(:,1);
nVals = size(nVec,1);

%calculate w:d ratio, output median and variance
w_d = stn_w./stn_d;
wd_med = nanmedian(w_d);
wd_var = nanvar(w_d);

%calculate Manning's n, output median and variance
% nVec = ((stn_d.^(2/3)).*(slope^(1/2)))./stn_v;
n = nanmedian(nVec);
nVar = nanvar(nVec);

%call function to estimate uncertainty
[uncertainty] = Manningn_uncertainty(nVec,gage_ID,Q_sort,50);
end

