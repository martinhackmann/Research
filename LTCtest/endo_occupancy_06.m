%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Calculate endogenous occupancy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

occup_endo=zeros(size(occupTransCdf));

stead=5000;

occumarkerpost=27;
priv_post=25;
mcaid_post=25;

for t=1:sw

   % occ_all=occtemp_all
   priv_sample=priv_post;
   mcaid_sample=mcaid_post;
   otherbeds=otherbeds_post;
   %occtemp_lim=occtemppost-11;
   occumarker=occumarkerpost;
   
   % payer type transitions;
   
   transitions=sum(trans_shock_sample(1:priv_sample,t)<0.011);
   priv_sample=priv_sample-transitions;
   mcaid_sample=mcaid_sample+transitions;
   
   
   % non_sample=non;

   % arrivals
   
   [~, arrtempall] = min(abs(arrivCDF - arrivaldraw(t)));
   
   % payertypes
   
   priv=sum(payertypedraw(1:(arrtempall-1),t)<0.723);
   
   
   priv_post=priv_sample+priv;
   mcaid_post=mcaid_sample+(arrtempall-1-priv);
   
   % capacity cap (for coding tractability)
   
   mcaid_post=min(mcaid_post,beds-priv_post);
   
   % discharges
   
   dis_priv=sum(dis_shock_sample(1:priv_post,t)<(Pr_priv_extra(occumarker)));
   dis_mcaid=sum(dis_shock_sample((priv_post+1):(priv_post+mcaid_post),t)<(Pr_med_extra(occumarker)));
   
   priv_post=priv_post-dis_priv;
   mcaid_post=mcaid_post-dis_mcaid;
   
   % occupancy updates

   otherbeds_post=otherbedshist(t);
  
   
   occupancy_temp=(otherbeds_post+priv_post+mcaid_post)/beds;
   
   occumarkerpost=min(max(occupancy_temp*100-63,1),35);
   
   occuphist(t)=occupancy_temp;
   %occupancyhist2(t)=occup(occumarkerpost);
   
  if t>stead 
      %obed_transCDF(otherbeds,otherbeds_post)=obed_transCDF(otherbeds,otherbeds_post)+1;
      occup_endo(occumarker,occumarkerpost)=occup_endo(occumarker,occumarkerpost)+1;
  end 
end

for i = 1:size(occup_endo, 1)
occup_endo(i,:)=occup_endo(i,:)/max(sum(occup_endo(i,:)),1);
end

occup_endo_CDF = zeros(size(occup_endo));
for i = 1:size(occup_endo, 1)
    occup_endo_CDF(i, 1) = occup_endo(i, 1);
    for j = 2:size(occup_endo, 2)
        occup_endo_CDF(i, j) = occup_endo_CDF(i, j-1) + occup_endo(i, j);
    end
end

%%%% Partititioned

occup_endo_Part = occup_endo(11:nOccup, 11:nOccup);

% CDF of occupancy transitions for each current occupancy rate

occup_endo_PartCdf = zeros(size(occup_endo_Part));
for i = 1:size(occup_endo_Part, 1)
    occup_endo_PartCdf(i, 1) = occup_endo_Part(i, 1);
    for j = 2:size(occup_endo_Part, 2)
        occup_endo_PartCdf(i, j) = occup_endo_PartCdf(i, j-1) + occup_endo_Part(i, j);
    end
end


