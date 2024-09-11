clc;
clear all;
CostFunction=@(x)fitness(x); 
nVar =; 
nVar =[1 nVar]; 
VarMin=;
VarMax=;
MaxIt=; 
nPop=; 
nOnlooker=nPop; 
L=round(0.6*nVar*nPop);
a=1; 
empty_bee.Position=[];
empty_bee.Cost=[];
pop=repmat(empty_bee,nPop,1);
BestSol.Cost=inf;
for i = 1:nPop
    pop(i).Position = unifrnd(VarMin,VarMax,VarSize);
    pop(i).Cost = CostFunction(pop(i).Position);
    if pop(i).Cost<=BestSol.Cost 
        BestSol = pop(i);
    end
end
C = zeros(nPop,1);
BestCost = zeros(MaxIt,1);
for it = 1:MaxIt
    for i = 1:nPop
        K = [1:i-1 i+1:nPop]; 
        k = K(randi([1 numel(K)])); 
        phi = a*unifrnd(-0.1,+0.1,VarSize); 
        newbee.Position=pop(i).Position+phi.*(pop(i).Position-pop(k).Position); 
        newbee.Cost = CostFunction(newbee.Position);
        if newbee.Cost<=pop(i).Cost 
            pop(i)=newbee; 
        else
            C(i) = C(i)+1;
        end
    end
    F=zeros(nPop,1);
    MeanCost = mean([pop.Cost]);
    for i = 1:nPop
        F(i) = exp(-pop(i).Cost/MeanCost);
    end
    P = F/sum(F);

    for m=1:Onlooker
        i = RouletteWheelSelection(P);
        K = [1:i-1 i+1:nPop];
        k = K(randi([1 numel(K)]));
        phi = a*unifrnd(-0.1,0.1,VarSize);
        newbee.Cost = CostFunction(newbee.Position);
        if newbee.Cost<=pop(i).Cost
            pop(i)=newbee;
        else
            C(i) = C(i)+1;
        end
    end
    for i=1:nPop
        if C(i)>=L
            pop(i).Position = unifrnd(VarMin, VarMax,Varsize);
            pop(i).Cost = CostFunction(pop(i).Position);
            C(i) = 0;
        end
    end
    BestCost(it) = BestSol.Cost;
end





