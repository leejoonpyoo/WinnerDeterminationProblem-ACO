include("sample.jl")

function run_exp()
    unique_bids = [(Set([1]),3), (Set([2]),4), (Set([1,2]),9)]
    g, subsets = create_graph(unique_bids)
end
# run_exp()


unique_bids = [(Set([1]),3), (Set([2]),4), (Set([1,2]),9)]
g, subsets = create_graph(unique_bids)


