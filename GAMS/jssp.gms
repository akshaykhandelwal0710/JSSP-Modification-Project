Set
    i /1, 2, 3, 4, 5/
    j /1, 2, 3/;
Alias (i,ip);
Parameter
    r(i)
    /1 1
    2 1
    3 1
    4 5
    5 6/
    d(i)
    /1 2
    2 3
    3 4
    4 9
    5 12/
    id(j)
    /1 1
    2 2
    3 3/;

Table
 p(i,j)
    1   2   3
1   1   2   3
2   2   2   3
3   3   2   3
4   1   2   3
5   1   2   3;

Table
cost(i, j)
    1   2   3
1   1   2   3
2   1   2   3
3   1   2   3
4   1   2   3
5   1   2   3;

Table
 setup(i,ip)
    1   2   3   4   5
1   1   2   3   4   5
2   1   2   3   4   5
3   1   2   3   4   5
4   1   2   3   4   5
5   1   2   3   4   5;

Binary Variables

A(i, ip)
B(i, ip)
Z(i, ip) 'order i and ip on same machine and i finishes at or before ip'
Y(i, ip) 'no of orders after i on m_i - no of orders after ip on m_ip >= 1'
D(i, ip)
adj(i, ip) '1 if order ip is the order next after i'
m(i, j);

Integer Variable
s(i)
f(i)
C(i) 'number of orders scheduled after order i on the same machine'
;
Variable
z;

Scalar U /10000/;

s.lo(i) = r(i);
s.up(i) = d(i);

Equation
    cost_obj
    
    finish_time(i)
    mac_con(i)
    process_end(i)
    
    finish_before_start(i,ip)
    tight_constraint_fbs(i, ip)
    machine_num_lesseq(i,ip)
    tight_constraint_mnl(i,   ip)
    overlap(i,ip)
    
    finish_before_start_and_same_mac(i,ip)
    tc_fbssm(i,ip)
    n_following_orders(i)
    setY(i,ip)
    tc_setY(i,ip)
    adj_nextorder_same_mac(i,ip)
    tc_nosm(i,ip)
    
;


cost_obj.. z =e= sum((i,j), cost(i, j)*m(i, j));

finish_time(i).. f(i) =e= s(i) + sum(j, p(i, j)*m(i, j)) + sum(ip, adj(i,ip)*setup(i,ip));
mac_con(i).. sum(j, m(i, j)) =e= 1;
process_end(i).. f(i) =l= d(i);

finish_before_start(i,ip).. f(i) =l= s(ip) + U*(1-B(i,ip));
tight_constraint_fbs(i, ip)..  1 + s(ip) =l= f(i) + U*B(i,ip);
machine_num_lesseq(i,ip).. sum(j, m(i,j)*id(j)) - sum(j, m(ip,j)*id(j)) =l= U*(1 - A(i,ip));
tight_constraint_mnl(i, ip).. 1 + sum(j, m(ip,j)*id(j)) =l= U*A(i,ip) + sum(j, m(i,j)*id(j)) ;

overlap(i,ip).. 1 $ (not sameAs(i,ip)) =l= B(ip,i)+ B(i,ip)+ U*(1 - (A(i,ip) + A(ip,i) - 1));

finish_before_start_and_same_mac(i,ip).. ((B(i,ip) + (A(i,ip) + A(ip,i) - 1)) - 1) =l= U*Z(i,ip);
tc_fbssm(i,ip).. 1 =l= ((B(i,ip) + (A(i,ip) + A(ip,i) - 1)) - 1) + U*(1 - Z(i,ip));
n_following_orders(i).. C(i) =e= sum(ip, Z(i, ip)) - Z(i,i);
setY(i,ip).. C(i) - C(ip) =l= U*Y(i,ip);
tc_setY(i,ip).. 1 =l= C(i) - C(ip) + U*(1 - Y(i,ip));
adj_nextorder_same_mac(i,ip).. (((Y(i,ip) + Y(ip,i) - 1) + (A(i,ip) + A(ip,i) - 1)) - 1) =l= U*D(i,ip);
tc_nosm(i,ip).. 1 =l= (((Y(i,ip) + Y(ip,i) - 1) + (A(i,ip) + A(ip,i) - 1)) - 1) + U*(1 - D(i,ip));


Model jssp /all/;
solve jssp using mip minimizing z;
display  A.l, B.l,s.l, f.l, m.l;