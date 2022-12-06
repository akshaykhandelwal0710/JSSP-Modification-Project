clear;
clc;
addpath('mht');
T = 10;
NPop = 100;
nProb = 10;
nRuns = 5;
for p = 6
    resTL = [];
    resDE = [];
    resGA = [];
    resABC = [];
    resPSO = [];
    resAL = [];

    fprintf("Problem %d:\n", p);
    [lb, ub, FITNESSFCN] = ProblemDetails(p);
    [nbMachines,nbJobs,duration,release,due,cost,setup] = ProblemData(p);
%     nbMachines
%     nbJobs
%     duration
%     release
%     due
%     cost
%     setup
    for run = 1:nRuns
        [X,F1] = sTLBO(FITNESSFCN,lb,ub,T,NPop);
        resTL = [resTL, F1];  
    end
    %resTL
    mean(resTL);
    min(resTL);
    median(resTL);
    for run = 1:nRuns
        [X,F2] = DifferentialEvolution(FITNESSFCN,lb,ub,NPop,T,0.7,2);
        resDE = [resDE, F2];
    end
    %resDE;

    mean(resDE);
    min(resDE);
    median(resDE);
    for run = 1:nRuns
        [X,F3] = GeneticAlgorithm(FITNESSFCN,lb,ub,NPop,T,20,20,0.8,0.2);
        resGA = [resGA , F3];
    end
    %resGA
    mean(resGA);
    min(resGA);
    median(resGA);

    for run = 1:nRuns
        [X,F4] = ABC(FITNESSFCN,lb,ub,NPop,T,5);
        resABC = [resABC , F4];
    end
    %resABC
    mean(resABC);
    min(resABC);
    median(resABC);

    for run = 1:nRuns
        [X,F5] = PSOfunc(FITNESSFCN,NPop,lb,ub,T,0.7,1.5,1.5);
        resPSO = [resPSO , F5];
    end
    %resPSO
    mean(resPSO);
    min(resPSO);
    median(resPSO);
    
    for run = 1:nRuns
        [F6,X] = ALO(NPop,T,lb,ub,nbJobs,FITNESSFCN);
        resAL = [resAL, F6];
    end
    %resAL
    mean(resAL);
    min(resAL);
    median(resAL);
    
    [min(resTL) min(resDE) min(resGA) min(resABC) min(resPSO) min(resAL)]
    [mean(resTL) mean(resDE) mean(resGA) mean(resABC) mean(resPSO) mean(resAL)]
    [median(resTL) median(resDE) median(resGA) median(resABC) median(resPSO) median(resAL)]
    
    
    
end
