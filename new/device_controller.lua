local class = require 'middleclass'
local mqtt = require 'mqtt'
local json = require 'dkjson'

-- Core Device Controller
DeviceController = class('DeviceController')

function DeviceController:initialize(config)
    self.sensors = {}
    self.actuators = {}
    self.scripts = {}
    self.security = require('security').new()
    self.mqtt_client = mqtt.client.create(
        config.broker_url,
        config.broker_port,
        function() self:on_connect() end
    )
end

function DeviceController:load_script(script_name, script_code)
    -- Sandbox environment for user scripts
    local env = {
        sensors = self.sensors,
        actuators = self.actuators,
        publish = function(topic, message) 
            self:publish_message(topic, message) 
        end,
        log = function(msg) self:log_event(msg) end
    }
    
    -- Create sandbox
    local sandbox = setmetatable(env, {__index = _G})
    local script_func, err = load(script_code, script_name, 't', sandbox)
    
    if script_func then
        self.scripts[script_name] = {
            func = script_func,
            env = env
        }
        return true
    else
        return false, err
    end
end

function DeviceController:execute_script(script_name, params)
    if self.scripts[script_name] then
        local success, result = pcall(function()
            return self.scripts[script_name].func(params)
        end)
        return success, result
    end
    return false, "Script not found"
end
