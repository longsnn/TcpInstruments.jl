using Dates

function elapsed_time(start_time)
            seconds = floor(time() - start_time)
            return Time(0) + Second(seconds)
end
function elapsed_time(func, start_time)
            seconds = floor(time() - start_time)
            return Time(0) + Second(func(seconds))
end

"""
This function initializes connections with the xyz stage and the
Oscilloscope. The program does this by calling ky_xyz_init and
ky_scope_rs_init. This function takes 6 input arguements and 4 of those
are mandatory. If there is no previous structure settings from previous
initializations (if this is the first time the user calls this function),
leave settings blank. Also, the default stage will be 'new' if not
entered. This stage is the newer stage located in the larger lab room.

Input:
       xyz: The handle of desired xyz stage
     scope: Handle of desired scope
   channel: This input decides which channel the scope will read from.
sample_size: The amount of samples desired to be taken.


Ex.
```
lts = initialize(ThorlabsLTS150)
scope = initialize(Scope350MHz)
# Sample size 100, read from scope on channel 1
hydrophone = Hydrophone(lts, scope, 100, 1)
```
"""
struct Hydrophone 
    xyz
    scope
    channel
    sample_size
end

mutable struct Waveinfo
    info::Union{Waveform_info, Nothing}
    time::Union{Array{Float64, 1}, Nothing}
    waveinfo::Union{Array{Float64}, Nothing}
    coordinates::Union{Array{Tuple{Real, Real, Real}}, Nothing}
    unfiltered_waveform
end

Waveinfo() = Waveinfo(nothing, nothing, nothing, nothing, nothing)


"""
 wave_info_x = ky_hydro_scan_x(settings, axis_range, num_points, called)

 This function moves along the x axis and grabs data based on a fixed
 increment passed by the user. This program uses the ky_scope_rs_ch_data
 function that returns a structure with helpful information. There are
 three mantadory inputs and one optional input that is used only when this
 function is called by other functions and the printed messages should be
 supressed. The user usually doesn't have to use the variable called.

 Delete:
       settings: the structure for all controller connections.
 Input: 
     hydrophone: the structure for all controller connections.
        axis_range: A 1x2 or 1x1 array that contains the start and end point
                 of the desired range in the x-direction.
          num_points: The number of points the user desires to record along the
                 x-axis.
         called: This variable is either one or zero and is used to turn
                 off user notifications when another function calls this
                 one. User usually won't have to use this variable.

 Output:
   wave_info_x: A structure that contains the data that traces num_points of
                waveforms and the coordinates travelled. The waveforms are
                stored under wave_info_x.wave_form and the coordinates 
                travelled is stored under wave_info_x.coordinates. The
                coordinates are the (x, y, z) coordinates along the path
                that the function took.

 Example:
 scan_range = [0 1]; num_points = 5;
 wave_info_x = ky_hydro_scan_x(settings, scan_range, num_points);
"""
function intensity_scan_x(
    hydro, x_range, num_points;
    verbose=true, filter=false
)
    intensity_scan_single_axis(
        hydro, x_range, num_points, move_x_abs; verbose=verbose, filter=filter
    )
end

function intensity_scan_single_axis(
    hydro, axis_range, num_points, move_func;
    verbose=true, filter=false
)
    num_axis = 3 # Represents the three axis xyz
    start_time = time()

    # Ensure axis_range is within xyz limits
    x_low, x_high = hydro.xyz.get_limits_x()
    if !axis_range[begin] in x_low:x_high || !axis_range[end] in x_low:x_high
        error("Scan range is outside current limits of the xyz stage")
    end

    # Set X Positions Vector
    x_pos = if length(axis_range) == 1
        if num_points != 1
            error(
                "Can't measure multiple points when axis_range has one"* 
                " position"
            )
        end
        axis_range
    elseif length(axis_range) == 2
        range(axis_range[begin], stop=axis_range[end], length=num_points)
    else
        error("axis_range must have 1 or 2 elements")
    end

    # Pre-Allocate output matrices
    wave_info = Waveinfo() 
    wave_info.wave_form = zeros(hydro.sample_size, num_points)
    wave_info.coordinates = zeros(num_axis, num_points) 
    if filter
        wave_info.unfiltered_waveform = zeros(hydro.sample_size, num_points)
    end

    # Loop to scan positions
    for i in 1:num_points
        if verbose 
            loop_time = time()
            axis = split(string(move_func), '_')[2]
            @info "Scanning $axis-direction: $i/$num_points iterations"
        end

        first_pass = i == 1

        move_func(hydro.xyz, x_pos[i])

        # TODO: Pausing
        
        data = get_data(hydro.scope, hydro.channel)

        if data.info.num_points != hydro.sample_size
            error("Scope sample size is different from hydrophone")
        end

        # TODO: if remove_amount_data != 0 trim beginning and end of data

        if filter
            wave_info.unfiltered_waveform[:, i] = data.volts
        end

        if first_pass
            wave_info.info = data.info
        end
        wave_info.wave_form[:, i] = data.volts
        wave_info.coordinates[i] = pos_xyz(hydro.xyz)

        if verbose
            time_left = elapsed_time(loop_time) do elapsed_seconds
                # Multiply seconds this loop took by number of
                # remaining iterations to get approximate end time
                elapsed_seconds * (num_points - i)
            end
            @info "Estimated time remaining: $time_left"
        end
    end

    if verbose
        @info """
            Done!
            Scan completed from $(axis_range[begin]) to $(axis_range[end])
            Total elapsed time: $(elapsed_time(start_time))
            
        """
    end

    # TODO: Save data to file
    if verbose
        @info "Saving to file"
    end

    # TODO: Plot
    wave_info

end
