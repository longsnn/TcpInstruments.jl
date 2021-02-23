module LTS
export 
        initialize_lts,
        ThorlabsLTS150,
        move_x_abs,
        move_y_abs,
        move_z_abs,
        move_x_rel,
        move_y_rel,
        move_z_rel,
        pos_xyz,
        pos_x,
        pos_y,
        pos_z,
        home,
        home_x,
        home_y,
        home_z

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
- `pos_xyz(xyz)
- `pos_x(xyz)
- `pos_y(xyz)
- `pos_z(xyz)
- `home(xyz)`
- `home_x(xyz)`
- `home_y(xyz)`
- `home_z(xyz)`
"""
mutable struct ThorlabsLTS150
    lts
    x_low_limit::Int64
    y_low_limit::Int64
    z_low_limit::Int64
    x_high_limit::Int64
    y_high_limit::Int64
    z_high_limit::Int64
end

ThorlabsLTS150(lts) = ThorlabsLTS150(lts, -1, -1, -1, -1, -1, -1)

using PyCall
function __init__()
PyCall.python != "python" && return
scriptdir = @__DIR__
pushfirst!(PyVector(pyimport("sys")."path"), scriptdir)
pyimport("lts")
end

"""
    xyz = initialize_lts()

Connect to Thorlabs LTS

Returns:
   - ThorlabsLTS150: Device Handle 
"""
initialize_lts() = ThorlabsLTS150(py"LTS().init()")

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

function set_limits(xyz, low, high)
    lts = xyz.lts
    lts.x_low_limit, lts.y_low_limit, lts.z_low_limit = low
    lts.x_high_limit, lts.y_high_limit, lts.z_high_limit = high
end

function get_limits(xyz)
    lts = xyz.lts
    return (lts.x_low_limit, lts.y_low_limit, lts.z_low_limit),
           (lts.x_high_limit, lts.y_high_limit, lts.z_high_limit)
end

end
