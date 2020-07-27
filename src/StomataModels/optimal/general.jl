###############################################################################
#
# Solve for stomatal conductance from environmental conditions
# Description in general model section in the empirical folder
# The one without ind is useful for Eller, Sperry Wang, WAP, and WAPMod models
# The one with ind is useful for Wang, WAP, and WAPMod models
#
###############################################################################
function leaf_photo_from_envir!(
            photo_set::AbstractPhotoModelParaSet{FT},
            canopyi::CanopyLayer{FT},
            hs::LeafHydraulics{FT},
            envir::AirLayer{FT},
            sm::OptimizationStomatalModel{FT}
) where {FT<:AbstractFloat}
    # update the temperature dependent parameters and maximal a and kr
    update_leaf_TP!(photo_set, canopyi, hs, envir);
    update_leaf_AK!(photo_set, canopyi, hs, envir);

    # calculate optimal solution for each leaf
    for ind in eachindex(canopyi.APAR)
        canopyi.ps.APAR = canopyi.APAR[ind];
        leaf_ETR!(photo_set, canopyi.ps);
        leaf_photo_from_envir!(photo_set, canopyi, hs, envir, sm, ind);
    end
end




function leaf_photo_from_envir!(
            photo_set::AbstractPhotoModelParaSet{FT},
            canopyi::CanopyLayer{FT},
            hs::LeafHydraulics{FT},
            envir::AirLayer{FT},
            sm::OptimizationStomatalModel{FT},
            ind::Int
) where {FT<:AbstractFloat}
    # if there is light
    if canopyi.APAR[ind] > 1
        # unpack required variables
        @unpack ec, g_max, g_min, p_sat = canopyi;
        @unpack p_atm, p_H₂O = envir;
        _g_bc   = canopyi.g_bc[ind];
        _g_bw   = canopyi.g_bw[ind];
        _g_m    = canopyi.g_m[ind];

        # calculate the physiological maximal g_sw
        _g_crit = ec / (p_sat - p_H₂O) * p_atm;
        _g_max  = 1 / max(1/_g_crit - 1/_g_bw, FT(1e-3));
        _g_max  = min(_g_max, g_max);

        # if _g_sw is lower than g_min
        if _g_max <= g_min
            canopyi.g_sw[ind] = FT(0);

        # if _g_sw is higher than g_min
        elseif canopyi.a_max[ind] < 0.05
                canopyi.g_sw[ind] = FT(0);
        else
            # solve for optimal g_lc, A and g_sw updated here
            _gh    = 1 / (1/_g_bc + FT(1.6)/_g_max + 1/_g_m);
            _gl    = 1 / (1/_g_bc + FT(1.6)/g_min  + 1/_g_m);
            _sm    = NewtonBisectionMethod{FT}(_gl, _gh, (_gl+_gh)/2);
            _st    = SolutionTolerance{FT}(1e-4, 50);
            @inline f(x) = envir_diff!(x, photo_set, canopyi, hs, envir, sm, ind);
            _solut = find_zero(f, _sm, _st);

            #= used for debugging
            @show _g_sw;
            @show _g_max;
            @show leaf.p_ups;
            @show _solut;
            println("");
            =#

            # update leaf conductances and rates
            update_leaf_from_glc!(photo_set, canopyi, envir, ind, _solut);
        end

    # if there is no light
    else
        canopyi.g_sw[ind] = FT(0);
    end

    # make sure g_sw in its range
    leaf_gsw_control!(photo_set, canopyi, envir, ind);

    return nothing
end
