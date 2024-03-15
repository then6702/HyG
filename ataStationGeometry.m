% updated at-a-station geometry code.  Section 1: read in data. Section 2:
% remove any measurements where Q=/=vA (within *threshold* percent). 

clear all
close all
%% Section 1: read in data from various text files
% % % %read in USGS measurement data (discharge, width, area, velocity). They
% % % %are already in metric
% % % [ID,meas_no,Q,w,A,v,dist] = ...
% % %     readUSGSmeasurements('usgs_measurements.txt');
% % % 
% % % %save this so we don't have to do it again
% % % save('usgs_measurements.mat','ID','meas_no','Q','w','A','v','dist')

%load saved usgs measurements
load('usgs_measurements.mat')

%load datenum file
load('usgs_measurements_datenum.mat','date_dn');

%calculate depth (in meters)
d = A./w;

%read in NHD slope data (slope in m/m)
fileName = 'lists/USGS_slope_reach_20190220.txt';
fileID = fopen(fileName,'r');
data = textscan(fileID,'%s %*s %s %f %*[^\n]');
fileID = fclose(fileID);
ID_slope = data{1,1};
reachCode = data{1,2};
slope = data{1,3};

%read in lat/lon data
fileName = 'lists/USGS_llae_metric.txt';
fileID = fopen(fileName,'r');
data = textscan(fileID,'%f %f %*[^\n]','HeaderLines',1);
lat = data{1,1};
lon = data{1,2};
fileID = fclose(fileID);

%read in full list of gage IDs
fileName = 'lists/USGS_IDs.txt';
fileID = fopen(fileName,'r');
data = textscan(fileID,'%s %*[^\n]','HeaderLines',1);
ID_str_all = data{1,1};
fileID = fclose(fileID);

%% Section 2: QC to remove measurements where Q =/= vA within *threshold* %

threshold = 5;
[Q,A,w,d,v,dist,ID,date_dn,meas_no,flagStn] = ...
    qc_QvA(Q,A,w,d,v,dist,ID,date_dn,meas_no,threshold);

%% Section 3: do some setup
%NaN any physically unrealistic values
v(v<=0) = NaN;
w(w<=0) = NaN;
d(d<=0) = NaN;
Q(Q<=0) = NaN;

%initialize output vectors
vec_b = [];
vec_f = [];
vec_m = [];
vec_a = [];
vec_c = [];
vec_k = [];
vec_v = [];
vec_d = [];
vec_w = [];
vec_Q = [];
vec_nmeas = [];
vec_ID_AHG = [];
vec_ID_n = [];
vec_wd_med = [];
vec_n_med = [];
vec_rmsd = [];
vec_slope = [];
latlon_AHG = [];
latlon_n = [];
% vec_lat = [];
% vec_lon = [];

