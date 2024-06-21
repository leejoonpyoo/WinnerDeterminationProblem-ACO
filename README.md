# Winner Determination Problem in Combinatorial Auctions

This project implements multiple approaches, including a graph-based ant algorithm, to solve the Winner Determination Problem (WDP) in combinatorial auctions. The primary objective is to determine the winning bids that maximize the total value while ensuring no item is allocated more than once.

## Project Structure

- `functions.jl`: Contains functions for generating instances, finding unique bids, and creating graphs.
- `mip_solver.jl`: Implements the Mixed Integer Programming (MIP) solver for the WDP using JuMP and Gurobi.
- `traca.jl`: Implements the graph-based ant algorithm (TRACA) for solving the WDP.
- `main.jl`: Main script to run the different solvers and output the results.

## Getting Started

### Prerequisites

- Julia programming language
- JuMP package
- Gurobi package
- DataStructures package
- Graphs package
- Combinatorics package
- Random package
- StatsBase package

### Installation

1. Install Julia from the [official website](https://julialang.org/).
2. Install the required Julia packages by running the following commands in the Julia REPL:

    ```julia
    using Pkg
    Pkg.add("JuMP")
    Pkg.add("Gurobi")
    Pkg.add("DataStructures")
    Pkg.add("Graphs")
    Pkg.add("Combinatorics")
    Pkg.add("Random")
    Pkg.add("StatsBase")
    ```

3. Ensure you have Gurobi installed and properly configured. Follow the instructions on the [Gurobi website](https://www.gurobi.com/documentation/9.1/quickstart_mac/the_gurobi_command_line.html) for installation and licensing.

## Running the Models

1. Include the function and model files:

    ```julia
    include("functions.jl")
    include("mip_solver.jl")
    include("traca.jl")
    ```

2. Execute the `main.jl` script:

    ```julia
    include("main.jl")
    ```

## Explanation of Models

### WDP MIP Solver

This approach formulates the WDP as a Mixed Integer Programming (MIP) problem. The model maximizes the total value of the winning bids while ensuring that no item is allocated more than once.

### LPP MIP Solver

This approach formulates the WDP as a Linear Programming Problem (LPP) and uses Mixed Integer Programming (MIP) to solve it. The model creates a graph representation of the bids and solves the problem by maximizing the flow.

### TRACA Algorithm

The TRACA (graph-based ant algorithm) uses a heuristic approach inspired by ant colony optimization to solve the WDP. The algorithm iteratively constructs solutions and updates pheromone trails based on the quality of the solutions found.

## Reference

This project is based on the paper: "A Graph-Based Ant Algorithm for the Winner Determination Problem in Combinatorial Auctions" by Abhishek Ray, Mario Ventresca, and Karthik Kannan, published in INFORMS in 2021. You can find the paper [here](https://pubsonline.informs.org/doi/10.1287/isre.2021.1031).

## Conclusion

- The MIP solver is effective for finding the optimal solution for the WDP.
- The TRACA algorithm provides a competitive heuristic approach with good performance in reasonable computation times.
- Combining different methods and comparing their results helps in understanding the strengths and limitations of each approach.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Abhishek Ray, Mario Ventresca, and Karthik Kannan for the foundational paper on the WDP.
- The Julia and JuMP communities for their support and development of the necessary packages.

