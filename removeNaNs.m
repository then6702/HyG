%function to flag the indices of all NaNs in station Q,d,v,w and remove
%them. In other words, get rid of 'fake' station measurements

function [Q,d,v,w,date,dist] = removeNaNs(Q,d,v,w,date,dist)

%go through Q,d,v,w, flag NaNs
flag = isnan(Q) + isnan(d) + isnan(v) + isnan(w);

%remove flagged indices
Q = Q(flag==0);
d = d(flag==0);
v = v(flag==0);
w = w(flag==0);
date = date(flag==0);
dist = dist(flag==0);

end