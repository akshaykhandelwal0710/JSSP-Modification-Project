clear;
addpath('mht');
T = 100;
T2 = 1000;
NPop = 100;
nProb = 10;
nRuns = 15;
for p = 1:10
    resTL = [];
    resDE = [];
    resGA = [];
    resABC = [];
    resPSO = [];
    resAL = [];
    F_tlbo = [];


    fprintf("Problem %d:\n", p);
    [lb, ub, FITNESSFCN] = ProblemDetails(p);
    [lb1, ub1, FITNESSFCN1] = ProblemDetails_old(p);
    [nbMachines,nbJobs,duration,release,due,cost] = ProblemData(p);
    for run = 1:nRuns
        [X,F1,bestNpop] = sTLBO(FITNESSFCN,lb,ub,T,NPop);
%         bestNpop
        F_tlbo = [F_tlbo F1];

        initPop = [bestNpop, zeros(NPop,nbJobs)];
        for j = 1:NPop
            initPop(j,:) = genStart(bestNpop(j,:), release, due, duration, nbMachines, nbJobs);
        end
        [X,F] = sTLBO1(FITNESSFCN1, lb1, ub1, T2, NPop, initPop);
%         [X,F] = GA1(FITNESSFCN1,lb1,ub1,NPop,T2,20,20,0.5,0.5,initPop);
%         [X,F] = DE1(FITNESSFCN1,lb1,ub1,NPop,T2,0.7,2,initPop);
%         [F,X] = ALO1(NPop,T2,lb1,ub1,2*nbJobs,FITNESSFCN,initPop);
        resTL = [resTL, F];
    end
    F_tlbo;
    mean(F_tlbo);
    min(F_tlbo);
    resTL
    mean(resTL)
    min(resTL)
    median(resTL)
end