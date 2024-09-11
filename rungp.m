function gpout = rungp(configFile)
gp = gpdefaults();
gp = gprandom(gp);
gp = feval(configFile,gp);
for run=1:gp.runcontrol.runs
    gp.state.run = run;
    if run > 1 && ~gp.runcontrol.suppressConfig
        gp = feval(configFile,gp);
    end
    gp.info.configFile = configFile;
    gp = gpcheck(gp);
    gp = gpinit(gp); 
    for count=1:gp.runcontrol.num_gen
        gp = gptic(gp);
        if count == 1
            gp = initbuild(gp);
        else
            popf = gp.pop;
            fit = gp.fitness.values;
            complexity  = gp.fitness.complexity; 
            gp = popbuild(gp); 
        end
         gp = evalfitness(gp);
        if count >=2 
        gp.pop1 = [popf;gp.pop]; 
        gp.fitness1.values = [fit;gp.fitness.values];
        gp.fitness1.complexity = [complexity;gp.fitness.complexity;];
        gp = non_domination_sort_mod(gp);
        end
        gp = evalfitness(gp);
    end 
end 