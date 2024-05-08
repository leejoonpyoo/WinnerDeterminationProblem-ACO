using DataStructures, Graphs, Combinatorics, Random, StatsBase

# k: Number of items, l: Number of bids
function sample_instances(k, l)
    bids = Tuple{Array{Int64,1}, Int64}[]

    min_items = max(1, round(Int, k * 0.05))  
    max_items = min(k, round(Int, k * 0.15))  

    # 각 비드 생성
    for i in 1:l
        # 랜덤 아이템 개수: 설정된 최소와 최대 사이
        item_count = rand(min_items:max_items)

        # 아이템 랜덤 선택
        selected_items = sample(1:k, item_count, replace=false)

        # 랜덤 가격 설정
        price = rand(20:100)

        # 비드 배열에 추가
        push!(bids, (selected_items, price))
    end

    return bids
end

function find_unique_bids(bids)
    bid_dict = Dict{Set{Int}, Int}()

    for bid in bids
        subset, price = bid
        subset_set = Set(subset)  
        if !haskey(bid_dict, subset_set) || bid_dict[subset_set] < price
            bid_dict[subset_set] = price
        end
    end

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