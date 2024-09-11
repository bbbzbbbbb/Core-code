function gp=main_config(gp)
gp.runcontrol.pop_size = 400;              
gp.runcontrol.num_gen = 100;			                                                 
gp.selection.tournament.size = 6;
gp.fitness.terminate = true;
gp.fitness.terminate_value = 0.003;
gp.userdata.xtrain = ; 
gp.userdata.ytrain = ; 
gp.userdata.xtest = data(501:869,:); 
gp.userdata.ytest = datay(501:869,:); 
gp.userdata.name = '';
gp.genes.max_genes = 3;                   
gp.nodes.functions.name = {'times','minus','plus','sqrt','square','sin','cos','exp','add3','mult3'};



