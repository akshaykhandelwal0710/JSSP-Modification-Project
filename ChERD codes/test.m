clear;
clc;
addpath('mht');
T = 100;
NPop = 100;
nProb = 10;
nRuns = 2;
for p = 1
    fprintf("Problem %d:\n", p);
    [lb, ub, FITNESSFCN] = ProblemDetails(p);
    [nbMachines,nbJobs,duration,release,due,cost,setup] = ProblemData(p);
    
    fitTLBO = [];
    fitDE = [];
    fitGA = [];
    fitABC = [];
    fitPSO = [];
    fitALO = [];
    
    for run = 1:nRuns
        [X,F1,bestNpop,fitsTLBO] = sTLBO(FITNESSFCN,lb,ub,T,NPop);
        fitTLBO = [fitTLBO ; fitsTLBO];
        [X,F2, fitsDE] = DifferentialEvolution(FITNESSFCN,lb,ub,NPop,T,0.7,2);
        fitDE = [fitDE ; fitsDE];
        [X,F3, fitsGA] = GeneticAlgorithm(FITNESSFCN,lb,ub,NPop,T,20,20,0.8,0.2);
        fitGA = [fitGA; fitsGA];
        [X,F4, fitsABC] = ABC(FITNESSFCN,lb,ub,NPop,T,5);
        fitABC = [fitABC; fitsABC];
        [X,F5, fitsPSO] = PSOfunc(FITNESSFCN,NPop,lb,ub,T,0.7,1.5,1.5);
        fitPSO = [fitPSO; fitsPSO];
        [F6,X, fitsALO] = ALO(NPop,T,lb,ub,nbJobs,FITNESSFCN);
        fitALO = [fitALO; fitsALO];

        
    end
    finalTLBO = mean(fitTLBO);
    finalDE = mean(fitDE);
    finalGA = mean(fitGA);
    finalABC = mean(fitABC);
    finalPSO = mean(fitPSO);
    finalALO = mean(fitALO);
    xrange = [1:1000];
    subplot(2,3,1);
    plot(finalTLBO, "r")
    title('sTLBO');
    subplot(2,3,2);
    plot(finalDE, "r")
     title('DE');
    subplot(2,3,3);
    plot(finalGA, "r")
     title('GA');
    subplot(2,3,4);
    plot(finalABC, "r")
     title('ABC');
    subplot(2,3,5);
    plot(finalPSO, "r")
     title('PSO');
    subplot(2,3,6);
    plot(finalALO, "r")
     title('ALO');
end
