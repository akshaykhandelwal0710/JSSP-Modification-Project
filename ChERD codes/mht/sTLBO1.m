% TLBO with initial population given

function [bestSol,bestFit] = sTLBO(FITNESSFCN,lb,ub,T,NPop,inPop)
% Teaching Learning Based optimization (TLBO)
% ModifiedTLBO attempts to solve problems of the following forms:
%         min F(X)  subject to: lb <= X <= ub
%          X
%
%  [X,FVAL,BestFVALIter, pop] = ModifiedTLBO(FITNESSFCN,lb,ub,T,NPop)
%  FITNESSFCN   - function handle of the fitness function
%  lb           - lower bounds on X
%  ub           - upper bounds on X
%  T            - number of iterations
%  NPop         - size of the population (class size)
%  X            - minimum of the fitness function determined by ModifiedTLBO
%  FVAL         - value of the fitness function at the minima (X)
%  BestFVALIter - the best fintess function value in each iteration
%  pop          - the population at the end of the specified number of iterations

% preallocation to store the best objective function of every iteration
% and the objective function value of every student
obj = NaN(NPop,1);

% Determining the size of the problem
D = length(lb);

% Generation of initial population
pop = inPop;


%  Evaluation of objective function
%  Can be vectorized
for p = 1:NPop
    [obj(p),pop(p,:)] = FITNESSFCN(pop(p,:));
end


for gen = 1: T
    
    % Partner selection for all students
    % Note that randperm has been used to speedup the partner selection.
    Partner = randperm(NPop);
    % There is a remote possibility that the ith student will have itself as its partner
    % No experiment is available in literature on the disadvantages of
    % a solution having itself as partner solution.
    
    for i = 1:NPop
        
        % ----------------Begining of the Teacher Phase for ith student-------------- %
        mean_stud = mean(pop);
        
        % Determination of teacher
        [~,ind] = min(obj);
        best_stud = pop(ind,:);
        
        % Determination of the teaching factor
        TF = randi([1 2],1,1);
        
        % Generation of a new solution
        NewSol = pop(i,:) + rand(1,D).*(best_stud - TF*mean_stud);
        
        % Bounding of the solution
        NewSol = max(min(ub, NewSol),lb);
        
        % Evaluation of objective function
        [NewSolObj,NewSol] = FITNESSFCN(NewSol);
        
        % Greedy selection
        if (NewSolObj < obj(i))
            pop(i,:) = NewSol;
            obj(i) = NewSolObj;
        end
        % ----------------Ending of the Teacher Phase for ith student-------------- %
        
        
        % ----------------Begining of the Learner Phase for ith student-------------- %
        % Generation of a new solution
        if (obj(i)< obj(Partner(i)))
            NewSol = pop(i,:) + rand(1, D).*(pop(i,:)- pop(Partner(i),:));
        else
            NewSol = pop(i,:) + rand(1, D).*(pop(Partner(i),:)- pop(i,:));
        end
        
        % Bounding of the solution
        NewSol = max(min(ub, NewSol),lb);
        
        % Evaluation of objective function
        [NewSolObj,NewSol] = FITNESSFCN(NewSol);
        % Greedy selection
        if(NewSolObj< obj(i))
            pop(i,:) = NewSol;
            obj(i) = NewSolObj;
        end
        % ----------------Ending of the Learner Phase for ith student-------------- %

    end
    [bestFit,ind] = min(obj);
    bestSol = pop(ind,:);
    
end
