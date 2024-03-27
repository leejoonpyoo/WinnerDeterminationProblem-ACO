using JuMP, Gurobi

function gurobi_WDP_solver(k, l, bids)
    A = zeros(Int, k, l)
    prices = [bid[2] for bid in bids]

    for j in 1:l
        for item in bids[j][1]
            A[item, j] = 1
        end
    end

    m = Model(Gurobi.Optimizer)
    set_optimizer_attribute(m, "OutputFlag", 0)

    @variable(m, x[1:l], Bin)
    
    @objective(m, Max, sum(x[i] * prices[i] for i in 1:l))
    
    @constraint(m, [i=1:k], sum(A[i, j]*x[j] for j in 1:l) <= 1)
    
    optimize!(m)

    obj_value = objective_value(m)
    sol = value.(x)

    return obj_value, sol
end

function gurobi_LPP_solver(g, bids)
    l = length(bids)
    n_nodes = nv(g)

    prices = [bids[i][2] for i in 1:l]

    m = Model(Gurobi.Optimizer)
    set_optimizer_attribute(m, "OutputFlag", 0)

    @variable(m, x[1:n_nodes, 1:n_nodes], Bin)

    @objective(m, Max, sum(x[i, j] * prices[j] for i in 1:l+1, j in 1:l))

    # flow conservation constraints
    @constraints(m, begin
        [i=1:l], sum(x[i, j] for j in 1:l if j != i) - sum(x[j, i] for j in 1:l if j != i) == 0
        sum(x[l+1, j] for j in 1:l) - sum(x[j, l+1] for j in 1:l) == 1
        sum(x[l+2, j] for j in 1:l) - sum(x[j, l+2] for j in 1:l) == -1
    end)
    
    # capacity constraints
    @constraint(m, [j=1:l], sum(x[i, j] for i in 1:l) <= 1)

    
    # Intersecting bids constraints
    for i in 1:l
        for j in i+1:l
            intersecting_items = intersect(bids[i][1], bids[j][1])
            if !isempty(intersecting_items)
                @constraint(m, sum(x[k, i] for k in intersecting_items) + sum(x[k, j] for k in intersecting_items) <= 1)
            end
        end
    end

    optimize!(m)

    obj_value = objective_value(m)
    sol = value.(x)

    return obj_value, sol
end