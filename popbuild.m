function gp = popbuild(gp)
newPop = cell(gp.runcontrol.pop_size,1);
xrank1 = ndfsort_rank1([gp.fitness.values gp.fitness.complexity]);
num2skim = sum(xrank1==1);
for g=1:num2skim
    bestInds = find(xrank1==1);
    oldIndex = bestInds(g);
    newIndex = g;
    copiedIndividual = gp.pop{oldIndex,1};
        newPop{newIndex,1} = copiedIndividual;
end
num2build = gp.runcontrol.pop_size - num2skim;
p_mutate = gp.operators.mutation.p_mutate;
p_direct = gp.operators.directrepro.p_direct;
maxDepth = gp.treedef.max_depth;
max_nodes = gp.treedef.max_nodes;
p_cross_hi = gp.genes.operators.p_cross_hi;
crossRate = gp.genes.operators.hi_cross_rate;
useMultiGene = gp.genes.multigene;
pmd = p_mutate + p_direct;
maxNodesInf = isinf(max_nodes);
maxGenes = gp.genes.max_genes;
if gp.runcontrol.usecache
    remove(gp.fitness.cache,gp.fitness.cache.keys);
gp.state.count = gp.state.count + 1;
buildCount = g;
while buildCount < num2build+g  
    buildCount = buildCount + 1;
    p_gen = rand;
    if p_gen < p_mutate  
        eventType = 1;
    elseif p_gen < pmd   
        eventType = 2;
    else                
        eventType = 3;
    end
    if eventType == 1 
        parentIndex = selection(gp); 
        parent = gp.pop{parentIndex}; 
        if useMultiGene 
            numParentGenes = numel(parent);
            targetGeneIndex = ceil(rand * numParentGenes); 
            targetGene = parent{1,targetGeneIndex}; 
        else
            targetGeneIndex = 1;
            targetGene = parent{1}; 
        end
        
        mutateSuccess = false;
        for loop = 1:10	
            mutatedGene = mutate(targetGene,gp); 
            mutatedGeneDepth = getdepth(mutatedGene); 
            if mutatedGeneDepth <= maxDepth
                
                if maxNodesInf
                    mutateSuccess = true;
                    break;
                end
                
                mutatedGeneNodes = getnumnodes(mutatedGene);
                if mutatedGeneNodes <= max_nodes
                    mutateSuccess = true;
                    break;
                end
            end   
        end  
        if ~mutateSuccess
            mutatedGene = targetGene; 
        end
        parent{1,targetGeneIndex} = mutatedGene;
        newPop{buildCount,1} = parent;
    elseif eventType == 2 
        parentIndex = selection(gp); 
        parent = gp.pop{parentIndex};
        newPop{buildCount} = parent;
        if gp.runcontrol.usecache
            cachedData.complexity = gp.fitness.complexity(parentIndex,1);
            cachedData.returnvalues = gp.fitness.returnvalues{parentIndex,1};
            cachedData.value = gp.fitness.values(parentIndex,1);
            gp.fitness.cache(buildCount) = cachedData;
        end
    elseif eventType == 3 
        highLevelCross = false;
        if useMultiGene
            if rand < p_cross_hi
                highLevelCross = true;
            end  
        end
        parentIndex = selection(gp);
        dad = gp.pop{parentIndex};
        numDadGenes = numel(dad);
        
        parentIndex = selection(gp);
        mum = gp.pop{parentIndex};
        numMumGenes = numel(mum);
        
        if highLevelCross
            if numMumGenes>1 || numDadGenes>1 
                dadGeneSelectionInds = rand(1,numDadGenes) < crossRate;
                mumGeneSelectionInds = rand(1,numMumGenes) < crossRate;
                if ~any(dadGeneSelectionInds)
                    dadGeneSelectionInds(1,ceil(numDadGenes *rand)) = true;
                end
                if ~any(mumGeneSelectionInds)
                    mumGeneSelectionInds(1,ceil(numMumGenes *rand)) = true;
                end
                
                dadSelectedGenes = dad(dadGeneSelectionInds);
                mumSelectedGenes = mum(mumGeneSelectionInds);
                
                dadRemainingGenes = dad(~dadGeneSelectionInds);
                mumRemainingGenes = mum(~mumGeneSelectionInds);
                
                mumOffspring = [mumRemainingGenes dadSelectedGenes];
                dadOffspring = [dadRemainingGenes mumSelectedGenes];
                newPop{buildCount,1} = mumOffspring(1:(min(end,maxGenes)));
                buildCount = buildCount+1;
                
                if buildCount <= num2build+g
                    newPop{buildCount,1} = dadOffspring(1:(min(end,maxGenes)));
                end
                
            else
                highLevelCross = false;
            end
        end
        if ~highLevelCross
            
            if useMultiGene 
                dad_target_gene_num = ceil(rand*numDadGenes); 
                mum_target_gene_num = ceil(rand*numMumGenes); 
                dad_target_gene = dad{1,dad_target_gene_num};
                mum_target_gene = mum{1,mum_target_gene_num};
            else
                dad_target_gene_num = 1;
                mum_target_gene_num = 1;
                dad_target_gene = dad{1};
                mum_target_gene = mum{1};
            end
            for loop = 1:10  
                [son,daughter] = crossover(mum_target_gene,dad_target_gene,gp);
                son_depth = getdepth(son);
                crossOverSuccess = false;
                if son_depth <= maxDepth
                    daughter_depth = getdepth(daughter);
                    if daughter_depth <= maxDepth
                        
                        if maxNodesInf
                            crossOverSuccess = true;
                            break;
                        end
                        
                        son_nodes = getnumnodes(son);
                        if son_nodes <= max_nodes
                            daughter_nodes = getnumnodes(daughter);
                            if  daughter_nodes <= max_nodes
                                crossOverSuccess = true;
                                break;
                            end
                        end
                    end
                end
                
            end
            if ~crossOverSuccess
                son = dad_target_gene;
                daughter = mum_target_gene;
            end

            dad{1,dad_target_gene_num} = son;
            newPop{buildCount} = dad;
            
            buildCount = buildCount+1;
            
            if buildCount <= num2build+g
                mum{1,mum_target_gene_num} = daughter;
                newPop{buildCount} = mum;
            end
            
        end 
        
    end 
    
end
    if gp.runcontrol.usecache
        cachedData.complexity = gp.fitness.complexity(oldIndex,1);
        cachedData.returnvalues = gp.fitness.returnvalues{oldIndex,1};
        cachedData.value = gp.fitness.values(oldIndex,1);
        gp.fitness.cache(newIndex) = cachedData;
    end
gp.pop = newPop;
