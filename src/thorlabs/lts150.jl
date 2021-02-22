
module LTS
export 
        initialize_lts,
        ThorlabsLTS150,
        goto_position,
        move_position,
        move_x_abs,
        move_y_abs,
        move_z_abs,
        move_x_rel,
        move_y_rel,
        move_z_rel,
        set_home,
        move_home

"""
# Available Functions

- `initialize` 
- `goto_position(xyz, x, y, z)` 
- `get_position(xyz)`
- `move_x_abs(xyz, x)`
- `move_y_abs(xyz, y)`
- `move_z_abs(xyz, z)`
- `move_x_rel(xyz, x)`
- `move_y_rel(xyz, y)`
- `move_z_rel(xyz, z)`
- `set_home(xyz, x, y, z)`
- `move_home(xyz)`
"""
mutable struct ThorlabsLTS150
    lts
    x_home
    y_home
    z_home
end

using PyCall
function __init__()
scriptdir = @__DIR__
pushfirst!(PyVector(pyimport("sys")."path"), scriptdir)
mytest = pyimport("py_test")
PyCall.python != "python" && return
scriptdir = @__DIR__
@info scriptdir
pushfirst!(PyVector(pyimport("sys")."path"), scriptdir)
mytest = pyimport("lts")
end


two(x) = py"one"(x) + py"one"(x)


"""
# Available Functions

- `initialize` 
- `goto_position(xyz, x, y, z)` 
- `get_position(xyz)`
- `move_x_abs(xyz, x)`
- `move_y_abs(xyz, y)`
- `move_z_abs(xyz, z)`
- `move_x_rel(xyz, x)`
- `move_y_rel(xyz, y)`
- `move_z_rel(xyz, z)`
- `set_home(xyz, x, y, z)`
- `move_home(xyz)`
"""
function initialize_lts()
    lts = py"LTS()"
    lts.init()
    return ThorlabsLTS150(lts, 0, 0 ,0)
end

function goto_position(xyz, x, y, z)
    xyz.lts.move_x(x)
    xyz.lts.move_y(y)
    xyz.lts.move_z(z)
end

function get_position(xyz)
    return xyz.lts.pos_x(), xyz.lts.pos_y(), xyz.lts.pos_z()
end

move_x_abs(xyz, x) = xyz.lts.move_x(x)

move_y_abs(xyz, y) = xyz.lts.move_y(y)

move_z_abs(xyz, z) = xyz.lts.move_z(z)

move_x_rel(xyz, x) = xyz.lts.move_x(x + xyz.lts.pos_x())

move_y_rel(xyz, y) = xyz.lts.move_y(y + xyz.lts.pos_y())

move_z_rel(xyz, z) = xyz.lts.move_z(z + xyz.lts.pos_z())

function set_home(xyz, x, y, z) 
    xyz.x_home = x
    xyz.y_home = y
    xyz.z_home = z
end

function move_home(xyz)
    xyz.lts.move_x(xyz.x_home)
    xyz.lts.move_y(xyz.y_home)
    xyz.lts.move_z(xyz.z_home)
end
end
