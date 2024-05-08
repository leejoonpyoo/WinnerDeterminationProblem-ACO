include("mip_solver.jl")
include("traca.jl")
include("functions.jl")

function main(k, l)
    bids = sample_instances(k, l)
    println("Number of items: ", k)
    println("Number of bids: ", l)

    obj_value_WDP, sol_WDP = WDP_MIP_solver(k, l, bids)
    println("WDP Objective Value: ", obj_value_WDP)
    #println("WDP Solution: ", sol_WDP)
    
    # obj_value_LPP, sol_LPP = LPP_MIP_solver(bids)
    # println("LPP-IP Objective Value: ", obj_value_LPP)
    # println("LPP Solution: ", sol_LPP)

    n_ants = 40
    n_iterations = 1500
    evaporation_rate = 0.05
    alpha = 2 # range: 1~5
    beta = 5 # range: 1~5
    tau0 = 1

    elapsed_time = @elapsed obj_value_TRACA, sol_TRACA = traca(bids, n_ants, n_iterations, evaporation_rate, alpha, beta, tau0)
    println("traca Objective Value: ", obj_value_TRACA)
    #println("TRACA Solution: ", sol_TRACA)

    # Gap 계산
    if obj_value_WDP > 0
        gap = (obj_value_WDP - obj_value_TRACA) / obj_value_WDP * 100
        println("Gap between WDP optimal and TRACA solution: ", gap, "%")
    end

    println("Execution time for TRACA: ", elapsed_time, " seconds")
end

#main(10, 10)
main(50, 100)
#main(50, 100)