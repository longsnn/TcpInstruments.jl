module LTS
import TcpInstruments.Configuration
export 
        initialize_lts,
        ThorlabsLTS150,
        move_x_abs,
        move_y_abs,
        move_z_abs,
        move_x_rel,
        move_y_rel,
        move_z_rel,
        move_xyz,
        pos_xyz,
        pos_x,
        pos_y,
        pos_z,
        home,
        home_x,
        home_y,
        home_z,
        set_limits,
        get_limits,
        get_limits_x,
        get_limits_y,
        get_limits_z,
        clear_limits

"""
# Available Functions

- `initialize_lts` 
- `move_xyz(xyz, x, y, z)` 
- `pos_xyz(xyz, x, y, z)` 
- `move_x_abs(xyz, x)`
- `move_y_abs(xyz, y)`
- `move_z_abs(xyz, z)`
- `move_x_rel(xyz, x)`
- `move_y_rel(xyz, y)`
- `move_z_rel(xyz, z)`
- `pos_xyz(xyz)`
- `pos_x(xyz)`
- `pos_y(xyz)`
- `pos_z(xyz)`
- `home(xyz)`
- `home_x(xyz)`
- `home_y(xyz)`
- `home_z(xyz)`
- `set_limits(xyz, low, high)`
- `get_limits(xyz)`
- `get_limits_x(xyz)`
- `get_limits_y(xyz)`
- `get_limits_z(xyz)`
- `clear_limits(xyz)`

# Example
```
lts = initialize(ThorlabsLTS150)

move_xyz(lts, 0.1, 0.1, 0.1)

# Move 0.05 meters forwards
move_x_rel(lts, 0.05)

# Get position of x stage (0.05 here)
pos_x(lts)

# Move 0.05 meters backwards
move_x_rel(lts, -0.05)

# Moves device to home position
home(lts)

# Returns x,y,z positions
pos_xyz(lts)

# First tuple contains lower limits, second contains upper limits
# (x_low_lim, y_low_lim, z_low_lim), (x_up_lim, y_up_lim, z_up_lim)
# Arrays can be used instead of tuples as well []
set_limits(lts, (0.01, 0.01, 0.01), (0.1, 0.1, 0.1))

# Will return a pair of tuples with limits you just set
get_limits(lts)

# Will return lower and upper limit for x stage
lower_x, upper_x = get_limits_x(lts)

# Will stay at 0.1 (upper limit)
move_x_abs(lts, 0.2)

# Beyond device limit but will stay at 0.1 (upper limit)
move_x_abs(lts, 5)

# Will move to 0.01 (lower limit)
move_x_abs(lts, 0)

# Clear limits
clear_limits(lts)

# Moving beyond your physical device with no limits will throw an error
# Don't do this
move_x_abs(lts, 5)
```

"""
mutable struct ThorlabsLTS150
    lts
end

lts_lib = nothing

const xyz_config = Configuration.Config(".xyz_stage.yml")

using PyCall


function __init__()
global lts_lib
@info xyz_config
Configuration.load_config(xyz_config)
PyCall.python != "python" && return
scriptdir = @__DIR__
pushfirst!(PyVector(pyimport("sys")."path"), scriptdir)
lts_lib = pyimport("lts")
end

function get_config()
    return Configuration.get_config(xyz_config)
end

function create_config(;dir=homedir())
    Configuration.create_config(xyz_config; dir=dir)
end

function edit_config()
    Configuration.edit_config(xyz_config)
end

function load_config()
    isempty(xyz_config.loaded_file) && return
    #create_aliases(xyz_config)
end

"""
    xyz = initialize_lts()

Connect to Thorlabs LTS

Returns:
   - ThorlabsLTS150: Device Handle 
"""
function initialize_lts() 
    @assert Sys.iswindows() "Windows is needed to connect to ThorlabsLTS150"
    @assert lts_lib != nothing "add python: python to top of config file then call load_python(). You must be on a windows computer to use this device"
    lts = lts_lib.LTS()

    stages = get(get_config(), "ThorlabsLTS150", "")
    @info stages
    return

    if isempty(stages)
        lts.init()
    else
        lts.init([stages["X"], stages["Y"], stages["Z"]])
    end
    ThorlabsLTS150(lts)
