%%%% Medicaid transition shocks

simu_shockhyb = rand(nSim,T);

Pr_priv = ones(nOccupPart, 1) * beta * mean(max((beta * (kappa * ...
        price(1) - utility(1) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0))+mu(1);
    
Pr_med = ones(nOccupPart,1) * beta * mean(max((beta * (kappa * ...
        price(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0)) + alpha * effortsnf(11:35)+mu(2);   
    
run('endo_occupancy_06.m')
run('simulateloshybrid_07.m')

LOStable_rob=zeros(5,8);

LOStable_rob(1,1) = mean(LOS_priv);
LOStable_rob(2,1) = mean(LOS_med);
LOStable_rob(4,1) = mean(LOS_hyb)+mean(Pr_hyb)*mean(LOS_med);
LOStable_rob(5,1) = mean(LOS_hyb);

% effort = (0.00:0.00001:0.02);
effort=(0.00:0.01:1.99);
phieffort_count = vertcat(zeros(10, 1), phiPart);

price_cf = price;
revenue_cf = revenue;

patient_elasticities=zeros(4,Runs);

for n = 1:Runs    
% patient elasticity
priceNew(1) = price(1) * 1.01;
priceNew(2) = price(2);


Pr_priv = ones(nOccupPart, 1) * beta * mean(max((beta * (kappa * ...
        priceNew(1) - utility(1) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa * gamma3), 0))+mu(1);
    
Pr_med = ones(nOccupPart,1) * beta * mean(max((beta * (kappa * ...
        priceNew(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa * gamma3), 0)) + alpha * effortsnf(11:35)+mu(2);   

        run('simulateloshybrid_07.m')

LOStable(1,2) = mean(LOS_priv);
LOStable(2,2) = mean(LOS_med);
LOStable(4,2) = mean(LOS_hyb)+mean(Pr_hyb)*LOStable(2,1);
LOStable(5,2) = mean(LOS_hyb);

patient_elast1=(LOStable(1,1)-LOStable(1,2))/(LOStable(1,1)/2+LOStable(1,2)/2)/0.01;
patient_elast2=(LOStable(3,1)-LOStable(3,2))/(LOStable(3,1)/2+LOStable(3,2)/2)/0.01;
patient_elast3=(LOStable(3,1)-LOStable(3,2))/(LOStable(3,1)/2+LOStable(3,2)/2)/(0.01*LOStable(4,1)/LOStable(1,1));


        patient_elasticities(1,n)=patient_elast1;
        patient_elasticities(2,n)=patient_elast2;
        patient_elasticities(3,n)=patient_elast3;

end

price_cf = price;
%%% Medicaid OOP costs
price_cf(2) = 5/4;

Pr_priv = ones(nOccupPart, 1) * beta * mean(max((beta * (kappa * ...
        price_cf(1) - utility(1) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0))+mu(1);
    
Pr_med = ones(nOccupPart,1) * beta * mean(max((beta * (kappa * ...
        price_cf(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0)) + alpha * effortsnf(11:35)+mu(2);   

%run('../../../code/3_structural/endo_occupancy_06.m')
run('simulateloshybrid_07.m')

LOStable_rob=zeros(5,8);

LOStable_rob(1,1) = mean(LOS_priv);
LOStable_rob(2,1) = mean(LOS_med);
LOStable_rob(4,1) = mean(LOS_hyb)+mean(Pr_hyb)*mean(LOS_med);
LOStable_rob(5,1) = mean(LOS_hyb);

for n = 1:Runs    
% patient elasticity
priceNew(1) = price_cf(1);
priceNew(2) = price_cf(2)*1.1;


Pr_priv = ones(nOccupPart, 1) * beta * mean(max((beta * (kappa * ...
        priceNew(1) - utility(1) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa * gamma3), 0))+mu(1);
    
Pr_med = ones(nOccupPart,1) * beta * mean(max((beta * (kappa * ...
        priceNew(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa * gamma3), 0)) + alpha * effortsnf(11:35)+mu(2);   

        run('simulateloshybrid_07.m')

LOStable_rob(1,2) = mean(LOS_priv);
LOStable_rob(2,2) = mean(LOS_med);
LOStable_rob(4,2) = mean(LOS_hyb)+mean(Pr_hyb)*mean(LOS_med);
LOStable_rob(5,2) = mean(LOS_hyb);

patient_elast4=(LOStable(2,1)-LOStable(2,2))/(LOStable(2,1)/2+LOStable(2,2)/2)/0.1;


        patient_elasticities(4,n)=patient_elast4;

end

csvwrite('elasticities_robustness.csv', patient_elasticities)
