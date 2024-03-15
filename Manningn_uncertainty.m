% script to calculate uncertainty in Manning n estimates.  We take
% uncertainty to be the average distance from the Manning n measurements to
% the idealized Manning n curve calculated from the hydraulic geometry

function [rmsd] = Manningn_uncertainty(nVec,stn_ID,stn_Q,threshold)


%load theoretical data
load('LinearCoefficients_logQlogn_Qptile1yr.mat','x','b','ID_out')


%log-transform measured n,Q
logn_meas = log10(nVec);
logQ_meas = round(log10(stn_Q),2);


%linear model for the given station
ind_ID = strcmp(ID_out,stn_ID);
if sum(ind_ID)==0
    rmsd = NaN;
else
    stn_x = x(ind_ID==1);
    stn_b = b(ind_ID==1);
    Qmax = max(logQ_meas);
    Qmin = min(logQ_meas);
    logQ_th = Qmin:0.01:Qmax;
    logQ_th = round(logQ_th,2);
    logn_th = (logQ_th.*stn_x)+stn_b;
    % stn_x
    % stn_b
    %calculate distance from each derived n to the theoretical n at the same Q
    %value
    % length(logQ_meas)
    % logQ_meas
    vec_d = zeros(length(logn_meas),1);
    for ii = 1:length(logn_meas)
    %     logQ_meas(ii)
        ind = logQ_th==logQ_meas(ii);
    %     length(ind)
    %     logn_th
        n_t = logn_th(ind==1);
        diff = n_t - logn_meas(ii);
        vec_d(ii) = diff;
    end

    %get RMSD
    logrmsd = sqrt(nanmean(vec_d.^2));
    rmsd = 10.^logrmsd;
end
% %insert n measurements into a vector the same length as theoretical Q
% %vector (w/ place holder NaN's)
% ind_n = ismember(logQ_th,logQ_meas);
% test_n = NaN.*zeros(length(logQ_th));
% test_n(ind_n==1) = logn_meas;

%test plot first
% figure;
% hold on;
% plot(logQ_th,logn_th)
% scatter(logQ_meas,logn_meas)
% xlabel('logQ')
% ylabel('logn')
% title(stn_ID)
% set(gca,'fontsize',14)
% 
% figure;
% hold on;
% plot(10.^logQ_th,10.^logn_th)
% scatter(10.^logQ_meas,10.^logn_meas)
% xlabel('Q')
% ylabel('n')
% title(stn_ID)
% set(gca,'fontsize',14)

% uncertainty = 1;

end