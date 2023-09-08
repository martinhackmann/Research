%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Mapping discharges and arrivals into transition matrices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

otherbedshist=zeros(1, sw);

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

   [~, occumarkerpost]= min(abs(occupTransCdf(occumarker, :) - simu_shock_occ(t)),[],2);
   if occupTransCdf(occumarker,occumarkerpost) - simu_shock_occ(t)<0
   occumarkerpost=occumarkerpost+1;
   end
   
   if occumarkerpost > 35
       occumarkerpost = 35;
   end
   
   otherbeds_post=max(round(beds*occup(occumarkerpost))-priv_post-mcaid_post,1);
   
   otherbedshist(t)=otherbeds_post;
   
end

