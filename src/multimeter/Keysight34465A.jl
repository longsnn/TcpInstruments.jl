function range_plc_to_resolution(instr::Instr{KeysightDMM34465A}, range::Union{String,Unitful.Voltage}, plc)

    # Resolution table used to get resolution using range as row, plc as column
    #  power-line cycles        100   10   1   0.2   0.06  0.02 0.006 0.002 0.001
    range_plc_to_resolution = [                                                   # Range [V}
                                3e-9 1e-8 3e-8 7e-8 1.5e-7 3e-7 6e-7 15e-7 30e-8; # 0.1
                                3e-8 1e-7 3e-7 7e-7 1.5e-6 3e-6 6e-6 15e-6 30e-7; # 1
                                3e-7 1e-6 3e-6 7e-6 1.5e-5 3e-5 6e-5 15e-5 30e-6; # 10
                                3e-6 1e-5 3e-5 7e-5 1.5e-4 3e-4 6e-4 15e-4 30e-5; # 100
                                3e-5 1e-4 3e-4 7e-4 1.5e-3 3e-3 6e-3 15e-3 30e-4; # 1000
                              ]

    range_idx = get_range_idx(instr, range)
    plc_idx = get_power_line_cycles_idx(instr, plc)

    return range_plc_to_resolution[range_idx,plc_idx]

end

function get_range_idx(instr::Instr{KeysightDMM34465A}, range::String)::Int
    if range == "MAX"
        range = 1000u"V"
    end

    if range in ["DEF", "DEFAULT"]
        range = 10u"V"
    end

    if range == "MIN"
        range = 0.1u"V"
    end

    return get_range_idx(instr, range)

end


get_range_idx(instr::Instr{KeysightDMM34465A}, range::Unitful.Voltage)::Int = findfirst( x -> x == range, [ 0.1u"V", 1u"V", 10u"V", 100u"V", 1000u"V" ] )
get_power_line_cycles_idx(instr::Instr{KeysightDMM34465A}, plc) = findfirst( x -> x == plc, [ 100, 10, 1, 0.2, 0.06, 0.02, 0.006, 0.002, 0.001]  )
verify_voltage_power_line_cycles(instr::Instr{KeysightDMM34465A}, plc) = !(plc in [100, 10, 1, 0.2, 0.06, 0.06, 0.006, 0.002,  0.001]) && error("power-line cycles value of \"$plc\" is not valid!\nIt's value must be 100, 10, 1, 0.2, 0.06, 0.02, 0.006, 0.002, 0.001.")
