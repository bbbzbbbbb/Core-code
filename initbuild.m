function gp=initbuild(gp)
popSize = gp.runcontrol.pop_size;
maxNodes = gp.treedef.max_nodes;
maxGenes = gp.genes.max_genes;
if ~gp.genes.multigene
    maxGenes = 1;
end
gp.pop = cell(popSize,1);
popsize = popSize;
numGenes = 1;
k=0;
p=1;
while p<=popsize+1 
    if maxGenes > 1
        numGenes = ceil(rand*maxGenes);
    individ = cell(1,(numGenes)); 
    for z = 1:numGenes 
        geneLoopCounter = 0;
        while true
            geneLoopCounter = geneLoopCounter + 1;
            temp = treegen(gp);
            numnodes = getnumnodes(temp);
            if numnodes <= maxNodes
                copyDetected = false;
                if z > 1 
                    
                    for j = 1:z-1
                        if strcmp(temp,individ{1,j})
                            copyDetected = true;
                            break
                        end
                    end
                    
                end
                
                if ~copyDetected
                    break
                end
            end    
        end 
        individ{1,z} = temp;
    end 
    k=0;
    pop1{p,1} = individ;
    if isnumeric(pop1{p,1})
        pop1{p,1} = num2str(pop1{p,1});
    end
    for m = 1:p-1
        if contains(cellstr(pop1{p,1}),cellstr(pop1{m,1})) 
            k = 1;
            break;
        else
            if contains(cellstr(pop1{m,1}),cellstr(pop1{p,1}))
                k = 1;
                break;
            else
                if numel(cellstr(pop1{p,1})) == numel(cellstr(pop1{m,1}))
                    if strcmp(cellstr(pop1{p,1}),cellstr(pop1{m,1}))
                        k = 1;
                        break;
                    else
                        k = 0;
                    end
                end
            end
        end
    end
    p = p-k;
    if k==0
        gp.pop{p,1} = individ;
        disp(individ);
    else
        popSize = popSize+1;
    end
    p = p+1;
end
end