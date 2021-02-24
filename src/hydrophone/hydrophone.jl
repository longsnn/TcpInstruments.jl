using Dates

function elapsed_time(start_time)
            seconds = floor(time() - start_time)
            return Time(0) + Second(seconds)
end
"""
Pretty awesome if I do say so myself
"""
function elapsed_time(func=x -> x, start_time=time())
            seconds = floor(time() - start_time)
            return Time(0) + Second(func(seconds))
end
"""
 settings = ky_hydro_init(scope_addr, sample_size, axis, ch_read, stage, settings)

 This function initializes connections with the xyz stage and the
 Oscilloscope. The program does this by calling ky_xyz_init and
 ky_scope_rs_init. This function takes 6 input arguements and 4 of those
 are mandatory. If there is no previous structure settings from previous
 initializations (if this is the first time the user calls this function),
 leave settings blank. Also, the default stage will be 'new' if not
 entered. This stage is the newer stage located in the larger lab room.
    Delete:
          axis: Decides whether the x,y, z or all 3 directions need to be
                activated.
         stage: Decides which stage to connect to. The two stages are 
                'new' and 'old'. If this spot is left blank, the function 
                assumes that the user desires to use the 'new' stage. The 
                new stage is located in the larger room.
      settings: The structure for all xyz stage controller connections.
    scope_addr: The IP address of the scope.

 Input:
           xyz: The handle of desired xyz stage
         scope: Handle of desired scope
       ch_read: This input decides which channel the scope will read from.
   sample_size: The amount of samples desired to be taken.


Ex.
```
lts = initialize_lts()
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
    waveinfo
    coordinates
    unfiltered_waveform
end

Waveinfo() = Waveinfo(nothing, nothing, nothing)


"""
 wave_info_x = ky_hydro_scan_x(settings, x_range, x_num, called)

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
        x_range: A 1x2 or 1x1 array that contains the start and end point
                 of the desired range in the x-direction.
          x_num: The number of points the user desires to record along the
                 x-axis.
         called: This variable is either one or zero and is used to turn
                 off user notifications when another function calls this
                 one. User usually won't have to use this variable.

 Output:
   wave_info_x: A structure that contains the data that traces x_num of
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
    hydro, x_range, x_num;
    verbose=true, filter=false,
)
    num_axis = 3 # Represents the three axis xyz
    wave_info = Waveinfo() 
    start_time = time()

    # Ensure x_range is within xyz limits
    x_low, x_high = hydro.xyz.get_limits_x()
    if !x_range[1] in x_low:x_high || !x_range[2] in x_low:x_high
        error("Scan range is outside current limits of the xyz stage")
    end

    # Set X Positions Vector
    x_pos = if length(x_range) == 1
        if x_num != 1
            error(
                "Can't measure multiple points when x_range has one"* 
                "position"
            )
        end
        x_range
    elseif length(x_range) == 2
        range(x_range[begin], stop=x_range[end], length=x_num)
    else
        error("x_range must have 1 or 2 elements")
    end

    # Pre-Allocate output matrices
    wave_info.wave_form = zeros(hydro.sample_size, x_num)
    wave_info.coordinates = zeros(num_axis, x_num) 

    # Loop to scan positions
    for i in 1:x_num
        if verbose 
            loop_time = time()
            @info "Scanning x-direction: $i/$x_num iterations"
        end

        move_x_abs(hydro.xyz, x_pos[i])

        # TODO: Something is pausing
        
        data = get_data(hydro.scope, hydro.channel)

        if hydro.sample_size != data.info.num_points
            error("Scope sample size is different from hydrophone")
        end

        # TODO: if remove_amount_data != 0 trim beginning and end of data

        # TODO: Implement
        if filter
            if i == 1 # Only on first pass
                wave_info.unfiltered_waveform = zeros(
                    hydro.sample_size, x_num
                )
            end
            # TODO: What format to save Waveform_info type
            wave_info.unfiltered_waveform[:, i] = data
        end

        # TODO: Save as point instead of column or destructure data?
        wave_info.wave_form[:, i] = data
        wave_info.coordinates[:, i] = pos_xyz(hydro.xyz)

        if verbose
            time_left = elapsed_time(loop_time) do seconds
                # Multiply seconds this loop took by number of remaining
                # iterations to get approximate end time
                seconds * (x_num - i)
            end
            @info "Estimated time remaining: $time_left"
        end
    end

    if verbose
            time_passed = elapsed_time(start_time)
    end
    wave_info
end

# TODO: ky_scope_rs_ch_data
