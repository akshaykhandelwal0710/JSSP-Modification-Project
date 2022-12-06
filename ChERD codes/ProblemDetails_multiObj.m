function [lb, ub, FITNESSFCN] = ProblemDetails_multiObj(problem_no)
    [nbMachines,nbJobs,duration,release,due,cost,setup] = ProblemData(problem_no);
    lb = ones(1, nbJobs);
    ub = (nbMachines*ones(nbJobs, 1))';
    
    FITNESSFCN = @get_fitness;
    
    function [Fitness, Pop1] = get_fitness(Pop)
        Pop = round(Pop);
        Pop1 = Pop;
        M = 3;
        
        [NPop, garbage] = size(Pop);
        Fitness = NaN(NPop,M);
        
        for p = 1:NPop
            singlesol = Pop(p,:); % current solution vector

            x = zeros(nbJobs,nbMachines);
            for i = 1: nbJobs % order x machine logical matrix 
                x(i,singlesol(i)) = 1;
            end

            Fitness(p,:) = [Cost_obj(cost, x, release, due, duration, setup, nbMachines, nbJobs) Time_obj(cost, x, release, due, duration, setup, nbMachines, nbJobs) Makespan_obj(cost, x, release, due, duration, setup, nbMachines, nbJobs)];
        end
    end
end