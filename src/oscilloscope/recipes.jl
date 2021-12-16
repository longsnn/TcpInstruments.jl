@recipe function plot(data::ScopeData; label="", xguide="0", yguide="Voltage / V")
    scaled_time, volts, t, l, x, y= plot_helper(data; label=label, xguide=xguide, yguide=yguide)
    title := t
    label := l
    xguide := x
    yguide := y
    return scaled_time, volts
end


@recipe function plot(data_array::Array{ScopeData, 1}; label="", xguide="0", yguide="Voltage / V")
    for data in data_array
        @series begin
            scaled_time, volts, t, l, x, y= plot_helper(data; label=label, xguide=xguide, yguide=yguide)
            title := t
            label := l
            xguide := x
            yguide := y
            return scaled_time, volts
        end
    end
end


function plot_helper(data::ScopeData; label="", xguide="0", yguide="Voltage / V")
    time_unit, scaled_time = autoscale_seconds(data.time)
    title = "Oscilloscope ~ Voltage Vs. Time (" * time_unit * ")"
    if isempty(label)
        label = "Channel $(data.info.channel)"
    else
        label = label
    end
    if xguide == "0"
        xguide = "Time / " * time_unit
    else
        xguide = xguide
    end
    return ustrip(scaled_time), ustrip(data.volt), title, label, xguide, yguide
end
