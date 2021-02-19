
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

struct ThorlabsLTS150
    lts
    x_home
    y_home
    z_home
end

using PyCall
function __init__()
PyCall.python != "python" && return
py"""
from time import sleep
import pdb
import clr
import sys
sys.path.append(r"C:\Program Files\Thorlabs\Kinesis")
from System import String
from System import Decimal
from System.Collections import *
clr.AddReference("Thorlabs.MotionControl.Controls")
clr.AddReference("Thorlabs.MotionControl.DeviceManagerCLI")
clr.AddReference("Thorlabs.MotionControl.GenericMotorCLI")
clr.AddReference("Thorlabs.MotionControl.IntegratedStepperMotorsCLI")
import Thorlabs.MotionControl.Controls
from Thorlabs.MotionControl.DeviceManagerCLI import *
from Thorlabs.MotionControl.IntegratedStepperMotorsCLI import *


def ParseDec(d):
    return float(str(d))

class LTS:
    def __init__(self):
        self.x_stage = 0
        self.y_stage = 0
        self.z_stage = 0
        self.x_serial = 0
        self.y_serial = 0
        self.z_serial = 0
        self.timeout = 60000

    def init_stage(self, serial):
        d = LongTravelStage.CreateLongTravelStage(serial)
        sleep(1)
        d.Connect(serial)
        sleep(1)
        d.EnableDevice()
        sleep(1)
        d.LoadMotorConfiguration(serial)
        return d


    def init(self):
        DeviceManagerCLI.BuildDeviceList()
        d_list = DeviceManagerCLI.GetDeviceList(45)
        print(d_list)

        if len(d_list) == 0:
            print("No Thorlabs LTS Device connected!")

        self.x_serial, self.y_serial, self.z_serial = d_list
        print("X: ", self.x_serial)
        print("Y: ", self.y_serial)
        print("Z: ", self.z_serial)

        self.x_stage = self.init_stage(self.x_serial)
        self.y_stage = self.init_stage(self.y_serial)
        self.z_stage = self.init_stage(self.z_serial)

    def move_x(self, pos):
        self.x_stage.MoveTo(Decimal(pos), self.timeout)

    def move_y(self, pos):
        self.y_stage.MoveTo(Decimal(pos), self.timeout)

    def move_z(self, pos):
        self.z_stage.MoveTo(Decimal(pos), self.timeout)

    def home(self):
        self.x_stage.Home(self.timeout)
        self.y_stage.Home(self.timeout)
        self.z_stage.Home(self.timeout)

    def pos_x(self):
        return ParseDec(self.x_stage.Position)

    def pos_y(self):
        return ParseDec(self.y_stage.Position)

    def pos_z(self):
        return ParseDec(self.z_stage.Position)
"""

end


two(x) = py"one"(x) + py"one"(x)

"""
# Available Functions

- `initialize` 
- `goto_position(xyz, x, y, z)` 
- `move_position(xyz)`
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
    return ThorlabsLTS150(lts)
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
