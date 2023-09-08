%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Simulate LOS for Private and Medicaid beneficiairies

% time window T
% Number of individuals Nsim

%T=1000;
%Numsim=1000000;

% Private

In_priv=ones(Numsim,1)'; %%% still in NHome
LOS_priv=ones(Numsim,1)'; %%% cumulated number of weeks


In_hyb=ones(Numsim,1)'; %%% still in NHome
LOS_hyb=ones(Numsim,1)'; %%% cumulated number of weeks
Pr_hyb=zeros(Numsim,1)'; %%% cumulated number of weeks

In_med=ones(Numsim,1)'; %%% still in NHome
LOS_med=ones(Numsim,1)'; %%% cumulated number of weeks

%occu_priv=zeros(NSim,1)'; 

%occushock=rand(Numsim,1); %%% occupancy shock 
occushock=occushockt;

[~, occu_markerpost]=min(abs(occupSteadyPartCdf' - rand(Numsim,1)),[],2);
occu_priv = occupPart(occu_markerpost); %%% occupancy at beginning of period

for t=1:T
    
  occu_marker=occu_markerpost;
 %dis=rand(Numsim,1)<=Pr_priv(occu_marker); 
 dis=simu_shock1(:,t)<=Pr_priv(occu_marker); 
 In_priv(dis==1)=0;
 LOS_priv=LOS_priv+In_priv;   
 
 
 %%% payer type switch
 
 dishyb=simu_shockhyb(:,t)<=psi(1); 
 In_hyb(dishyb==1)=0;
 hybpriv=[transpose(In_hyb),transpose(In_priv)];
 
 %%% LOS preceding transition
 LOS_hyb=LOS_hyb+transpose(min(hybpriv,[],2));   
 
 %%% Pr ever transiton
 Pr_hyb(In_priv==1 & In_hyb==0)=1;
 
 
 %%% occupancy transition
 %[~, occu_marker] = min(abs(occupTransPartCdf(occu_marker, :) - rand(Numsim,1)),[],2);
 [~, occu_markerpost] = min(abs(occupTransPartCdf(occu_marker, :) - simu_shock2(:,t)),[],2);
 for i=1:Numsim
 if occupTransPartCdf(occu_marker(i),occu_markerpost(i)) - simu_shock2(i,t)<0 & occu_markerpost(i)<25
     occu_markerpost(i)=occu_markerpost(i)+1;
 end
 end
 
 occu_priv = occupPart(occu_markerpost); %%% occupancy at beginning of period
end

[~, occu_markerpost]=min(abs(occupSteadyPartCdf' - rand(Numsim,1)),[],2);
occu_med = occupPart(occu_markerpost); %%% occupancy at beginning of period

for t=1:T
    occu_marker=occu_markerpost;
 %dis=rand(Numsim,1)<=Pr_med(occu_marker); 
 dis=simu_shock3(:,t)<=Pr_med(occu_marker); 
 In_med(dis==1)=0;
 LOS_med=LOS_med+In_med;   
 
 %%% occupancy transition
 
 %[~, occu_marker] = min(abs(occupTransPartCdf(occu_marker, :) - rand(Numsim,1)),[],2);
 %[~, occu_marker] = min(abs(occupTransPartCdf(occu_marker, :) - simu_shock4(:,t)),[],2);
  [~, occu_markerpost] = min(abs(occupTransPartCdf(occu_marker, :) - simu_shock4(:,t)),[],2);
 for i=1:Numsim
 if occupTransPartCdf(occu_marker(i),occu_markerpost(i)) - simu_shock4(i,t)<0 & occu_markerpost(i)<25
     occu_markerpost(i)=occu_markerpost(i)+1;
 end
 end
 occu_med = occupPart(occu_markerpost); %%% occupancy at beginning of period
end