%error code vector. 1 = no data. 2 = too few measurements. 
%3 = bad linear fits. 4 = too many measurements excluded by QC (same as 2,
%but measurements are excluded downstream. 5 = no slope data. 6 = bad HyG
%conveniences
stn_error_code = zeros(size(ID_str_all)); 

%number of measurements vector. Look for correlation between (low) number
%of measurements and other sources of error
num_meas = zeros(size(ID_str_all));


%% Section 4: data processing by gage

%loop through the list of all stations
for ii = 1:length(ID_str_all)
%  ii = 65847;   
    %get index of data corresponding to station
    stn_ind = strcmp(ID,ID_str_all(ii));
    
    %kill if station is not found in list
    if sum(stn_ind)==0
        stn_error_code(ii) = 1;
        [num2str(ii) '      no data']
        continue;
    end
    
    %isolate relevant data for that station
    stn_w = w(stn_ind==1);
    stn_d = d(stn_ind==1);
    stn_Q = Q(stn_ind==1);
    stn_v = v(stn_ind==1);
    stn_date = date_dn(stn_ind==1);
    stn_dist = dist(stn_ind==1);
    
    
    %remove any NaN values (they don't count as measurements)
    [stn_Q,stn_d,stn_v,stn_w,stn_date,stn_dist] = ...
        removeNaNs(stn_Q,stn_d,stn_v,stn_w,stn_date,stn_dist);

    %record number of measurements
    num_meas(ii) = length(stn_Q);
    
    %kill if there are less than 10 measurements
    if length(stn_Q)<10
        stn_error_code(ii) = 2;
        [num2str(ii) '      too few measurements']
        continue;
    end

    %cut down to most recent X years of data
    X = 5;
    [stn_d,stn_w,stn_v,stn_Q] = ...
                lastXyears(stn_d,stn_w,stn_v,stn_Q,stn_date,X);
    
    %log transform data, find and remove outliers, get hydraulic geometry
    [abcfkm,stn_Q,stn_d,stn_v,stn_w,badfit] = ...
        logTransform(stn_Q,stn_d,stn_v,stn_w);
    
    %overwrite number of measurements
    num_meas(ii) = length(stn_Q);
    
    %kill if any pvalue greater than 0.05 (i.e. linear fits are bad)
    if badfit==1
        stn_error_code(ii) = 3;
        [num2str(ii) '      bad linear fits']
        continue;
        %kill if fewer than 10 measurements
    elseif badfit==2
        stn_error_code(ii) = 4;
        [num2str(ii) '      too many measurements excluded by QC']
        continue;
    end
%     length(stn_Q)
      
    %check ack,bfm
    if abcfkm(1)*abcfkm(3)*abcfkm(5)>1.1 || ...
            abcfkm(1)*abcfkm(3)*abcfkm(5)<0.9
        stn_error_code(ii) = 6;
        [num2str(ii) '      bad HyG conveniences']
        continue;
    elseif abcfkm(2)+abcfkm(4)+abcfkm(6)>1.1 || ...
            abcfkm(2)+abcfkm(4)+abcfkm(6)<0.9
        stn_error_code(ii) = 6;
        [num2str(ii) '      bad HyG conveniences']
        continue;
    end
    
    %append coefficients to vectors
    vec_a = [vec_a; abcfkm(1)];
    vec_b = [vec_b; abcfkm(2)];
    vec_c = [vec_c; abcfkm(3)];
    vec_f = [vec_f; abcfkm(4)];
    vec_k = [vec_k; abcfkm(5)];
    vec_m = [vec_m; abcfkm(6)];
    vec_w = [vec_w; nanmedian(stn_w)];
    vec_Q = [vec_Q; nanmedian(stn_Q)];
    vec_d = [vec_d; nanmedian(stn_d)];
    vec_v = [vec_v; nanmedian(stn_v)];
    vec_nmeas = [vec_nmeas; num_meas(ii)];
    vec_ID_AHG = [vec_ID_AHG; ID_str_all(ii)];
    latlon_AHG = [latlon_AHG; lat(ii) lon(ii)];
    
%     %find gage ID in slope list
    slope_id = strcmp(ID_slope,ID_str_all(ii));
%     
%     %if there is a slope associated w/ this gage, calculate Manning n, w:d
    if sum(slope_id)==1
        [n,nvar,wd_med,wd_var,Q_sort,nv,uncertainty] = ...
            Manning_n_2(ID_str_all(ii),stn_d,stn_w,stn_v,stn_Q,...
            slope(slope_id==1));
        vec_ID_n = [vec_ID_n; ID_str_all(ii)];
        vec_n_med = [vec_n_med; n];
        vec_wd_med = [vec_wd_med; wd_med];
        vec_rmsd = [vec_rmsd; uncertainty];
        vec_slope = [vec_slope; slope(slope_id==1)];
        latlon_n = [latlon_n; lat(ii) lon(ii)];
    else
        stn_error_code(ii) = 5;
        [num2str(ii) '      no slope data']
    end
                
    ii
end

%% plots of interest 
close all

%remove min slope values
lo_slope = vec_slope>0.00001;
nolo_latlon = latlon_n(lo_slope,:);
nolo_n = vec_n_med(lo_slope);
nolo_slope = vec_slope(lo_slope);
% nolo_n = vec_n_med;
% nolo_slope = vec_slope;
% nolo_latlon = latlon_n;

%density plot, slope vs. n
dplot_size = 0:0.005:0.5;
dplot_cont = hist3([nolo_n,nolo_slope],'Ctrs',{dplot_size' dplot_size'});
[x,y] = meshgrid(dplot_size,dplot_size);
figure
subplot(1,2,1)
surface(x,y,dplot_cont)
xlabel('Slope (m/m)')
ylabel('Manning n')
c = colorbar;
colormap(flipud(hot(10)))
xlabel(c,'# of measurements');
caxis([0.1 350])
axis([0 0.2 0 0.5])
set(gca,'fontsize',14)
set(gca,'colorscale','log')
subplot(1,2,2)
scatter(nolo_slope,nolo_n)
% axis([0 0.2 0 0.5])
xlabel('Slope (m/m)')
ylabel('Manning n')
set(gca,'fontsize',14)

%normalized histogram of n
figure;
h = histogram(nolo_n,'binedges',0:0.01:4,'normalization','probability');
sum(h.BinCounts(3:8))/sum(h.BinCounts)
ylabel('Fraction')
xlabel('Manning n')
set(gca,'fontsize',14)
xlim([0 0.2])

%station error codes (1 = no data, 2 = <10 measurements (preQC), 3 = bad
%linear fits, 4 = <10 measurements (postQC), 5 = no slope data, 
%6 = bad AHG conveniences
% figure;
% scatter(stn_error_code,num_meas)

%fit linear model to slope vs n
mdl = fitlm(nolo_slope,nolo_n,'RobustOpts','on');
mdl_x = 0:0.01:0.2;
mdl_y = (mdl.Coefficients{2,1}.*mdl_x)+mdl.Coefficients{1,1};
figure;
hold on;
scatter(nolo_slope,nolo_n)
plot(mdl_x,mdl_y)
axis([0 0.2 0 0.5])
xlabel('Slope (m/m)')
ylabel('Manning n')
text(0.15,0.05,strcat('r^2=',num2str(mdl.Rsquared.Ordinary)),...
    'fontsize',14)
set(gca,'fontsize',14)

%fit linear model to log(slope) vs n
mdl = fitlm(log10(nolo_slope),nolo_n,'RobustOpts','on');
mdl_x = -5.5:0.01:0;
mdl_y = (mdl.Coefficients{2,1}.*mdl_x)+mdl.Coefficients{1,1};
figure;
hold on;
scatter(log10(nolo_slope),nolo_n)
plot(mdl_x,mdl_y)
axis([-5.5 0 0 0.5])
xlabel('log(slope)')
ylabel('Manning n')
text(-1,0.05,strcat('r^2=',num2str(mdl.Rsquared.Ordinary)),...
    'fontsize',14)
set(gca,'fontsize',14)

%fit linear model to slope vs log(n)
mdl = fitlm((nolo_slope),log10(nolo_n),'RobustOpts','on');
mdl_x = 0:0.01:0.2;
mdl_y = (mdl.Coefficients{2,1}.*mdl_x)+mdl.Coefficients{1,1};
figure;
hold on;
scatter((nolo_slope),log10(nolo_n))
plot(mdl_x,mdl_y)
axis([0 0.2 -2.5 1])
xlabel('slope (m/m)')
ylabel('log(n)')
text(0.15,-2,strcat('r^2=',num2str(mdl.Rsquared.Ordinary)),...
    'fontsize',14)
set(gca,'fontsize',14)

%fit linear model to log(slope) vs log(n)
mdl = fitlm(log10(nolo_slope),log10(nolo_n),'RobustOpts','on');
mdl_x = -5.5:0.01:0.2;
mdl_y = (mdl.Coefficients{2,1}.*mdl_x)+mdl.Coefficients{1,1};
figure;
hold on;
scatter(log10(nolo_slope),log10(nolo_n))
plot(mdl_x,mdl_y)
axis([-5.5 0.2 -3 0.5])
xlabel('log(slope)')
ylabel('log(n)')
text(-1,-2,strcat('r^2=',num2str(mdl.Rsquared.Ordinary)),...
    'fontsize',14)
set(gca,'fontsize',14)

% ax = figure;
% hold on;
% plotCONUS_NHD(0,ax,[25 52],[-125 -67],thresh_slo,...
%     nanmax(nolo_slope),'')
% scatterm(max_latlon(:,1),-1.*max_latlon(:,2),60,...
%     max_slope,'filled','markeredgecolor','k')
% c = colorbar;
% caxis([0 0.04])
% colormap(hsv(8))
% % c.Ticks = 1:5;
% c.Label.String = 'Slope';

% %histograms of variables of interest
figure
subplot(2,2,1)
histogram(Q(max_meas))
xlabel('Q (m^3/s)')
set(gca,'fontsize',14)
subplot(2,2,2)
histogram(v(max_meas))
xlabel('v (m/s)')
set(gca,'fontsize',14)
subplot(2,2,3)
histogram(w(max_meas))
xlabel('w (m)')
set(gca,'fontsize',14)
subplot(2,2,4)
histogram(d(max_meas))
xlabel('d (m)')
set(gca,'fontsize',14)

wd = w(max_meas)./d(max_meas);
wd_med = nanmedian(wd)

%% write text file of HyG parameters
% fileID = fopen('lists/USGS_HyG_parameters_qc.txt','w');
% for ii = 1:length(vec_a)
%     fprintf(fileID,'%15s',vec_ID_HyG{ii});
%     fprintf(fileID,'%13.5f',vec_a(ii));
%     fprintf(fileID,'%13.5f',vec_b(ii));
%     fprintf(fileID,'%13.5f',vec_c(ii));
%     fprintf(fileID,'%13.5f',vec_f(ii));
%     fprintf(fileID,'%13.5f',vec_k(ii));
%     fprintf(fileID,'%13.5f',vec_m(ii));
%     fprintf(fileID,'\n');
% end
% fileID = fclose(fileID);
