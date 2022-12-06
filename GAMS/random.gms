Set i/
$call =xls2gms r=Sheet5!b6:b17 i=test_data.xlsx o=set1.inc
$include set1.inc
/
j /
$call =xls2gms r=Sheet5!c5:e5 s="," i=test_data.xlsx o=set2.inc
$include set2.inc
/;
Alias (i,ip);

Parameter
    r(i)/
$call =xls2gms r=Sheet5!g6:h17 i=test_data.xlsx o=par1.inc
$include par1.inc
/
    d(i)/
$call =xls2gms r=Sheet5!j6:k17 i=test_data.xlsx o=par2.inc
$include par2.inc
/
    id(j)/
$call =xls2gms r=Sheet5!a21:b23 i=test_data.xlsx o=par3.inc
$include par3.inc
/;

Table
 p(i,j)
$call =xls2gms r=Sheet5!b5:e17 i=test_data.xlsx o=tab1.inc
$include tab1.inc
;

Table
cost(i, j)
$call =xls2gms r=Sheet5!b20:e32 i=test_data.xlsx o=tab2.inc
$include tab2.inc
;

Table
setup(i,ip)
$call =xls2gms r=Sheet5!g20:j32 i=test_data.xlsx o=tab3.inc
$include tab3.inc
;

display i, j, r, d, id, p, setup, cost;
*Set
*    i /1, 2, 3, 4, 5/
*    j /1, 2, 3/;
*Alias (i,ip);
*Parameter
*    r(i)
*    /1 1
*    2 1
*    3 1
*    4 30
*    5 60/
*    d(i)
*    /1 3
*    2 4
*    3 4
*    4 90
*    5 120/
*    id(j)
*    /1 1
*    2 2
*    3 3/;
*
*Table
* p(i,j)
*    1   2   3
*1   2   2   3
*2   3   2   3
*3   1   2   3
*4   1   2   3
*5   1   2   3;
*
*Table
*cost(i, j)
*    1   2   3
*1   1   2   3
*2   1   2   3
*3   1   2   3
*4   1   2   3
*5   1   2   3;
*
*Table
* setup(i,ip)
*    1   2   3   4   5
*1   1   1   1   1   1
*2   1   1   1   1   1
*3   1   1   1   1   1
*4   1   1   1   1   1
*5   1   1   1   1   1;


Set
obj /'p_cost', 'p_time', 'makespan'/
a_obj(obj);
Set
   obj1(obj)  'the first element of obj'
   objm1(obj) 'all but the first elements of obj'
   obj2(obj)
   obj3(obj);

obj1(obj)$(ord(obj) = 1) = yes;
obj2(obj)$(ord(obj) = 2) = yes;
obj3(obj)$(ord(obj) = 3) = yes;
objm1(obj)  = yes;
objm1(obj1) =  no;

Alias(obj, objp);
Parameter payoff(obj, obj) 'payoff tables entries'

maxobj(obj)
minobj(obj);

Binary Variables

A(i, ip) 'order i occurs on a machine with number less than or equal to that of ip'
B(i, ip) 'order i finishes before or at start time of ip with setup time required if i is processed before ip in between'
Z(i, ip) 'order i and ip on same machine and i finishes at or before ip'
Y(i, ip) 'no of orders after i on m_i - no of orders after ip on m_ip >= 1'
Yp(i, ip) 'no of orders after i on m_i - no of orders after ip on m_ip <= 1'
adj(i, ip) 'order ip is the order next after i on the same machine'
m(i, j) 'order i occurs on machine j'
Xf(i) 'Xf(i) = 1 if order i has largest finish time'
Xs(i) 'Xs(i) = 1 if order i has smallest start time'
; 

Integer Variable
s(i) 'start time of order i'
f(i) 'finish time of order i'
C(i) 'number of orders scheduled after order i on the same machine'
lf 'largest finish time'
es 'earliest start time'

;

Variable
obj_val(obj) 'objective function variables'
zval
;

Scalar U /10000/;

s.lo(i) = r(i);
s.up(i) = d(i);

Equation
    cost_obj
    ptime_obj
    makespan_obj
    allobj
    
    
    finish_time(i)
    mac_con(i)
    process_end(i)
    
    finish_before_start(i,ip)
    tight_constraint_fbs(i, ip)
    machine_num_lesseq(i,ip)
    tight_constraint_mnl(i, ip)
    overlap(i,ip)
    
    finish_before_start_and_same_mac(i,ip)
    tc_fbssm(i,ip)
    n_following_orders(i)
    setY(i,ip)
    tc_setY(i,ip)
    setYp(i,ip)
    tc_setYp(i,ip)
    adj_nextorder_same_mac(i,ip)
    tc_nosm(i,ip)
    
    select_latest
    select_earliest
    confirm_lf(i)
    set_lf(i)
    confirm_es(i)
    set_es(i)
    
;

* total cost = summation of cost of processing order i on machine m(i)
cost_obj.. obj_val('p_cost') =e= sum((i,j), cost(i, j)*m(i, j));

* p_time = summation of processing times of order i on machine m(i)
ptime_obj.. obj_val('p_time') =e= sum((i, j), p(i, j)*m(i, j));

* makespan = largest finish time - earliest start time
makespan_obj.. obj_val('makespan') =e= lf - es;

allobj..   sum(a_obj, obj_val(a_obj)) =e= zval;


* finish_time of order i = start time of order i + processing time of order i on machine m(i)
finish_time(i).. f(i) =e= s(i) + sum(j, p(i, j)*m(i, j)) ;

* every order operates on exactly one machine
mac_con(i).. sum(j, m(i, j)) =e= 1;

