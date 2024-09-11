function poplook(gp,dataset,ID,complexityType,logR2)
if nargin < 2 || isempty(dataset)
    dataset = 'train';
end
if nargin < 3
    ID = [];
end
if nargin < 4 || isempty(complexityType)
    complexityType = 1;
end
if nargin < 5 || isempty(logR2)
    logR2 = false;
end
browserFig = figure('visible','off'); set(browserFig,'name','GPTIPS 2 Population browser');
ax1 = gca; set(ax1 ,'box','on')
if ~isempty(gp.userdata.name)
    setname = ['Data: ' gp.userdata.name];
else
    setname = '';
end
mergeStr = '';
if gp.info.merged && gp.info.filtered
    mergeStr = ' (merged & filtered)';
elseif gp.info.merged
    mergeStr = ' (merged)';
elseif gp.info.filtered
    mergeStr = ' (filtered)';
end
%%
[~,sortIndex] = sort(gp.fitness1.values);
m = size(gp.fitness.values);
for i = 1:size(m)
    gp.fitness.values(i) = gp.fitness1.values(sortIndex(i));
    gp.fitness.complexity(i) = gp.fitness1.complexity(sortIndex(i));
end
mgmodel = false;
if strncmpi(func2str(gp.fitness.fitfun),'regressmulti',12)
    mgmodel = true;
    if strcmpi(dataset,'train')
        yvals = gp.fitness.values;
        ylabelContent = 'Fitness';
        yvalBest = min(yvals);
    end
        bluedots = plot(ax1,gp.fitness.complexity,yvals,'o');
    set(bluedots,'markeredgecolor','none','markerfacecolor',[1.0, 0.7137, 0.7569]);
    hold on;
        xrank = ndfsort_rank1([yvals gp.fitness.complexity]);
        greendots = plot(ax1,gp.fitness.complexity(xrank==1),yvals(xrank==1),'o');
        disp([yvals(xrank==1),gp.fitness.complexity(xrank==1)]);
        
    set(greendots,'markerfacecolor','green','markeredgecolor',[0.25 0.25 0.25]);
    gp.fitness.values = yvals; 
    [row, ~] = find(yvals==min(yvals));
    bestComplexity = gp.fitness.complexity(row);
    plot(ax1,bestComplexity,yvalBest,'ro','linewidth',2,'markersize',8);
    grid on; ylabel(ax1,ylabelContent,'FontSize', 25);
    ylim(ax1, 'auto'); 
    if complexityType
        xlabel(ax1,'Expressional complexity','FontSize', 25);
    else
        xlabel(ax1,'Number of nodes');
    end
    hold off;
    title(ax1,{['Population' mergeStr ' models = ' num2str(gp.runcontrol.pop_size)],...
        setname},'interpreter','none','FontWeight','bold','FontSize', 25);
end
gp.complexityType = complexityType;
grid on; set(browserFig,'userdata',gp); set(browserFig,'numbertitle','off'); set(browserFig,'visible','on');
dcManager = datacursormode(gcf);
if mgmodel && gp.info.toolbox.symbolic
    set(dcManager,'UpdateFcn',@disp_mgmodel);
else
    set(dcManager,'UpdateFcn',@disp_indiv); 
end
set(dcManager,'SnapToDataVertex','on');
set(dcManager,'enable','on');
set(gca,'FontSize',20);
drawnow;

function txt = disp_indiv(~,event_obj)
%returns population member ID to datacursor.
if verLessThan('Matlab','8.4')
    gp = get(gcbf,'userdata'); %appears not to work in 2014b
else
    gp = get(gcf,'userdata'); %workaround til this is fixed
end
a = get(event_obj);
b = get(a.Target);
if strcmp(b.Type,'line')
    comp = a.Position(1);
    fitness = a.Position(2);
    fitInd = find(gp.fitness.values==fitness);
    if gp.complexityType
        compInd = find(gp.fitness.complexity==comp);
    else
        compInd = find(gp.fitness.nodecount==comp);
    end
    ind = intersect(fitInd,compInd);
    numInds = numel(ind);
    txt = cell(numInds+1,1);
    txt{1} ='Individual ID: ';
    for i=1:numInds
        txt{i+1} = int2str(ind(i));
    end
else
    txt = '';
end


function txt = disp_mgmodel(~,event_obj)
if verLessThan('Matlab','8.4')
    gp = get(gcbf,'userdata'); 
else
    gp = get(gcf,'userdata'); 
end
a = get(event_obj);
b = get(a.Target);
if strcmp(b.Type,'line')
    complexity = a.Position(1);
    fitness = a.Position(2);
    fitInd = find(gp.fitness.values==fitness);
    
    if gp.complexityType
        compInd = find(gp.fitness.complexity==complexity);
    else
        compInd = find(gp.fitness.nodecount==complexity);
    end
    ind = intersect(fitInd,compInd);
    numInds = numel(ind);
    if numInds > 0
        if numInds > 10
            disp('Multiple matching models: only displaying first 5.');
            ind = ind(1:5);
            numInds = 5;
        end
        txt = cell(numInds+1,2);
        txt{1,1} ='Individual ID: ';
        txt{1,2} ='Model: ';
        for i=1:numInds
            txt{i+1,1} = int2str(ind(i));
            try
                txt{i+1,2} = char(vpa(gpmodel2sym(gp,ind(i),true),2));
                disp([int2str(ind(i)),'  ',char(vpa(gpmodel2sym(gp,ind(i),true),2))]);
            catch
                txt{i+1,2} = 'Invalid model';
            end
        end
    else
        txt = {'Model not found in population.'}; 
    end
else
    txt = '';
end
