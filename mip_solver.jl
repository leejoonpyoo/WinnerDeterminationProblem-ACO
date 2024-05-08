include("functions.jl")

using JuMP, Gurobi, CPLEX

function WDP_MIP_solver(k, l, bids)
    A = zeros(Int, k, l)
    prices = [bid[2] for bid in bids]

    for j in 1:l
        for item in bids[j][1]
            A[item, j] = 1
        end
    end

    m = Model(Gurobi.Optimizer)
    # m = Model(CPLEX.Optimizer)
    set_optimizer_attribute(m, "OutputFlag", 0)

    @variable(m, x[1:l], Bin)
    
    @objective(m, Max, sum(x[i] * prices[i] for i in 1:l))
    
    @constraint(m, [i=1:k], sum(A[i, j]*x[j] for j in 1:l) <= 1)
    
    println("Optimizing WDP...")
    elapsed_time = @elapsed optimize!(m)
    println("WDP Optimization Time: $(elapsed_time) seconds")

    obj_value = objective_value(m)
    sol = value.(x)

    return obj_value, sol
end

function LPP_MIP_solver(bids)
    unique_bids = find_unique_bids(bids)
    g = create_graph(unique_bids)

    l = length(unique_bids)
    n_nodes = nv(g)

    prices = [unique_bids[i][2] for i in 1:l]
    push!(prices, 0)  # Add price for l+1 (source)
    push!(prices, 0)  # Add price for l+2 (sink)

    m = Model(Gurobi.Optimizer)
    set_optimizer_attribute(m, "OutputFlag", 0)

    @variable(m, x[1:n_nodes, 1:n_nodes], Bin)

    @objective(m, Max, sum(x[i, j] * prices[j] for i in 1:n_nodes, j in 1:n_nodes))

    # basic constraints
    @constraint(m, [i=1:n_nodes], x[i,i] == 0)
    @constraint(m, [i=1:l], x[i, l+1] == 0)
    @constraint(m, [i=1:l], x[l+2, i] == 0)

    # flow conservation constraints
    @constraint(m, [i=1:l], sum(x[i, j] for j in 1:l+2) - sum(x[j, i] for j in 1:l+2) == 0)
    @constraint(m, sum(x[l+1, j] for j in 1:l) == 1)
    @constraint(m, sum(x[j, l+2] for j in 1:l) == 1)

    # capacity constraints
    @constraint(m, [i=1:n_nodes], sum(x[i, j] for j in 1:n_nodes) <= 1)
    @constraint(m, [j=1:n_nodes], sum(x[i, j] for i in 1:n_nodes) <= 1)

    # Intersecting bids constraints
    for i in 1:l
        for j in i+1:l
            @constraint(m, x[i, j] + x[j, i] <= 1)
            intersecting_items = intersect(unique_bids[i][1], unique_bids[j][1])
            if !isempty(intersecting_items)
                @constraint(m, x[i, j] == 0)
                @constraint(m, x[j, i] == 0)
            end
        end
    end

    # Dominated bids constraints
    item_bid_map = Dict{Int, Vector{Int}}()
    for i in 1:l
        for item in unique_bids[i][1]
            if !haskey(item_bid_map, item)
                item_bid_map[item] = Vector{Int}()
            end
            push!(item_bid_map[item], i)
        end
    end

    for item in keys(item_bid_map)
        bid_indices = item_bid_map[item]
        @constraint(m, sum(x[i, j] for i in bid_indices, j in 1:n_nodes) <= 1)
    end

    println("Optimizing LPP...")
    elapsed_time = @elapsed optimize!(m)
    println("LPP Optimization Time: $(elapsed_time) seconds")

    obj_value = objective_value(m)
    sol = value.(x)

    return obj_value, sol
end

