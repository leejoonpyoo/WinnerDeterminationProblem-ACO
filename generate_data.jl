using Combinatorics, Random

function sample_instances(k, l)
    # Generate all combinations of S
    all_combinations = [c for c in combinations(1:k)]

    # Select l random combinations
    random_subsets = rand(all_combinations, l)

    # Bidding prices for each subset
    prices = rand(1:100, l)

    bids = Tuple{Array{Int64,1}, Int64}[]

    for i in 1:l
        push!(bids, (random_subsets[i], prices[i]))
    end

    return bids
end