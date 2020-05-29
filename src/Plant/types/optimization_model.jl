#= AbstractOptimizationStomatalModel type tree
AbstractStomatalModel
---> AbstractOptimizationStomatalModel
    ---> OSMEller     # Eller 2018 Model
    ---> OSMSperry    # Sperry 2017 model
    ---> OSMWang      # Wang 2020 model
    ---> OSMWAP       # Wolf-Anderegg-Pacala model
=#

abstract type AbstractOptimizationStomatalModel <: AbstractStomatalModel end




"""
    OSMEller

An optimization model parameter set type for Eller model.
The equation used for Eller model is `∂Θ/∂E = -∂K/∂E * A/K`, where K is ∂E/∂P.

# Fields
$(DocStringExtensions.FIELDS)
"""
struct OSMEller  <: AbstractOptimizationStomatalModel end




"""
    OSMSperry

An optimization model parameter set type for Sperry model.
The equation used for Sperry model is `∂Θ/∂E = -∂K/∂E * Amax/Kmax`, where K is ∂E/∂P.

# Fields
$(DocStringExtensions.FIELDS)
"""
struct OSMSperry <: AbstractOptimizationStomatalModel end




"""
    OSMWang

An optimization model parameter set type for Eller type model.
The equation used for Eller model is `∂Θ/∂E = A / (E_crit - E)`.

# Fields
$(DocStringExtensions.FIELDS)
"""
struct OSMWang   <: AbstractOptimizationStomatalModel end




"""
    OSMWAP{FT}

An optimization model parameter set type for Wolf-Anderegg-Pacala type model.
The equation used for Wolf-Anderegg-Pacala model is `∂Θ/∂E = (2aP+b) / K`, where K is ∂P/∂E.

# Fields
$(DocStringExtensions.FIELDS)
"""
Base.@kwdef struct OSMWAP{FT} <: AbstractOptimizationStomatalModel
    "Quadratic equation parameter `[μmol m⁻² s⁻¹ MPa⁻²]`"
    a::FT = FT(0.5)
    "Quadratic equation parameter `[μmol m⁻² s⁻¹ MPa⁻¹]`"
    b::FT = FT(2.0)
end




"""
    OSMWAPMod{FT}

An optimization model parameter set type for Wolf-Anderegg-Pacala type model, modified by adding a photosynthesis component while set b and c = 0.
The equation used for modified Wolf-Anderegg-Pacala model is `∂Θ/∂E = a * P`, where P is absolute value of leaf xylem pressure.

# Fields
$(DocStringExtensions.FIELDS)
"""
Base.@kwdef struct OSMWAPMod{FT} <: AbstractOptimizationStomatalModel
    "Quadratic equation parameter `[mol mol⁻¹ MPa⁻¹]`"
    a::FT = FT(0.1)
end