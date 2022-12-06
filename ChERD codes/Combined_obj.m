function fitness = Combined_obj(cost, x, release, due, duration, setup, nbMachines, nbJobs)
    fitness(1) = Cost_obj(cost, x, release, due, duration, setup, nbMachines, nbJobs);
    fitness(2) = Time_obj(cost, x, release, due, duration, setup, nbMachines, nbJobs);
    fitness(3) = Makespan_obj(cost, x, release, due, duration, setup, nbMachines, nbJobs);
end