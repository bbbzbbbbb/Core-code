clc;
gp = rungp(@main_config);
summary(gp);
runtree(gp);
if gp.info.toolbox.symbolic
    gppretty(gp,'best');
end
poplook(gp);