*every order should finish before its due date d(i)
process_end(i).. f(i) =l= d(i);

* set B(i, ip) =1 iff order i finishes before or at start time of ip with setup time required if i is processed before ip in between
finish_before_start(i,ip).. f(i)+ adj(i,ip)*setup(i,ip) =l= s(ip) + U*(1-B(i,ip));
tight_constraint_fbs(i, ip)..  1 + s(ip) =l= f(i)+adj(i,ip)*setup(i,ip) + U*B(i,ip);

*set A(i, ip) = 1 iff order i occurs on a machine with number less than or equal to that of ip
machine_num_lesseq(i,ip).. sum(j, m(i,j)*id(j)) - sum(j, m(ip,j)*id(j)) =l= U*(1 - A(i,ip));
tight_constraint_mnl(i, ip).. 1 + sum(j, m(ip,j)*id(j)) =l= U*A(i,ip) + sum(j, m(i,j)*id(j)) ;

* if order i and ip are operating on the same machine, then either i should finish before ip or ip should finish before i
overlap(i,ip).. 1 $ (not sameAs(i,ip)) =l= B(ip,i)+ B(i,ip)+ U*(1 - (A(i,ip) + A(ip,i) - 1));

* set Z(i , ip) = 1 iff order i and ip on same machine and i finishes at or before ip
finish_before_start_and_same_mac(i,ip).. ((B(i,ip) + (A(i,ip) + A(ip,i) - 1)) - 1) =l= U*Z(i,ip);
tc_fbssm(i,ip).. 1 =l= ((B(i,ip) + (A(i,ip) + A(ip,i) - 1)) - 1) + U*(1 - Z(i,ip));

* C(i) = number of orders after order i on the same machine
n_following_orders(i).. C(i) =e= sum(ip, Z(i, ip)) - Z(i,i);

* set Y(i, ip) = 1 iff no of orders after i on m_i - no of orders after ip on m_ip >= 1
setY(i,ip).. C(i) - C(ip) =l= U*Y(i,ip);
tc_setY(i,ip).. 1 =l= C(i) - C(ip) + U*(1 - Y(i,ip));

* set Yp(i, ip) = 1 iff no of orders after i on m_i - no of orders after ip on m_ip <= 1
setYp(i,ip).. 2 =l= U*Yp(i,ip) + C(i) - C(ip);
tc_setYp(i,ip).. C(i) - C(ip) =l= 1+ U*(1 - Yp(i,ip));

* set adj(i, ip) = 1 iff order ip is the order next after i on the same machine
adj_nextorder_same_mac(i,ip).. (((Y(i,ip) + Yp(i,ip) - 1) + (A(i,ip) + A(ip,i) - 1)) - 1) =l= U*adj(i,ip);
tc_nosm(i,ip).. 1 =l= (((Y(i,ip) + Yp(i,ip)- 1) + (A(i,ip) + A(ip,i) - 1)) - 1) + U*(1 - adj(i,ip));


* summation of Xf(i) = summation of Xs(i) = 1, to select the latest and the earliest order respectively
select_latest.. sum(i, Xf(i)) =e= 1;
select_earliest.. sum(i, Xs(i)) =e= 1;

*confirming lf, es
confirm_lf(i).. lf =g= f(i);
confirm_es(i).. es =l= s(i);

* setting lf, es
set_lf(i).. lf =l= U*(1 - Xf(i)) + f(i);
set_es(i).. es + U*(1 - Xs(i)) =g= s(i);

Model mod_payoff /all/;

* Generate payoff table applying lexicographic optimization
loop(obj,
   a_obj(obj) = yes;
   solve mod_payoff using mip minimizing zval;
   payoff(obj,objp) = obj_val.l(objp);
   a_obj(obj) = no;
*  release the fixed values of the objective functions for the new iteration
   obj_val.up(objp) =  inf;
   obj_val.lo(objp) = -inf;
);

display payoff;

*each row in the payoff is minimizing one objective function, and has the values of all the other objectives at its minima
*searching in one column over all rows for the min and max values of a particular objective
minobj(obj) = smin(objp,payoff(objp,obj)); 
maxobj(obj) = smax(objp,payoff(objp,obj)); 

$if not set gridpoints $set gridpoints 10

Set
   g         'grid points' / g0*g%gridpoints% /
   grid(obj,g) 'grid';
Alias(g, gp);
Alias(g, gpp);

Set
    a_g(obj,g);

Parameter
   gridrhs(obj,g) 'rhs of eps-constraint at grid point'
   maxg(obj)      'maximum point in grid for objective'
   numg(g)      'ordinal value of g starting with 0';

Equation
    eps_cons(obj,g);
    
eps_cons(a_g(obj,g)).. gridrhs(obj,g) =g= obj_val(obj);
Model eps_cons_mod /all/;

numg(g) = ord(g) - 1;
display objm1;
grid(objm1,g) = yes;
*Here we could define different grid intervals for different objectives
maxg(objm1)   = smax(grid(objm1,g), numg(g));
gridrhs(grid(objm1,g)) = minobj(objm1) + numg(g)/maxg(objm1)*(maxobj(objm1) - minobj(objm1));
display gridrhs;

a_obj(obj1) = yes;
a_obj(objm1) = no;
loop(gp,
    a_g(obj2,gp) = yes;
    loop(gpp,
        a_g(obj3,gpp) = yes;
        solve eps_cons_mod using mip minimizing zval;
        display obj_val.l, m.l;
        a_g(obj3,gpp) = no;
    );
    a_g(obj2,gp) = no;
);