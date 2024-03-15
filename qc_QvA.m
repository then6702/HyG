%function to weed out measurements where Q ~= vA

function [Q_qc,A_qc,w_qc,d_qc,v_qc,dist_qc,ID_qc,date_qc,meas_no_qc,flagStn] = ...
    qc_QvA(Q,A,w,d,v,dist,ID,date,meas_no,threshold)

vA_flag = zeros(size(ID));
Q_vA = v.*A;
Q_vA_frac = ((Q - Q_vA)./Q_vA).*100;

for ii = 1:length(ID)
    if Q_vA_frac(ii) > threshold
        vA_flag(ii) = 1;
    end
end

% %remove stations that do not make the cut
A_qc = A(vA_flag==0);
d_qc = d(vA_flag==0);
v_qc = v(vA_flag==0);
w_qc = w(vA_flag==0);
Q_qc = Q(vA_flag==0);
dist_qc = dist(vA_flag==0);
ID_qc = ID(vA_flag==0);
meas_no_qc = meas_no(vA_flag==0);
date_qc = date(vA_flag==0);

flagStn = ID(vA_flag==1);

    %special case for 1st iteration
%     if ii == 1
%         %increment measurement counter
%         counter_measNo = counter_measNo + 1;
%         %increment velocity counter if there is a velocity measurement
%         if ~isnan(v(ii))
%             counter_velocity = counter_velocity + 1;            
%         end
%         
%         %add index to index vector
%         stn_index = [stn_index; ii];
        
    %case for progression to next station
%     if ID(ii)~=ID(ii-1)
%         station_counter = station_counter + 1
%    
%         %flag station if thresholds are not met
%         if counter_measNo<threshold || counter_velocity<threshold
%             index_flag(stn_index) = 1;
%         end
% 
%         %re-initialize index vector
%         stn_index = ii;
%         
%         %re-start counters
%         counter_measNo = 1;
%         if ~isnan(v(ii))
%             counter_velocity = 1;
%         else 
%             counter_velocity = 0;
%         end
%         
%     %case for w/in station measurements
%     elseif ID(ii)==ID(ii-1)
%         
%         %increment counters as needed 
%         counter_measNo = counter_measNo + 1;
%         if ~isnan(v(ii))
%             counter_velocity = counter_velocity + 1;            
%         end
%         
%         %continue building index vector
%         stn_index = [stn_index; ii];
%     end
% end
% station_counter = station_counter + 1
% 
% 
% 
