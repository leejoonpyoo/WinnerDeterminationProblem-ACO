using Graphs, SimpleWeightedGraphs, DataStructures

function find_unique_bids(bids)
    # Using a dictionary for efficient look-up and update
    bid_dict = Dict{Set{Int}, Int}()

    for bid in bids
        subset, price = bid
        # If the subset is not in the dictionary or the new price is higher, update the dictionary
        if !haskey(bid_dict, subset) || bid_dict[subset] < price
            bid_dict[subset] = price
        end
    end

    # Convert the updated dictionary to a deque of tuples (for further operations if needed)
    unique_bids = Deque{Tuple{Set{Int}, Int}}()

    for (subset, price) in bid_dict
        push!(unique_bids, (subset, price))
    end

    return unique_bids
end

function create_graph(unique_bids)
    # Number of unique bids
    m = length(unique_bids)

    # Create a graph with m+2 nodes 
    n_nodes = m + 2
    g = SimpleWeightedDiGraph(n_nodes)

    # Define source and target node 
    source = n_nodes - 1
    target = n_nodes

    for i in 1:m
        add_edge!(g, source, i, unique_bids[i][2])
        add_edge!(g, i, target, 1)
    end

    for i in 1:m
        for j in 1:m
            if i != j && isempty(intersect(unique_bids[i][1], unique_bids[j][1]))
                add_edge!(g, i, j, unique_bids[j][2])
            end
        end
    end

    # subsets 
    subsets = [bid[1] for bid in unique_bids]

    return g, subsets
end
