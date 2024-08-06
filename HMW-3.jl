
### Run the following part to see if there is any package that you need to install
### if something goes wrong, watch the error message and install the needed package by 
### Pkg.add("missing_package")
using Pkg
using Plots: plot, plot!
using Statistics
using BSON
using Random
using LinearAlgebra
using Zygote
using LinearAlgebra




#### ----- ###
cd(@__DIR__)
#### Before getting started you should write your student_number in integer format
const student_number::Int64 = 1234567891 ## <---replace 0 by your student_number 
### ---- ###
## Assume that you are given a matrix A. In this assignment you will need to find inverse of A provided that it is invertibble, 
## you want to determine B so that AB is close to I_d as much as possible use LinearAlgebra.norm!!!!.
## and solve this problem as an unconstrained optimization problem.
## We will now do this step by step. 
## Given A, pick B similar to A (has the same shape)
## 1) Implement your objective function (if you use norm, make sure you take its square not itself!)
## 2) Fix your learning rate, and max_iter
## 3) Do gradient descent until some convergence stopping_criterions are met!!!
## 3.5) If your matrix is not invertible your function should throw an error!!!
### 4) Remember that matrix A should be square and has non-zero determinant in order to be invertible. 

function objective(A::AbstractMatrix, B::AbstractMatrix)::AbstractFloat
    # Checking if A is square
    @assert size(A)[1] == size(A)[2] "Matrix A should be square"
    # Checking if A is invertible
    @assert !isapprox(det(A), 0) "Matrix A should be invertible"
    # Calculating the objective function value
    return norm(A * B - I) ^ 2
end



### Some unit test as usual!!!!
function unit_test_objective()::Bool
    for _ in 1:100
        let 
            A = randn(100, 100)
            objective(A, A^-1)
            @assert isapprox(objective(A,A^(-1)),0; atol = 1e-3) "Something went wrong!!!"
        end
    end
    @info "Oki Doki!!!"
    return 1
end

## Let's give a try to objective function!!!!
unit_test_objective()


function fit_(A::AbstractMatrix;
    lr::Float64 = 0.001, 
    max_iter::Int64 = 1000,
    stopping_criterion::Float64 = 1e-2)
     ## Your code here ##
     # Initialize B as a random matrix of the same size as A
    B = randn(size(A))
    
    # Perform gradient descent
    for i in 1:max_iter
        # Calculate gradient
        # We used \nabla + space key to print the nabla symbol.
        ∇ = Zygote.gradient(B -> objective(A, B), B)[1]
        # Update B using gradient descent
        B -= lr * ∇
        # Check convergence
        if norm(∇) < stopping_criterion
            println("Convergence reached after $i iterations")
            break
        end
    end
    
    return B
end

## Let's give a try to see what happens!!!
a = randn(10,10)
q = fit_(a, max_iter = 10000, lr = 0.01, stopping_criterion = 1e-4)
##Is the following matrix close to identity matrix?
q*a 
## 

function unit_test_fit()
    Random.seed!(0)
    A = randn(3,3)
    try
        @assert isapprox(A\I(3), fit_(A, max_iter = 20000, lr = 0.001), atol = 1e-1)
    catch AssertionError
        @info "You gotto do it again Pal!!, adjust the learning rate and watch the convergence!!!"
        throw("Something went wrong!!!!")
    end
    @info "Great Success!!! Grab a cup of coffeeeeee!!!!"
    return 1
end



## Run the next function to see you are doing good!!!
unit_test_fit()
##Great!!!!

## No need to run below!!!
if abspath(PROGRAM_FILE) == @__FILE__
    G::Int64 = unit_test_objective()+unit_test_fit()
    dict_ = Dict("std_ID"=>student_number, "G"=>G)
    try
        BSON.@save "$(student_number).res" dict_ 
        catch Exception 
            println("something went wrong with", Exception)
    end

end

