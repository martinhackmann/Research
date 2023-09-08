% Consumer Dynamics Around Cost-Sharing

clear;

bunching=zeros(11,7);
bunching(1,:)=[ 0 0 0 0.95^(1/52) 0.95^(1/52) 0.95^(1/52)  0];
bunching(2:5,2)=[ 1 0 0 0];
bunching(2:5,5)=[ 1 0 0 0];
bunching(2:5,1)=[1 24.32/86.89 13.48/86.89 11.76/86.89];
bunching(2:5,4)=[1 24.32/86.89 13.48/86.89 11.76/86.89];
bunching(2:5,3)=[1 52.07/54.69 16.95/54.69 12.75/54.69];
bunching(2:5,6)=[1 52.07/54.69 16.95/54.69 12.75/54.69];

Pr = [0.216 0.178 0.176 0.176];
Pr=(Pr/(sum(Pr))*4*0.017)+0.015;

bunching(6:9,7)=Pr


for t=1:6
    
P = bunching(2:5,t)';    
beta=bunching(1,t);   


valuepat=zeros(4,1);

%%% starting values

delta=-1; 

alpha=0.01;

x=[-1 0.01];

valuecheck=dynpateffort(x,P,beta,Pr);

fitcheck=dynpateffort_fit(x,P,beta,Pr);

fit_x = @(x)dynpateffort_fit(x,P,beta,Pr);

x0=[-1,0.01];

xhat=fminsearch(fit_x,x0);
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%

valuehat=dynpateffort(xhat,P,beta,Pr);

Prhat(1)=(1/(1+exp(xhat(1)-xhat(2)*P(1)+beta*valuehat(2))));
Prhat(2)=(1/(1+exp(xhat(1)-xhat(2)*P(2)+beta*valuehat(3))));
Prhat(3)=(1/(1+exp(xhat(1)-xhat(2)*P(3)+beta*valuehat(4))));
Prhat(4)=(1/(1+exp(xhat(1)-xhat(2)*P(4)+beta*valuehat(1))));

bunching(6:9,t)=Prhat;

bunching(10,t)=(abs(Prhat(1)-Pr(1))^2+abs(Prhat(2)-Pr(2))^2+abs(Prhat(3)-Pr(3))^2+abs(Prhat(4)-Pr(4))^2)*10000;

%%%%%%%%%%%%%
%% Counterfactuals and Elasticities
%%%%%%%%%%%%%

Pflat=P;


Valueflat=dynpateffort(xhat,Pflat,beta,Pr);

Prflat(1)=(1/(1+exp(xhat(1)-xhat(2)*Pflat(1)+beta*Valueflat(2))));
Prflat(2)=(1/(1+exp(xhat(1)-xhat(2)*Pflat(2)+beta*Valueflat(3))));
Prflat(3)=(1/(1+exp(xhat(1)-xhat(2)*Pflat(3)+beta*Valueflat(4))));
Prflat(4)=(1/(1+exp(xhat(1)-xhat(2)*Pflat(4)+beta*Valueflat(1))));

Prflat

%%%% LOS up too 100 weeks

LOStable=zeros(100,2);
LOStable(:,1)=[1:1:100];

for j = 1:100 
LOStable(j,2)=Prflat(1)*(1-Prflat(1))^(LOStable(j,1)-1)*LOStable(j,1) ;
end

LOS=sum(LOStable(:,2));


%%%% Now increase price by 10%

Pflatc=Pflat*1.10;

Valueflatc=dynpateffort(xhat,Pflatc,beta,Pr);

Prflatc(1)=(1/(1+exp(xhat(1)-xhat(2)*Pflatc(1)+beta*Valueflatc(2))));
Prflatc(2)=(1/(1+exp(xhat(1)-xhat(2)*Pflatc(2)+beta*Valueflatc(3))));
Prflatc(3)=(1/(1+exp(xhat(1)-xhat(2)*Pflatc(3)+beta*Valueflatc(4))));
Prflatc(4)=(1/(1+exp(xhat(1)-xhat(2)*Pflatc(4)+beta*Valueflatc(1))));

