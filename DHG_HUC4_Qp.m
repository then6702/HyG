%script to find relationships between Q and DA/w/d/v for different
%percentiles over each HUC4

clear all
close all

%% section 1: load data

%load AHG,n,slope data
load('AHG_n_20190319.mat')
latlon_n(:,2) = latlon_n(:,2).*-1;
latlon_AHG(:,2) = latlon_AHG(:,2).*-1;

%load drainage area
fileName = 'NHD_xls/NHDPlusv2_GageInfo.xlsx';
[num, ~, raw] = xlsread(fileName,1,'A2:G27956');
ID_DA = raw(:,1);
DA = num(:,2);
clear num raw;
DA(DA<=0) = NaN;
[C,ia,ic] = unique(ID_DA);
DA = DA(ia);
ID_DA = C;
ID_DA(isnan(DA)) = [];
DA(isnan(DA)) = [];

%load Q percentiles file
load('lists/Q_percentiles_10yr.txt')
Qp = Q_percentiles_10yr(:,2:end);
clear Q_percentiles_10yr;
fileID = fopen('lists/Q_percentiles_10yr.txt','r');
ID_Qp = textscan(fileID,'%s %*[^\n]');
ID_Qp = ID_Qp{1};
fileID = fclose(fileID);
percentiles = [0.5 1:5 10:5:90 95:99 99.1:0.1:100]';
%load HUC4
S = shaperead('HUC4/HUC4');

%% section 2: cross-reference ID lists. Eliminate gages that don't have all data we want

%get indices of other lists
[ID_sort1,ia,ib] = intersect(ID_DA,ID_AHG);
DA = DA(ia);
AHG = AHG(ib,:);
latlon_AHG = latlon_AHG(ib,:);
Qvwd = Qvwd(ib,:);

[ID_sort1,ic,id] = intersect(ID_sort1,ID_n);
DA = DA(ic);
AHG = AHG(ic,:);
latlon_AHG = latlon_AHG(ic,:);
Qvwd = Qvwd(ic,:);
n = n(id);
slope = slope(id);

[ID_master,ie,ig] = intersect(ID_sort1,ID_Qp);
DA = DA(ie);
AHG = AHG(ie,:);
latlon_AHG = latlon_AHG(ie,:);
Qvwd = Qvwd(ie,:);
n = n(ie);
slope = slope(ie);
Qp = Qp(ig,:);


%% section 3: cluster gages by HUC4

% ax = figure(1);
% plotCONUS_NHD(0,ax,[25 53],[-125 -67],-1,1,'')
% hold on;

%initialize vector to assign HUC4 to each gage
HUC4 = zeros(size(ID_master));
%loop through each ecoregion, find points inside each one
for ii = 1:length(S)
    
    %check if lat/lon's are inside ecoregion polygon
    in = inpolygon(latlon_AHG(:,2),latlon_AHG(:,1),S(ii).X,S(ii).Y);
%     [ii sum(in)]
    
%     if sum(in)>0
%         plotm(S(ii).Y,S(ii).X)
%         scatterm(latlon_AHG(in==1,1),latlon_AHG(in==1,2))
%         counter = counter + 1;
%     end
    HUC4(in==1) = S(ii).OBJECTID;
    ii
end

HUC4(HUC4==0) = NaN;

%% section 4: test plot

ax = figure(1);
plotCONUS_NHD(0,ax,[25 53],[-125 -67],-1,1,'')
hold on;


for ii = 1:max(HUC4)
    scatterm(latlon_AHG(HUC4==ii,1),latlon_AHG(HUC4==ii,2),...
        15,[randi(10)/10 randi(10)/10 randi(10)/10],'filled')
end

%% section 5: get relationships by HUC4 and Q percentile

%initialize gif index and filename
% filename = 'CONUS_logDA_logQp_B1_HUC6.gif';
% filename = 'hist_logDA_logQp_B1_HUC4.gif';
count_im = 1;

for p = 90%5:10:95   %define which Q percentile to focus on

%     %initialize CONUS plots
    ax = figure(69);
    plotCONUS_NHD(0,ax,[25 53],[-125 -67],0,1,'RMSE')
    title(strcat('DA, Q',num2str(p)))
    
    ax = figure(96);
    plotCONUS_NHD(0,ax,[25 53],[-125 -67],0,1,'r^2')
    title(strcat('DA, Q',num2str(p)))

    %initialize output vectors
    rsq_DAQp = [];
    rsq_DAw = [];
    rsq_DAd = [];
    B1_DAQp = [];
    B1_DAw = [];
    B1_DAd = [];
    rsq_DAQp = [];
    B1_DAQp = [];
    B0_DAQp = [];
    E_DAQp = [];
    med_DAQp = [];
    
    %start loops
    counter = 1;
    while counter <= max(HUC4)

        %get index of gages w/in current HUC4
        huc_index = HUC4==counter;

        %kill if fewer than 5 gages 
        if sum(huc_index)<10
            counter = counter + 1;
            rsq_DAQp = [rsq_DAQp; NaN];
            B1_DAQp = [B1_DAQp; NaN];
            B0_DAQp = [B0_DAQp; NaN];
            E_DAQp = [E_DAQp; NaN];
            med_DAQp = [med_DAQp; NaN NaN];
            continue;
        end

        % define variables for HUC
        huc_Qp = Qp(huc_index==1,percentiles==p);
        huc_Qvwd = Qvwd(huc_index==1,:);
        huc_latlon = latlon_AHG(huc_index==1,:);
        huc_DA = DA(huc_index==1);
        huc_AHG = AHG(huc_index==1,:);
        
        %log transform
        logQp = log10(huc_Qp);
        logQp(isinf(logQp)) = NaN;
