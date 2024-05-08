include("functions.jl")

using Random, LinearAlgebra

function traca(initial_bids, n_ants, n_iterations, evaporation_rate, alpha, beta, tau0)
    bids = find_unique_bids(initial_bids)
    g = create_graph(bids)

    push!(bids, (Set{Int}(), 0))  # Add source
    push!(bids, (Set{Int}(), 0))  # Add sink
    
    n_nodes = nv(g)

    prices = [bids[i][2] for i in 1:n_nodes]

    pheromones = fill(tau0, n_nodes, n_nodes)
    best_solution = zeros(Int, n_nodes, n_nodes)
    best_obj_value = -Inf

    for iteration in 1:n_iterations
        solutions = zeros(Int, n_ants, n_nodes, n_nodes)
        obj_values = zeros(Float64, n_ants)

        for ant in 1:n_ants
            solution = zeros(Int, n_nodes, n_nodes)
            visited = falses(n_nodes)
            visited_items = Set()
            current_node = n_nodes - 1
            visited[current_node] = true

            while current_node != n_nodes
                probabilities = Float64[]
                neighbors = collect(outneighbors(g, current_node))
                total_prob = 0.0

                for neighbor in neighbors
                    if !visited[neighbor] 
                        if isempty(intersect(visited_items, bids[neighbor][1]))
                            prob = (pheromones[current_node, neighbor]^alpha) * ((prices[neighbor])^beta)
                            push!(probabilities, prob)
                            total_prob += prob
                        else
                            push!(probabilities, 0.0)
                        end
                    else
                        push!(probabilities, 0.0)
                    end
                end

                if total_prob == 0.0
                    next_node = n_nodes
                    solution[current_node, next_node] = 1
                    current_node = next_node
                else
                    # Normalize probabilities
                    probabilities ./= total_prob

                    next_node = sample(neighbors, Weights(probabilities))
                    if visited[next_node]
                        break
                    end
                    solution[current_node, next_node] = 1
                    visited[next_node] = true
                    current_node = next_node
                    union!(visited_items, bids[current_node][1])
                end
            end

            solutions[ant, :, :] = solution
            obj_values[ant] = sum(solution .* prices)
        end

        best_ant = argmax(obj_values)
        before_obj_value = best_obj_value
        if obj_values[best_ant] > best_obj_value
            best_obj_value = obj_values[best_ant]
            best_solution = solutions[best_ant, :, :]
        end

        # Pheromone evaporation
        pheromones *= (1 - evaporation_rate)

        # Pheromone update
        update_probability = 1 / 3
        # choose update option
        option = 1
        k = 2 # k>1

        if option == 1
            if rand() < update_probability
                # Option 1: Global best pheromone update parameters
                tau_delta = best_obj_value - before_obj_value
                tau_max = tau_delta / evaporation_rate
                tau_min = tau_max / sum(best_solution)

                for ant in 1:n_ants
                    for i in 1:n_nodes
                        for j in 1:n_nodes
                            if solutions[ant, i, j] == 1
                                pheromones[i, j] += tau_delta
                                pheromones[i, j] = clamp(pheromones[i, j], tau_min, tau_max)
                            end
                        end
                    end
                end
            end
        elseif option ==2
            if rand() < update_probability
                # Option 2: Iteration best pheromone update parameters
                tau_delta = obj_values[best_ant] - before_obj_value
                tau_max = tau_delta / evaporation_rate
                tau_min = tau_max * sum(solutions[best_ant, :, :])

                for ant in 1:n_ants
                    for i in 1:n_nodes
                        for j in 1:n_nodes
                            if solutions[ant, i, j] == 1
                                pheromones[i, j] += tau_delta
                                pheromones[i, j] = clamp(pheromones[i, j], tau_min, tau_max)
                            end
                        end
                    end
                end
            end
        else
            if rand() < update_probability
                # Option 3: Fixed pheromone update parameters
                tau_delta = (best_obj_value + obj_values[best_ant]  - 2*before_obj_value)/2
                tau_max = k*tau0
                tau_min = tau0/k

                for ant in 1:n_ants
                    for i in 1:n_nodes
                        for j in 1:n_nodes
                            if solutions[ant, i, j] == 1
                                pheromones[i, j] += tau_delta
                                pheromones[i, j] = clamp(pheromones[i, j], tau_min, tau_max)
                            end
                        end
                    end
                end
            end
        end

    end

    return best_obj_value, best_solution
end