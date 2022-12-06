clear;
clc;
addpath('mht');
T = 100;
NPop = 100;
nProb = 9;
nRuns = 1;

for p = [2,4,6,8,10]
    [lb, ub, FITNESSFCN] = ProblemDetails_multiObj(p);
    [nbMachines,nbJobs,duration,release,due,cost,setup] = ProblemData(p);
    
    X = gamultiobj(FITNESSFCN,nbJobs,[],[],[],[],lb,ub);
    X = round(X);
    X = unique(X, 'rows');
    Y = [X FITNESSFCN(X)];
    sprintf('Problem Number %d:', p)
    Y
end