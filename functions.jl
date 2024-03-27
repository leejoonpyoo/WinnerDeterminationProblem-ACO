using DataStructures, Graphs

function find_unique_bids(bids)
    # Efficient look-up and update를 위한 딕셔너리 사용
    bid_dict = Dict{Set{Int}, Int}()

    for bid in bids
        subset, price = bid
        subset_set = Set(subset) # Ensure the subset is treated as a Set
        if !haskey(bid_dict, subset_set) || bid_dict[subset_set] < price
            bid_dict[subset_set] = price
        end
    end

    # 딕셔너리를 일반 리스트로 변환
    unique_bids = [(subset, price) for (subset, price) in bid_dict]

    return unique_bids
end

function create_graph(unique_bids)
    # Number of unique bids
    m = length(unique_bids)

    # Create a graph with m+2 nodes 
    n_nodes = m + 2
    g = SimpleDiGraph(n_nodes)

    # Define source and target node 
    source = n_nodes - 1
    target = n_nodes

    for i in 1:m
        add_edge!(g, source, i)
        add_edge!(g, i, target)
    end

    for i in 1:m
        for j in 1:m
            if i != j && isempty(intersect(unique_bids[i][1], unique_bids[j][1]))
                add_edge!(g, i, j)
            end
        end
    end

    return g
end
