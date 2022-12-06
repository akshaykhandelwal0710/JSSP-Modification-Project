function [lb, ub, FITNESSFCN] = ProblemDetails_old(problem_no)

[nbMachines,nbJobs,duration,release,due,~] = ProblemData(problem_no);
lb = [ones(nbJobs , 1) ; release']';
ub = [nbMachines*ones(nbJobs , 1) ; due' - min(duration,[],2)]';

FITNESSFCN = @get_fitness;
    
function [Fitness, Pop] = get_fitness(Pop)
    Pop = round(Pop);
    M = 1; % Dimension of the objective space

    % Obtain the data corresponding to this particular problem
    [nbMachines,nbJobs,duration,release,due,cost] = ProblemData(1);
    ub = due' - min(duration,[],2); % Upper bound calculation

    [NPop,Nx] = size(Pop);
    Fitness = NaN(NPop,M);
    w = zeros(NPop,3);

    for p = 1:NPop
        singlesol = Pop(p,:); % current solution vector

        x = zeros(nbJobs,nbMachines);
        for i = 1: nbJobs % order x machine logical matrix 
            x(i,singlesol(i)) = 1;
        end

        % The last nbJobs variables of a solution correspond to the start time
        % of the Jobs
        ts = singlesol(Nx-nbJobs+1 : Nx)'; % starting time extraction

        %%
        prod = duration .* x; % Pim*xim = Processing time
        %     ----------------------------------------------------
        % no. of orders on each machine
        NOrderMachine = sum(x,1);
        for m = 1: nbMachines
    %         tsold  = ts;
            if NOrderMachine(m) > 1
                CurrOrders  = find(x(:,m) == 1);% determine the orders to be 
                % processed on machine m
                [currentts, ind] = sort(ts(CurrOrders)); % Sort the orders with
                % respect to starting time
    %             ts(CurrOrders(ind)) = currentts; % 
                ts(CurrOrders(ind(1))) = release(CurrOrders(ind(1)));% first order starts at release
                currOrderProd = prod(CurrOrders(ind),m); % Processing time of all orders
                for i = 2:NOrderMachine(m)
                    ts(CurrOrders(ind(i))) = ts(CurrOrders(ind(i-1))) + currOrderProd(i-1);
                    ts(CurrOrders(ind(i))) = max(ts(CurrOrders(ind(i))),release(CurrOrders(ind(i))));
                end
                bVioInd = find(ts(CurrOrders)>ub((CurrOrders)));
                if ~isempty(bVioInd)
                    ts(CurrOrders(bVioInd)) = ub((CurrOrders(bVioInd)));
                    [currentts, ind] = sort(ts(CurrOrders));
    %                 ts(CurrOrders(ind)) = currentts;
                    currOrderProd = prod(CurrOrders(ind),m);
                    for j = 1:NOrderMachine(m)-1
                        Vio = ts(CurrOrders(ind(j+1))) - (ts(CurrOrders(ind(j))) ...
                            + currOrderProd(j));
                        if Vio < 0
                            w(p,1) = w(p,1) - Vio;
                        end
                    end

                end
            else
                CurrOrder  = find(x(:,m) == 1);
                ts(CurrOrder) = release(CurrOrder);
            end

        end

        %% Constraint to check if all of the jobs are completed before their due date
        Ordertimereqd = sum(prod,2);
        Ordertimecomplete = ts + Ordertimereqd;
        Ordertimedelay = due(:) - Ordertimecomplete;
        w(p,2) = sum(abs(Ordertimedelay((Ordertimedelay<0))));
        %     Makespan = max(Ordertimecomplete) - min(ts);

        MachineTimeReqd = sum(prod,1);
        MaxTimeAvailable = max(due) - min(release);
        dummyvar = MachineTimeReqd - MaxTimeAvailable ;
        w(p,3) = sum(abs(dummyvar(dummyvar > 0)));


        TotalConViolation = sum(w(p,:));
        if TotalConViolation > 0
    %         Fitness(p,1) = Makespan + TotalConViolation + max(due);
            Fitness(p) = sum(sum(cost.*x)) + TotalConViolation + sum(max(cost,[],2));
        else
    %         Fitness(p,1) = Makespan;
            Fitness(p) = sum(sum(cost.*x));
        end
       Pop(p,:) = [Pop(p, 1:nbJobs) ts']; 
    end
    end

end