end

"""
    move_xyz(xyz, x, y, z)

Simulatenously moves x, y and z stage to desired location
"""
move_xyz(xyz, x, y, z) = xyz.lts.move_xyz(x, y, z)

"""
    pos_xyz(xyz)

Returns location of x, y and z stages in the form of a Pair: (x, y, z)
"""
pos_xyz(xyz) = xyz.lts.pos_x(), xyz.lts.pos_y(), xyz.lts.pos_z()

"""
    move_x(xyz, x)

Moves x stage to desired absolute location
"""
move_x_abs(xyz, x) = xyz.lts.move_x(x)

"""
    move_y(xyz, y)

Moves y stage to desired absolute location
"""
move_y_abs(xyz, y) = xyz.lts.move_y(y)

"""
    move_z(xyz, z)

Moves z stage to desired absolute location
"""
move_z_abs(xyz, z) = xyz.lts.move_z(z)

"""
    move_x(xyz, x)

Moves x stage forward or backwards.

A positive number will move it forwards along the x axis while
a negative number will move it backwards.
"""
move_x_rel(xyz, x) = xyz.lts.move_x(x + xyz.lts.pos_x())

"""
    move_y(xyz, y)

Moves y stage forward or backwards.

A positive number will move it forwards along the y axis while
a negative number will move it backwards.
"""
move_y_rel(xyz, y) = xyz.lts.move_y(y + xyz.lts.pos_y())

"""
    move_z(xyz, z)

Moves z stage forward or backwards.

A positive number will move it forwards along the z axis while
a negative number will move it backwards.
"""
move_z_rel(xyz, z) = xyz.lts.move_z(z + xyz.lts.pos_z())

"""
    home(xyz)

This will home the x, y and z stages at the same time
"""
home(xyz) = xyz.lts.home_xyz()

"""
    home_x(xyz)

This will home the x stage
"""
home_x(xyz) = xyz.lts.home_x() 

"""
    home_y(xyz)

This will home the y stage
"""
home_y(xyz) = xyz.lts.home_y() 

"""
    home_z(xyz)

This will home the z stage
"""
home_z(xyz) = xyz.lts.home_z() 

"""
    pos_x(xyz)

Returns the current position of x stage
"""
pos_x(xyz) = xyz.lts.pos_x()

"""
    pos_y(xyz)

Returns the current position of y stage
"""
pos_y(xyz) = xyz.lts.pos_y()

"""
    pos_z(xyz)

Returns the current position of z stage
"""
pos_z(xyz) = xyz.lts.pos_z()

"""
    set_limits(xyz, (x_low_lim, y_low_lim, z_low_lim), (x_high_lim, y_high_lim, z_high_lim))

# Arguments
- `low`: A Pair or an Array of three positions: (lts.x_low_limit, lts.y_low_limit, lts.z_low_limit)
- `high`: A Pair or an Array of three positions: (lts.x_high_limit, lts.y_high_limit, lts.z_high_limit)

"""
function set_limits(xyz, low, high)
    if length(low) != 3 || length(high) != 3
        error("Cannot set device to these limits\nUse `help>set_limits` to see example of proper inputs")
    end
    xyz.lts.set_limits(low, high)
end

"""
Returns

    (lts.x_low_limit, lts.y_low_limit, lts.z_low_limit),
       (lts.x_high_limit, lts.y_high_limit, lts.z_high_limit)
"""
function get_limits(xyz)
    return xyz.lts.get_limits()
end

"""
Returns

    (x_low_limit, x_high_limit)
"""
function get_limits_x(xyz)
    low, high = xyz.lts.get_limits()
    return low[1], high[1]
end

"""
Returns

    (y_low_limit, y_high_limit)
"""
function get_limits_y(xyz)
    low, high = xyz.lts.get_limits()
    return low[2], high[2]
end

"""
Returns

    (z_low_limit, z_high_limit)
"""
function get_limits_z(xyz)
    low, high = xyz.lts.get_limits()
    return low[3], high[3]
end

function clear_limits(xyz)
    xyz.lts.remove_limits()
end

end
