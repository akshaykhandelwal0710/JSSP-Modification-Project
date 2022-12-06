function fitness = Makespan_obj(cost, x, release, due, duration, setup, nbMachines, nbJobs)
    if isempty(setup)
        setup = zeros(nbJobs,nbJobs);
    end
    
    TotalConViolation = 0;
    min_start = 1e9;
    max_finish = 0;
    for i = 1: nbMachines
        z = [];
        min_ths = 1e9;
        max_ths = 0;
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
            min_ths = 1e9;
            max_ths = 0;
            z = sortrows(z, k);
            counter = 0;
            cur_time = 0;
            violation = 0;
            previous_order = 0;
            for j = 1: sz(1)
                p_cur_time = cur_time;
                setup_time = 0;
                if previous_order ~= 0
                    setup_time = setup(previous_order,z(j,6));
                end
                cur_time = max(cur_time + setup_time, z(j,1));
                min_ths = min(min_ths, cur_time);
                cur_time = cur_time + z(j, 3);
                max_ths = max(max_ths, cur_time);
                if cur_time > z(j, 2)
                    violation = 1;
                    counter = counter + 1;
                    cur_time = p_cur_time;
                else
                    previous_order = z(j,6);
                end
            end
            
            if violation == 0
                break
            end
            minViolation = min(minViolation, counter * 1000);
        end
         
%         if violation == 1
%             k = 0;
%             cur_time = 0;
%             violation = 0;
%             counter = 0;
%             min_ths = 1e9;
%             max_ths = 0;
%             previous_order = 0;
%             for j = 1 : sz(1)
%                 sz_cur = size(z);
%                 minm = 10^9;
%                 for l = 1 : sz_cur(1)
%                     setup_time = 0;
%                     if previous_order ~= 0
%                         setup_time = setup(previous_order,z(l,6));
%                     end
%                     next_cur = max(cur_time + setup_time, z(l,1)) + z(l,3);
%                     if next_cur < minm
%                         minm = next_cur;
%                         k = l;
%                     end
%                 end
%                 
%                 p_cur_time = cur_time;
%                 cur_time = minm;
%                 setup_time = 0;
%                 if previous_order ~= 0
%                     setup_time = setup(previous_order,z(k,6));
%                 end
%                 min_ths = min(min_ths, p_cur_time + setup_time);
%                 max_ths = max(max_ths, cur_time);
%                 if cur_time > z(k, 2)
%                     violation = 1;
%                     counter = counter + 1;
%                     cur_time = p_cur_time;
%                 else
%                     previous_order = z(k,6);
%                 end
%                 
%                 z(k,:) = [];
%             end
%             
%             minViolation = min(minViolation, counter * 1000);
%         end
        
        if violation
            TotalConViolation = TotalConViolation + minViolation;
        end
        min_start = min(min_start, min_ths);
        max_finish = max(max_finish, max_ths);
    end
    
    fitness = max_finish - min_start + TotalConViolation;
end