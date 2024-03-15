function [abcfkm,stn_Q,stn_d,stn_v,stn_w,badfit] = ...
    logTransform(ID,stn_Q,stn_d,stn_v,stn_w)

%function to apply log transformation to streamflow data, derive
%coefficients

%log transform everything
logw = log10(stn_w);
logd = log10(stn_d);
logv = log10(stn_v);
logQ = log10(stn_Q);

%%%outlier removal procedure%%%

%outlier flag
flag = 1;%zeros(length(logQ),1);
badfit = 0;

while sum(flag>0)
     % %robust linear regressions
    % %w
    mdl_w = fitlm(logQ,logw,'RobustOpts','on')
    b = mdl_w.Coefficients{2,1};
    loga = mdl_w.Coefficients{1,1};
    flag = isoutlier(mdl_w.Residuals.Raw);

    %d
    mdl_d = fitlm(logQ,logd,'RobustOpts','on')
    f = mdl_d.Coefficients{2,1};
    logc = mdl_d.Coefficients{1,1};
%     sum(isoutlier(mdl_d.Residuals.Raw))
    flag = flag + isoutlier(mdl_d.Residuals.Raw);

    %v
    mdl_v = fitlm(logQ,logv,'RobustOpts','on')
    m = mdl_v.Coefficients{2,1};
    logk = mdl_v.Coefficients{1,1};
%     sum(isoutlier(mdl_v.Residuals.Raw))
    flag = flag + isoutlier(mdl_v.Residuals.Raw);
    
%     test plot
    figure;
    set(gcf,'position',[10,10,10000,2500])
    
    subplot(1,3,1)
    hold on;
    scatter(logQ,logv,'filled','MarkerFaceColor','b')
    scatter(logQ(flag>0),logv(flag>0),'filled','MarkerFaceColor','b')
    plot(logQ,logk+m.*logQ,'LineWidth',2)
    xlabel('log(Q)')
    ylabel('log(v)')
    set(gca,'fontsize',12)
    
    subplot(1,3,2)
    hold on;
    scatter(logQ,logw,'filled','MarkerFaceColor','b')
    scatter(logQ(flag>0),logw(flag>0),'filled','MarkerFaceColor','b')
    plot(logQ,loga+b.*logQ,'LineWidth',2)
    xlabel('log(Q)')
    ylabel('log(w)')
    set(gca,'fontsize',12)
    
    subplot(1,3,3)
    hold on;
    scatter(logQ,logd,'filled','MarkerFaceColor','b')
    scatter(logQ(flag>0),logd(flag>0),'filled','MarkerFaceColor','b')
    plot(logQ,logc+f.*logQ,'LineWidth',2)
    xlabel('log(Q)')
    ylabel('log(d)')
    set(gca,'fontsize',12)

    %remove flagged values
    logQ(flag>0) = [];
    logv(flag>0) = [];
    logw(flag>0) = [];
    logd(flag>0) = [];
    stn_Q(flag>0) = [];
    stn_v(flag>0) = [];
    stn_w(flag>0) = [];
    stn_d(flag>0) = [];
    
    %check if still greater than 10 measurements
    if length(stn_Q)<10
        badfit = 2;
        flag = 0;
    end
    
    %assemble p-Value vector
    pVec = [mdl_d.Coefficients.pValue(2) mdl_v.Coefficients.pValue(2)...
        mdl_w.Coefficients.pValue(2)];
    flag_pval = sum(pVec>0.05);
    if flag_pval>0
        badfit = 1;
        flag = 0;
    end
    
    
end

% index = 1:length(logw);
% 
% figure;
% subplot(1,4,1)
% hold on;
% scatter(index,logw)
% scatter(index(out_lw==1),logw(out_lw==1),'filled')
% ylabel('logw')
% subplot(1,4,2)
% hold on;
% scatter(index,logd)
% scatter(index(out_ld==1),logd(out_ld==1),'filled')
% ylabel('logd')
% subplot(1,4,3)
% hold on;
% scatter(index,logv)
% scatter(index(out_lv==1),logv(out_lv==1),'filled')
% ylabel('logv')
% subplot(1,4,4)
% hold on;
% scatter(index,logQ)
% scatter(index(out_lQ==1),logQ(out_lQ==1),'filled')
% ylabel('logQ')
% 
% if we fall below 10 measurements, abort
if length(logQ)<10
    abcfkm = NaN.*zeros(1,6);
    pVec = NaN;
else

   
    %unlog a,c,k
    a = 10^loga;
    c = 10^logc;
    k = 10^logk;

    %assemble output vector
    abcfkm = [a b c f k m];

    
end
end


