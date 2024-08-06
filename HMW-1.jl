## Dear Comrade, in this HW you have two tasks
##You shall now implement quadratic search method for finding minima of a fucntion


### Run the following part to see if there is any package that you need to install
### if something goes wrong, watch the error message and install the needed package by 

using Pkg
Pkg.add("BSON")
using BSON
import Base: isapprox
using Test
### Run the following function as it is needed for comparison purposses
function isapprox((a,b)::Tuple{T, T}, (c,d)::Tuple{L, L}; rtol = 1e-2) where {T <: Real, L <: Real}
    return abs(a-c) < rtol && abs(b-d) < rtol
end
###
###  
### Scroll down for your HW
### Before getting started you should write your student_number in integer format
const student_number::Int64 =  13474139978 ## <---replace 0 by your student_number 
###
###
###

function find_minimum_quadratic_search(f::Function, 
    x_1::Real, 
    x_3::Real; 
    max_iter::Int = 100, 
    ϵ::Float64 = 1e-5)::Tuple{Float64, Float64}
    ## Beginning of the function ##
    ## Your code goes here your function should return a tuple of the form α, f(α), 
    ## where α is the point where the minimum is attained. 
    x_2 = (x_1 + x_3) / 2 #mid value of x_1 and x_3
    f1, f2, f3 = f(x_1), f(x_2), f(x_3)
    a = f1*(x_2 - x_3) + f2*(x_3 - x_1) + f3*(x_1 - x_2)
    b = (x_2^2 - x_3^2)*f1 + (x_3^2 - x_1^2)*f2 + (x_1^2 - x_2^2)*f3
    c = x_1*x_3*(x_1 - x_3)*f2 + x_2*x_3*(x_3 - x_2)*f1 + x_1*x_2*(x_2 - x_1)*f3
    x0bar =x_2   #higher value is taken
    k=0 #k is number of iteration method
    for k in 1:max_iter  
        # the vertex of the quadratic, which is the minimum point (like parabola vertex)
        x_4 = -b / (2*a)
        # Update points
        if  x_4 > x_2 && x_4 < x_2 
            if f(x_4) < f(x_2)
                x_3=x_2
                x_2=x_4
            else
                x_1 = x_4
            end
        else
            if f(x_4) < f(x_2)
                x_1=x_2
                x_2=x_4
            else
                x_3 = x_4
            end
        end
        
        # Check for convergence
        if abs(x_4 - x0bar) < ϵ
            break
        end
    end

    x0bar= x_2
    return x0bar, f(x0bar) 
    
end

## Before going to unit_test run the next cell see what ya doin?
find_minimum_quadratic_search(x->x^2 -1 , -1, 1)
### 
 
## Unit test for bisection ###
function unit_test_for_quadratic_search()
    @assert student_number != 0 "Mind your student number please!!!!"
    @assert isa(find_minimum_quadratic_search(x->x^2 , -1, 1), Tuple{Float64, Float64}) "Return type should be a tuple of Float64"
    try
        @assert isapprox(find_minimum_quadratic_search(x->x^2 -1 , -1, 1), (0.0, -1.0); rtol = 1e-2)
        @assert isapprox(find_minimum_quadratic_search(x->-sin(x), 0.0, pi), (pi/2, -1.0); rtol = 1e-2)
        @assert isapprox(find_minimum_quadratic_search(x->x^4+x^2+x, -1, 1; max_iter = 1000), (-0.3859, -0.2148); rtol = 1e-2)              
    catch AssertionError
        @info "Something went wrong buddy checkout your implementation"
        throw(AssertionError)
    end
    @info "This is it pal!!!!, you are done!!!"
    return 1
end

## Run the unit_test_for_bisection to see if your doing goood!!!
unit_test_for_quadratic_search()
### 

#### Seesm that we are done here congrats comrade, you have completed this task successsssfuly.

##### No need to run anything below!!!!
if abspath(PROGRAM_FILE) == @_FILE_

    G::Int64 = unit_test_for_quadratic_search()
    dict_ = Dict("std_ID"=>student_number, "G"=>G)
    try
        BSON.@save "$(student_number).res" dict_ 
        catch Exception 
            println("something went wrong with", Exception)
    end
end