%%%% Dynamic Patient Effort

function fit=dynpateffort_fit(x,P,beta,Pr)
 
     %%% person 1
     
     valuepat=dynpateffort(x,P,beta,Pr);
     
     fit1=Pr(1)-(1/(1+exp(x(1)-x(2)*P(1)+beta*valuepat(2))));
     fit2=Pr(2)-(1/(1+exp(x(1)-x(2)*P(2)+beta*valuepat(3))));
     fit3=Pr(3)-(1/(1+exp(x(1)-x(2)*P(3)+beta*valuepat(4))));
     fit4=Pr(4)-(1/(1+exp(x(1)-x(2)*P(4)+beta*valuepat(1))));
     
     
     fit=(fit1^2+fit2^2+fit3^2+fit4^2);
     
     
end

        