--[[
  Copyright 2017 Stefano Mazzucco

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
]]

--[[--
  Get information about your power devices using
  [UPower](https://upower.freedesktop.org/) and DBus.

  Requiring this module will return the UPower Manager singleton.

  Example:

      GLib = require("lgi").GLib
      ctx = GLib.MainLoop():get_context()
      upower = require("upower_dbus")
      -- What version of UPower is in use?
      upower.Manager.DaemonVersion
      -- Are we using a battery?
      upower.Manager.OnBattery
      -- Enumerate the Device Types known by UPower
      for _, v in ipairs(upower.enums.DeviceType) do print(v) end
      -- Say that the first device is a battery
      battery = upower.Manager.devices[1]
      print(battery.Percentage) -- may print 100.0
      -- Update the devices in case something changed
      ctx:iteration()
      -- The battery discharged a bit
      battery.Percentage -- may print 99.0

  @module upower_dbus

  @license Apache License, version 2.0
  @author Stefano Mazzucco <stefano AT curso DOT re>
  @copyright 2017 Stefano Mazzucco
]]

local proxy = require("dbus_proxy")
local enum = require("enum")

local upower = {}

--- UPower Enumerations.
-- The `upower.enums` table contains the below [Lua
-- Enumerations](https://luarocks.org/modules/stefano-m/enum).
-- @within Enumerations
upower.enums = {}

--- The type of power source
-- @within Enumerations
-- @table DeviceType
local DeviceType = {
    "Unknown",
    "Line Power",
    "Battery",
    "Ups",
    "Monitor",
    "Mouse",
    "Keyboard",
    "Pda",
    "Phone"
}
upower.enums.DeviceType = enum.new("DeviceType", DeviceType)

--- The state of the battery.
-- This property is only valid if the device is a battery.
-- @within Enumerations
-- @table BatteryState
-- @see DeviceType
local BatteryState =   {
  "Unknown",
  "Charging",
  "Discharging",
  "Empty",
  "Fully charged",
  "Pending charge",
  "Pending discharge"
}
upower.enums.BatteryState = enum.new("BatteryState", BatteryState)

--- The technology used by the battery.
-- This property is only valid if the device is a battery.
-- @within Enumerations
-- @table BatteryTechnology
-- @see DeviceType
local BatteryTechnology = {
  "Unknown",
  "Lithium ion",
  "Lithium polymer",
  "Lithium iron phosphate",
  "Lead acid",
  "Nickel cadmium",
  "Nickel metal hydride"
}
upower.enums.BatteryTechnology = enum.new("BatteryTechnology", BatteryTechnology)

--- The warning level of the battery.
-- This property is only valid if the device is a battery.
-- @within Enumerations
-- @table BatteryWarningLevel
-- @see DeviceType
local BatteryWarningLevel =  {
    "Unknown",
    "None",
    "Discharging", -- (only for UPSes)
    "Low",
    "Critical",
    "Action"
  }
upower.enums.BatteryWarningLevel = enum.new("BatteryWarningLevel", BatteryWarningLevel)

local function update_mapping(obj, name, mapping)
  local value = obj[name]
  obj[name:lower()] = mapping[value + 1]
end


--- Update the device mappings.
-- Unless you are sure that the properties of the Device
-- have changed, you may want to use `update_properties`
-- or `refresh` instead.
-- @see upower.Device:update_properties
-- @see upower.Device:refresh
local function update_mappings(device)
  update_mapping(
    device,
    "Type",
    upower.enums.DeviceType)
  update_mapping(
    device,
    "State",
    upower.enums.BatteryState)
  update_mapping(
    device,
    "Technology",
    upower.enums.BatteryTechnology)
  update_mapping(
    device,
    "WarningLevel",
    upower.enums.BatteryWarningLevel)
end


--[[-- Create a new [UPower
  Device](https://upower.freedesktop.org/docs/Device.html).

  Rather than creating devices manually, you should use the

  @param path The DBus object path for the device.
  @within Device
]]
function upower.create_device(path)
  local device =  proxy.Proxy:new(
    {
      bus = proxy.Bus.SYSTEM,
      name = "org.freedesktop.UPower",
      interface = "org.freedesktop.UPower.Device",
      path = path
    }
  )
  device.update_mappings = update_mappings
  device:update_mappings()
  return device
end

--- The UPower Manager that proxies the [UPower DBus
-- interface](https://upower.freedesktop.org/docs/UPower.html).
-- Additionally the `devices` field contains the available Device objects.
-- @see upower.create_device
-- @within Manager
upower.Manager = proxy.Proxy:new(
  {
    bus = proxy.Bus.SYSTEM,
    name = "org.freedesktop.UPower",
    path = "/org/freedesktop/UPower",
    interface = "org.freedesktop.UPower"
  }
)


--- Initialize the Manager singleton
local function init(mgr)
  local devices = mgr:EnumerateDevices()
  for i, path in ipairs(devices) do
    devices[i] = upower.create_device(path)
  end
  mgr.devices = devices
end

init(upower.Manager)

return upower
