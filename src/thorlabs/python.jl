using Pkg
using PyCall

function load_python()
    ENV["PYTHON"] = get(TCP_CONFIG, "python", "")
    Pkg.build("PyCall")
    @info "Python Loaded Please Restart Julia"
    exit()
end

if PyCall.python == "python"
py"""
import clr
import sys


lib_path = r"C:\Program Files\Thorlabs\Kinesis"

sys.path.append(lib_path)

from System import String
from System import Decimal
from System.Collections import *

clr.AddReference("Thorlabs.MotionControl.Controls")
import Thorlabs.MotionControl.Controls

clr.AddReference("Thorlabs.MotionControl.DeviceManagerCLI")
from Thorlabs.MotionControl.DeviceManagerCLI import *

clr.AddReference("Thorlabs.MotionControl.GenericMotorCLI")
from Thorlabs.MotionControl.GenericMotorCLI import *

clr.AddReference("Thorlabs.MotionControl.IntegratedStepperMotorsCLI")
from Thorlabs.MotionControl.IntegratedStepperMotorsCLI import *

# print(Thorlabs.MotionControl.Controls.__doc__)

def initialize(self, serial):
    self.device = Thorlabs.MotionControl.IntegratedStepperMotorsCLI.LongTravelStage.CreateLongTravelStage(serial)
    device.Connect(serial)
    motor = device.GetMotorConfiguration(serial)
    print(motor)
    deviceInfo = device.GetDeviceInfo()
    print(deviceInfo.Name, '  ', deviceInfo.SerialNumber)
    return device

"""

initialize_lts(serial) = py"initialize"(serial)
device_list() = py"DeviceManagerCLI.BuildDeviceList()"
end