%         logDA = log10(huc_DA);
        logDA = log10(huc_AHG(:,1)); %TRY USING AHG PARAMS
        logw = log10(huc_Qvwd(:,3));
        logd = log10(huc_Qvwd(:,4));
        
        %check that there are at least 5 points w/ Q
        flagger = ~isnan(logQp);
        if sum(flagger)<10
            counter = counter + 1;
            rsq_DAQp = [rsq_DAQp; NaN];
            B1_DAQp = [B1_DAQp; NaN];
            B0_DAQp = [B0_DAQp; NaN];
            E_DAQp = [E_DAQp; NaN];
            med_DAQp = [med_DAQp; NaN NaN];
            continue;
        end
        
        %swap in a drop-X
        X = 10;
        iterations = 50;
        [B1,B0,error,rsq] = dropXpercent(logDA,logQp,X,iterations);
        rsq_DAQp = [rsq_DAQp; rsq(1)];
        B1_DAQp = [B1_DAQp; B1(1)];
        B0_DAQp = [B0_DAQp; B0(1)];
        E_DAQp = [E_DAQp; error(1)];
        med_DAQp = [med_DAQp; nanmedian(logDA) nanmedian(logQp)];
        
        
% %         %find relationships
%         mdl_DAQp = fitlm(logDA,logQp,'RobustOpts','on');
%         mdl_DAw = fitlm(logDA,logw,'RobustOpts','on');
%         mdl_DAd = fitlm(logDA,logd,'RobustOpts','on');
% 
% %         %append quantities of interest to output vectors
%         rsq_DAQp = [rsq_DAQp; mdl_DAQp.Rsquared.Ordinary];
%         rsq_DAw = [rsq_DAw; mdl_DAw.Rsquared.Ordinary];
%         rsq_DAd = [rsq_DAd; mdl_DAd.Rsquared.Ordinary];
%         B1_DAQp = [B1_DAQp; mdl_DAQp.Coefficients{2,1}];
%         B1_DAw = [B1_DAw; mdl_DAw.Coefficients{2,1}];
%         B1_DAd = [B1_DAd; mdl_DAd.Coefficients{2,1}];

        %plot
        figure(69)
        scatterm(huc_latlon(:,1),huc_latlon(:,2),25,...
            ones(size(huc_latlon,1),1).*E_DAQp(end),'filled')
        figure(96)
        scatterm(huc_latlon(:,1),huc_latlon(:,2),25,...
            ones(size(huc_latlon,1),1).*rsq_DAQp(end),'filled')
        
        
        %increment counter
        counter = counter + 1;

    end
    
    %print rsq on plot
    figure(69)
    textm(27,-124,strcat('med. error = ',num2str(round(nanmedian(E_DAQp),2))))
    figure(96)
    textm(27,-124,strcat('med. r^2 = ',num2str(round(nanmedian(rsq_DAQp),2))))
    
%     %plot histogram
%     ax = figure;
%     h = histogram(B1_DAQp,'numbins',20);
%     h.Normalization = 'probability';
%     ylim([0 0.55])

    figure;
    scatter(rsq_DAQp,E_DAQp)
    set(gca,'fontsize',14)
    xlabel('r^2')
    ylabel('RMSE')
    
    figure;
    scatter(med_DAQp(:,1),E_DAQp)
    set(gca,'fontsize',14)
    xlabel('med. logDA')
    ylabel('RMSE')
    
    figure;
    scatter(med_DAQp(:,2),E_DAQp)
    set(gca,'fontsize',14)
    xlabel('med. logQ90')
    ylabel('RMSE')
    
% %     %write to gif
% %     frame = getframe(ax);
% %     im = frame2im(frame);
% %     [imind,cm] = rgb2ind(im,256);
% %     close;
% %     if count_im==1
% %         imwrite(imind,cm,filename,'gif','Loopcount',inf);
% %     else
% %         imwrite(imind,cm,filename,'gif','WriteMode','append');
% %     end
% %     
% %     count_im = count_im+1;
%     

    
end


%     
% 
% figure;
% for idx = 1:length(im)
%     imshow(im{idx});
% end

% filename = 'scatter_DEP_vwd.gif'; % Specify the output file name
% for idx = 1:length(im)
%     [A,map] = rgb2ind(im{idx},256);
%     if idx == 1
%         imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1);
%     else
%         imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1);
%     end
% end
