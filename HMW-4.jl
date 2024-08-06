using Statistics
using BSON
using Random
using LinearAlgebra
using Zygote
using ProgressBars



#### ----- ###
cd(@__DIR__)
#### Before getting started you should write your student_number in integer format
const student_number::Int64 = 1234567891 ## <---replace 0 by your student_number 
### ---- ###
## In this homework we will do a little constrained optimization to approixmate local minima of some function
## To do this you will use penalty methods
## See the slides for further information
## Here is your optimization problem
## Minimize f(x,y) = (x^2 + y -11)^2 + (x+ y^2 - 7)^2
## subject to norm([x,y]) <= 3.60
## and x+y = 5


### write your objective function, mind the args please!!!
function objective(x::AbstractVector)::Float64
   # My function is " f(x,y) = (x^2 + y -11)^2 + (x+ y^2 - 7)^2" 
    # Write function 
    return (x[1]^2 + x[2] - 11)^2 + (x[1] + x[2]^2 - 7)^2
end
## write your constraints, mind the args please!!!
function constraints(x::AbstractVector)::Tuple{Float64, Float64}

     ## You will use some penalty functions here, 
    ## Make sure that you pick up the rigth penaly functions
    ## one is the function of the constraint norm(x) ≤ 3.6
    ## the other one is for x+y = 5
    ## you should see  something like at the end::::  constraints([1.0, 2.0]) = (0, 1111)
    ## the numbers on the right may change depending on your penalty functions.
    
    # Constraint 1: [x, y]_2 <= 3.60
    # If the norm of the vector [x, y] exceeds 3.60, apply a penalty.
    penalty1 = max(0, norm(x) - 3.60)

    # Constraint 2: x + y = 5
    # If the sum of x and y does not equal 5, apply a penalty.
    penalty2 = abs(x[1] + x[2] - 5)

    return penalty1, penalty2
end



function unit_test_1()::Bool
    @assert student_number != 0 "Checkout your student number!!!"
    #
    @assert objective([0.0, 0.0])[1] == 170.0 "Check the objective function"
    @assert objective([0.0, 1.0])[1] == 136.0 "Check the objective function"
    @assert objective([1.0, 1.0])[1] == 106.0 "Check the objective function"
    #
    @assert constraints([1.0, 4.0])[1] > 0.0 "Check the constraint function"
    @assert constraints([0.0, 3.0])[1] == 0.0 "Check the constraint function"
    ## Do something here!!!
    @assert constraints([1.0, 4.0])[2] == 0.0 "Check the constraint function"
    @assert constraints([3.0, 2.0])[2] == 0.0 "Check the constraint function"
    
    ##
    @info "OK Computer!!!"
    return 1
end

### See what you got for us!!!
unit_test_1( )
## ---------------------------------------------------------------- ###
## Let's write the minimize function
## It should return ---- just --- updated x_init
## No println statements !!!!!! just return what you are asked for!!!!
function minimize(objective::Function, 
    constraints::Function, 
     ## The penalty term for the first constraint norm(x) <= 3.6
    λ::Float64, 
    ## The penalty term for the first constraint x[1] + x[2] = 5.0
    μ::Float64, 
    x_init::AbstractVector;
    max_iter::Int64 = 100, 
    lr::Float64 = 0.001,
    stopping_criterion::Float64 = 1e-4)::AbstractVector
    ## Your code here### 
    ### Update the gradients in a for loop ###
    x = x_init
    for _ in 1:max_iter
        # Compute the gradient of the objective function with respect to x,
        # including the penalty terms for the constraints
        grad = Zygote.gradient(x -> objective(x) + λ * constraints(x)[1] + μ * constraints(x)[2], x)[1]
         # Update x using gradient descent
        x -= lr * grad
        # Check the stopping criterion
        # if the norm of the gradient is below the specified threshold, stop iterating
        if norm(grad) < stopping_criterion
            break
        end
    end
    return x
end
## Let's give a try!!!
minimize(x->objective(x),x->constraints(x), 10.0, 10.0, randn(2); lr = 0.001, max_iter = 1000)


function unit_test_2()
    @info "The test started"
    @noinline for i in ProgressBar(1:10000)
        Random.seed!(i)
        x_init = minimize(x->objective(x),x->constraints(x), 10.0, 10.0, randn(2); lr = 0.00008, max_iter = 1000)
        const_1, const_2 = norm(x_init), sum(x_init)
        if norm([3,2])-1e-5 < const_1 < norm([3,2]) && isapprox(const_2, 5.0; atol = .01)
            @info "Ok buddy, you are doing goooooood!!! the point is $(x_init)"
            return 1
        end
    end
    @info "I am sorry pal! something is wrong with your implementations"
    return 0
end


## See what got for us!!!
unit_test_2()
### 



## No need to run below!!!
if abspath(PROGRAM_FILE) == @__FILE__
    G::Int64 = unit_test_1()+unit_test_2()
    dict_ = Dict("std_ID"=>student_number, "G"=>G)
    try
        BSON.@save "$(student_number).res" dict_ 
        catch Exception 
            println("something went wrong with", Exception)
    end

end





