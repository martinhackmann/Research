%%%% Dynamic Patient Effort

function solutionpat=dynpateffort(x,P,beta,Pr)
 
    valuepat=zeros(4,1);
    valuepatold=zeros(4,1);
    
    tol = 1e-8;
    metric = tol + 1000;
    
    while metric > tol
        
        valuepat(1)=log(exp(x(1)-x(2)*P(1)+beta*valuepatold(2))+1) + 0.577;
        valuepat(2)=log(exp(x(1)-x(2)*P(2)+beta*valuepatold(3))+1) + 0.577;
        valuepat(3)=log(exp(x(1)-x(2)*P(3)+beta*valuepatold(4))+1) + 0.577;
        valuepat(4)=log(exp(x(1)-x(2)*P(4)+beta*valuepatold(1))+1) + 0.577;
        
        metric = max(abs(valuepatold-valuepat));
        
        valuepatold = valuepat;
      
         end

solutionpat = [valuepat];
end

        