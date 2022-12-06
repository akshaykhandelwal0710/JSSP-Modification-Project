function newPop = genStart(pop, release, due, duration, nbMachines, nbJobs)
    newPop = [pop, zeros(1, nbJobs)];
    x = zeros(nbJobs,nbMachines);
    for i = 1: nbJobs
        if pop(i) > nbMachines
            pop(i)
            continue
        end
        x(i,pop(i)) = 1;
    end
    for i = 1: nbMachines
        z = [];
        for j = 1: nbJobs
            if x(j, i) == 1
                z = [z ; [release(j) due(j) duration(j, i) duration(j, i) + release(j) due(j) - duration(j, i) j]];
            end
        end
        
        if isempty(z)
            continue
        end
        
        violation = 1;
        minViolation = 1e9;
        sz = size(z);
        for k = [1,2,5,4]
            z = sortrows(z, k);
            counter = 0;
            cur_time = 0;
            violation = 0;
            for j = 1: sz(1)
                p_cur_time = cur_time;
                cur_time = max(cur_time, z(j,1));
                newPop(nbJobs + z(j,6)) = cur_time;
                cur_time = cur_time + z(j, 3);
                if cur_time > z(j, 2)
                    violation = 1;
                    counter = counter + 1;
                    cur_time = p_cur_time;
                end
            end
            if violation == 0
                break
            end
            minViolation = min(minViolation, counter * 1000);
        end
         
        if violation == 1
            k = 0;
            cur_time = 0;
            violation = 0;
            counter = 0;
            for j = 1 : sz(1)
                sz_cur = size(z);
                minm = 10^9;
                for l = 1 : sz_cur(1)
                    if max(cur_time, z(l, 1)) + z(l, 3) < minm
                        minm = max(cur_time, z(l, 1)) + z(l, 3);
                        k = l;
                    end
                end
                
                p_cur_time = cur_time;
                cur_time = minm;
                newPop(nbJobs + z(k,6)) = cur_time - z(k,3);
                if cur_time > z(k, 2)
                    violation = 1;
                    counter = counter + 1;
                    cur_time = p_cur_time;
                end
                if sz_cur(1) == 1
                    z = [];
                elseif k == 1
                    z = z(2:end, :);
                elseif k == sz_cur(1)
                    z = z(1:end-1, :);
                else
                    z = z([1:k-1 k+1:end], :);
                end
            end
            
            minViolation = min(minViolation, counter * 1000);
        end
    end
end