function gp = non_domination_sort_mod(gp)
n = numel(gp.fitness1.values);
f(:,1) = gp.fitness1.values;
f(:,2) = gp.fitness1.complexity;
for i=1:n
    dominatedCount = 0;
    for j = 1:n
        if i~=j
           dominated = all(f(j,:)<=f(i,:))&& any(f(j,:)<f(i,:)); 
                if dominated
                     dominatedCount = dominatedCount+1;
                end
        end
    end
    rankcount(i) = dominatedCount;  
end
u = unique(rankcount);
for i = 1:n
    indices(i) = find(u==rankcount(i));
end
[sorted_nums, idx] = sort(indices); 
[values,idx1] = sort(gp.fitness1.values); 
[complexity,idx2] = sort(gp.fitness1.complexity);
for i = 2:length(values)-1
    valuesd(i) = 2*(values(i+1)-values(i-1));
end
valuesd(1) = Inf; valuesd(length(values))=Inf;
for i = 2:length(complexity)-1
    complexityd(i) = 2*(complexity(i+1)-complexity(i-1));
end
complexityd(1) = Inf; complexityd(length(complexity)) = Inf;
sort_valuesd = valuesd(idx);
sort_complexityd = complexityd(idx);
sort_yjd = sort_valuesd+sort_complexityd;
yjd_rank(:,1) = idx';
yjd_rank(:,2) = sort_yjd';
yjd_rank(:,3) = sorted_nums';
m = 1;
q = 1;
yjd_rank(isnan(yjd_rank)) = 0;
for i = 1:n
    if i==length(data)
        break;
    end
    if yjd_rank(i+1,3) == yjd_rank(i,3)
        q = q+1;
    else
        if m==1
            sorted_rows = sortrows(yjd_rank(m:q, :), 2,'descend');
            yjd_rank = [sorted_rows; yjd_rank(q+1:end, :)];
        elseif q==n
            sorted_rows = sortrows(yjd_rank(m:q, :), 2,'descend');
            yjd_rank = [yjd_rank(1:m-1, :);sorted_rows]; 
            break
        else
            sorted_rows = sortrows(yjd_rank(m:q, :), 2,'descend');
            yjd_rank = [yjd_rank(1:m-1, :);sorted_rows; yjd_rank(q+1:end, :)];
        end
        q = q+1;
        m = q;
    end
end
for i = 1:length(gp.fitness.values)
    gp.pop(i) = gp.pop1(yjd_rank(i,1));
end












