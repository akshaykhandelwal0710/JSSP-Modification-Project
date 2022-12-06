function fitness = Time_obj(cost, x, release, due, duration, setup, nbMachines, nbJobs)
    fit_cost = Cost_obj(cost, x, release, due, duration, setup, nbMachines, nbJobs);
    fitness = fit_cost - sum(sum(cost.*x)) + sum(sum(duration.*x));
end