%%%%%%%%%%%%

LOStable=zeros(100,2);
LOStable(:,1)=[1:1:100];

for j = 1:100 
LOStable(j,2)=Prflatc(1)*(1-Prflatc(1))^(LOStable(j,1)-1)*LOStable(j,1) ;
end

LOSc=sum(LOStable(:,2));


elastnum=(LOSc-LOS)/LOS;

elastbase=(Pflatc(1)-Pflat(1))/Pflat(1);

elasticity=elastnum/elastbase

bunching(11,t)=-elasticity;

end    



%%% which discount factor predicts data best?


nodes=5;

support=zeros(nodes,4);
support(:,1)=linspace(0,0.999,nodes);

for j=2:4
for t=1:nodes

P = bunching(2:5,j-1)';    
beta=support(t,1);   


valuepat=zeros(4,1);

%%% starting values

delta=-1; 

alpha=0.01;

x=[-1 0.01];

valuecheck=dynpateffort(x,P,beta,Pr);

fitcheck=dynpateffort_fit(x,P,beta,Pr);

fit_x = @(x)dynpateffort_fit(x,P,beta,Pr);

x0=[-1,0.01];

xhat=fminsearch(fit_x,x0);
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%

valuehat=dynpateffort(xhat,P,beta,Pr);

Prhat(1)=(1/(1+exp(xhat(1)-xhat(2)*P(1)+beta*valuehat(2))));
Prhat(2)=(1/(1+exp(xhat(1)-xhat(2)*P(2)+beta*valuehat(3))));
Prhat(3)=(1/(1+exp(xhat(1)-xhat(2)*P(3)+beta*valuehat(4))));
Prhat(4)=(1/(1+exp(xhat(1)-xhat(2)*P(4)+beta*valuehat(1))));

%%%bunching(6:9,t)=Prhat;

support(t,j)=(abs(Prhat(1)-Pr(1))^2+abs(Prhat(2)-Pr(2))^2+abs(Prhat(3)-Pr(3))^2+abs(Prhat(4)-Pr(4))^2)*10000;

end
end


%%% reorganize rows for table

rowsb=[1 5 2 3 4 9 6:8 10:11];

bunching=bunching(rowsb, :);

BigT=table(round(bunching(:,7),4),round(bunching(:,1),4),round(bunching(:,2),4),round(bunching(:,3),4),round(bunching(:,4),4),round(bunching(:,5),4),round(bunching(:,6),4),'VariableNames',{'Data','StaticEoW','StaticFoM','StaticCC','DynamicEoW','DynamicFoM','DynamicCC'})

writetable(BigT,'TableE2.xlsx','Sheet',1);

%%%% Plot


dp = figure;
plot(support(:,1), support(:,2), 'LineStyle', '--', 'Color', 'black', 'LineWidth', 3)
hold on;
plot(support(:,1), support(:,3), 'LineStyle', '-.', 'Color', 'blue', 'LineWidth', 2)
plot(support(:,1), support(:,4), 'LineStyle', '-', 'Color', 'red', 'LineWidth', 2)
hold off;
xlabel('Weekly Discount Factor', 'FontSize', 16)
ylabel('Model Fit: Mean Squared Error', 'FontSize', 16)
legend({'End-of-Week Charges', 'First-of-Month Charges', 'Concurrent Charges'}, 'location', 'northwest', 'FontSize', 16)
xt = get(gca, 'XTick');
set(gca, 'FontSize', 16)
set(dp, 'Units', 'Inches')
pos = get(dp, 'Position');
%lgd = legend;
%lgd.NumColumns = 1 ;
set(dp, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', ...
    [pos(3), pos(4)])
    print(dp, 'FigureE11', '-dpdf', '-r0')



