using BenchmarkTools
using CSV
using DataFrames
using Statistics
using Test

using Land
using Land.CanopyRadiation
using Land.ConstrainedRootSolvers
using Land.WaterPhysics
using Land.PlantHydraulics
using Land.Photosynthesis
using Land.StomataModels
using Land.Plants




benchmarking = false;




ENV["JULIA_LOG_LEVEL"] = "WARN"




# Test the variable FT recursively
function recursive_FT_test(para, FT)
    # if the type is AbstractFloat
    if typeof(para) <: AbstractFloat
        try
            @test typeof(para) == FT
        catch e
            println("The not NaN test failed for ", para, " and ", FT)
        end
    # if the type is array
    elseif typeof(para) <: AbstractArray
        if eltype(para) <: AbstractFloat
            try
                @test eltype(para) == FT
            catch e
                println("The not NaN test failed for ", para, " and ", FT)
            end
        else
            for ele in para
                recursive_FT_test(ele, FT)
            end
        end
    else
        # try if the parameter is a struct
        try
            for fn in fieldnames( typeof(para) )
                recursive_FT_test( getfield(para, fn), FT )
            end
        catch e
            println(typeof(para), "is not supprted by recursive_FT_test.")
        end
    end
end




# Test the variable NaN recursively
function recursive_NaN_test(para)
    # if the type is Number
    if typeof(para) <: Number
        try
            @test !isnan(para)
        catch e
            println("The not NaN test failed for", para)
        end
    # if the type is array
    elseif typeof(para) <: AbstractArray
        for ele in para
            recursive_NaN_test(ele)
        end
    else
        # try if the parameter is a struct
        try
            for fn in fieldnames( typeof(para) )
                recursive_NaN_test( getfield(para, fn) )
            end
        catch e
            println(typeof(para), "is not supprted by recursive_NaN_test.")
        end
    end
end




# When moving any function from developing.jl to stable files,
# add corresponding test and docs




include("CanopyRadiation/test_bigleaf.jl"  );
include("CanopyRadiation/test_structs.jl"  );
include("CanopyRadiation/test_functions.jl");




# A S-shape function, e.g. Weibull function
function _r_func(x::FT) where {FT<:AbstractFloat}
    return exp( -1 * (x/2) ^ FT(0.8) ) - FT(0.5)
end

# A R-shape function
function _s_func(x::FT) where {FT<:AbstractFloat}
    return exp( -1 * (x/2) ^ 5 ) - FT(0.5)
end

# segmented function with solution 1
function _f0(x::FT) where {FT<:AbstractFloat}
    return x>1 ? FT(1) : x
end

# segmented function with solution 1
function _f1(x::FT) where {FT<:AbstractFloat}
    return x>1 ? 2-x : x
end

# segmented function with solution of upper end
function _f2(x::FT) where {FT<:AbstractFloat}
    return x>1 ? (1+x)/2 : x
end

# segmented function with solution 1
function _f3(x::FT) where {FT<:AbstractFloat}
    return x>1 ? 2-x : FT(0)
end

# segmented function with solution of lower bound
function _f4(x::FT) where {FT<:AbstractFloat}
    return x>1 ? 2-x : FT(1)
end

# segmented function with solution 1
function _f5(x::FT) where {FT<:AbstractFloat}
    return x>1 ? FT(0.5) : x
end

# surface function
function _surf_func(x::Array{FT,1}) where {FT<:AbstractFloat}
    return -(x[1]-2)^2 - (x[2]-3)^2
end

include("ConstrainedRootSolvers/test_findzero_bisection.jl"      );
include("ConstrainedRootSolvers/test_findzero_newtonbisection.jl");
include("ConstrainedRootSolvers/test_findzero_newtonraphson.jl"  );
include("ConstrainedRootSolvers/test_findzero_reducestep.jl"     );

include("ConstrainedRootSolvers/test_findpeak_bisection.jl"   );
include("ConstrainedRootSolvers/test_findpeak_neldermead.jl"  );
include("ConstrainedRootSolvers/test_findpeak_reducestep.jl"  );
include("ConstrainedRootSolvers/test_findpeak_reducestepND.jl");




include("WaterPhysics/test_diffusive_coefficient.jl");
include("WaterPhysics/test_latent_heat.jl"          );
include("WaterPhysics/test_surface_tension.jl"      );
include("WaterPhysics/test_vapor_pressure.jl"       );
include("WaterPhysics/test_viscosity.jl"            );




include("PlantHydraulics/test_struct.jl"     );
include("PlantHydraulics/test_vc_soil.jl"    );
include("PlantHydraulics/test_vc_xylem.jl"   );
include("PlantHydraulics/test_leaf.jl"       );
include("PlantHydraulics/test_legacy.jl"     );
include("PlantHydraulics/test_temperature.jl");
include("PlantHydraulics/test_root.jl"       );
include("PlantHydraulics/test_pressure.jl"   );
include("PlantHydraulics/test_plant.jl"      );




include("Photosynthesis/test_struct.jl"      );
include("Photosynthesis/test_TD.jl"          );
include("Photosynthesis/test_ETR.jl"         );
include("Photosynthesis/test_Ac.jl"          );
include("Photosynthesis/test_Aj.jl"          );
include("Photosynthesis/test_Ap.jl"          );
include("Photosynthesis/test_photo_pi.jl"    );
include("Photosynthesis/test_photo_glc.jl"   );
include("Photosynthesis/test_fluorescence.jl");




include("StomataModels/test_struct.jl"     );
include("StomataModels/test_gasexchange.jl");
include("StomataModels/test_empirical.jl"  );
include("StomataModels/test_solution.jl"   );




include("Plants/test_plants.jl");
