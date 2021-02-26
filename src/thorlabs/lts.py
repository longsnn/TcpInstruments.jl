from time import sleep
import pdb
import clr
import sys
sys.path.append(r"C:\Program Files\Thorlabs\Kinesis")

from System import String
from System import Decimal
from System import Action
from System import UInt64
from System.Collections import *
clr.AddReference("Thorlabs.MotionControl.Controls")
clr.AddReference("Thorlabs.MotionControl.DeviceManagerCLI")
clr.AddReference("Thorlabs.MotionControl.GenericMotorCLI")
clr.AddReference("Thorlabs.MotionControl.IntegratedStepperMotorsCLI")
import Thorlabs.MotionControl.Controls
from Thorlabs.MotionControl.DeviceManagerCLI import *
from Thorlabs.MotionControl.IntegratedStepperMotorsCLI import *

def test():
    print("LTS Python Loaded")

def ParseDec(d):
    return float(str(d))

class Stage:
    def __init__(self):
        self.stage = 0
        self.serial = 0
        self.is_moving = False
        self.is_enabled = False
        self.low_limit = -1
        self.high_limit = -1

    def init(self, serial):
        d = LongTravelStage.CreateLongTravelStage(serial)
        sleep(1)
        d.Connect(serial)
        sleep(1)
        d.EnableDevice()
        sleep(1)
        self.is_enabled = True
        d.LoadMotorConfiguration(serial)

        self.stage = d
        self.serial = serial

    def move(self, pos):
        if self.high_limit < self.low_limit:
            raise Exception("Upper limit cannot be smaller than lower limit")
        if self.low_limit >= 0:
            if pos < self.low_limit:
                pos = self.low_limit

        if self.high_limit >= 0:
            if pos > self.high_limit:
                pos = self.high_limit

        self.force_move(pos * 1000)

    def force_move(self, pos):
        self.is_moving = True
        self.stage.MoveTo(Decimal(pos), self.isDone())

    def home(self):
        self.is_moving = True
        self.stage.Home(self.isDone())

    def isDone(self):
        def isDoneHelper(taskID):
            self.is_moving = False
        return Action[UInt64](isDoneHelper)

    def pos(self):
        return self.pos_mm() * 0.001

    def pos_mm(self):
        return ParseDec(self.stage.Position)
    
    def get_limits(self):
        return self.low_limit, self.high_limit

    def remove_limits(self):
        self.low_limit = -1
        self.high_limit = -1

    def set_low_limit(self, lim):
        self.low_limit = lim

    def set_high_limit(self, lim):
        self.high_limit = lim

    def set_limits(self, low, high):
        self.set_low_limit(low)
        self.set_high_limit(high)

class LTS:
    def __init__(self):
        self.x_stage = Stage()
        self.y_stage = Stage()
        self.z_stage = Stage()

    def init(self):
        DeviceManagerCLI.BuildDeviceList()
        d_list = DeviceManagerCLI.GetDeviceList(45)
        print(d_list)

        if len(d_list) == 0:
            print("No Thorlabs LTS Device connected!")
            return
        elif len(d_list) == 3:
            self.x_serial, self.y_serial, self.z_serial = d_list
            print("X: ", self.x_serial)
            print("Y: ", self.y_serial)
            print("Z: ", self.z_serial)

            self.x_stage.init(self.x_serial)
            self.y_stage.init(self.y_serial)
            self.z_stage.init(self.z_serial)
        else:
            raise Exception(str(len(d_list)) + " stages were detected: " + str(d_list))

        return self

    # TODO
    def init(self, serials):
        DeviceManagerCLI.BuildDeviceList()

        if len(serials) == 0:
            print("No Thorlabs LTS Device connected!")
            return
        elif len(serials) == 3:
            self.x_serial, self.y_serial, self.z_serial = serials
            print("X: ", self.x_serial)
            print("Y: ", self.y_serial)
            print("Z: ", self.z_serial)

            self.x_stage.init(self.x_serial)
            self.y_stage.init(self.y_serial)
            self.z_stage.init(self.z_serial)
        else:
            raise Exception(str(len(d_list)) + " stages were detected: " + str(d_list))

        return self

    def serial(self):
        return self.x_stage.serial, self.y_stage.serial, self.z_stage.serial

    def move_x(self, pos):
        self.x_stage.move(pos)
        self.wait()

    def move_y(self, pos):
        self.y_stage.move(pos)
        self.wait()

    def move_z(self, pos):
        self.z_stage.move(pos)
        self.wait()

    def move_xyz(self, x, y, z):
        self.x_stage.move(x)
        self.y_stage.move(y)
        self.z_stage.move(z)
        self.wait()

    def home_x(self):
        self.x_stage.home()
        self.wait()

    def home_y(self):
        self.y_stage.home()
        self.wait()

    def home_z(self):
        self.z_stage.home()
        self.wait()

    def home_xyz(self):
        self.x_stage.home()
        self.y_stage.home()
        self.z_stage.home()
        self.wait()

    def pos_x(self):
        return self.x_stage.pos()

    def pos_y(self):
        return self.y_stage.pos()

    def pos_z(self):
        return self.z_stage.pos()

    def set_limits(self, low, high):
        low_x, low_y, low_z = low
        high_x, high_y, high_z = high
        self.x_stage.set_limits(low_x, high_x)
        self.y_stage.set_limits(low_y, high_y)
        self.z_stage.set_limits(low_z, high_z)

    def get_limits(self):
        low_x, high_x = self.x_stage.get_limits()
        low_y, high_y = self.y_stage.get_limits()
        low_z, high_z = self.z_stage.get_limits()
        return (low_x, low_y, low_z), (high_x, high_y, high_z)

    def remove_limits(self):
        self.x_stage.remove_limits()
        self.y_stage.remove_limits()
        self.z_stage.remove_limits()

    def wait(self):
        while self.x_stage.is_moving or self.y_stage.is_moving or self.z_stage.is_moving:
            sleep(0.1)

