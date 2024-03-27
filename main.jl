include("solver.jl")
include("generate_data.jl")
include("functions.jl")

k = 5
l = 10

function run_exp()
    bids = sample_instances(k, l)

    obj_value, sol = gurobi_WDP_solver(k, l, bids)
    println("WDP Objective Value: ", obj_value)
    println("WDP Solution: ", sol)

    unique_bids = find_unique_bids(bids)
    g = create_graph(unique_bids)
    
    obj_value, sol = gurobi_LPP_solver(g, unique_bids)
    println("LPP Objective Value: ", obj_value)
    println("LPP Solution: ", sol)
end

run_exp()




