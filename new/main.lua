local config = {
    broker_url = "mqtt.example.com",
    broker_port = 1883,
    device_id = "device001"
}

local controller = DeviceController:new(config)
local iam = IAMAgent:new(config)
local anonymizer = DataAnonymizer:new()

-- Configure IAM policies
iam:load_policy({
    name = "temp_read",
    role = "operator",
    resource = "temperature",
    action = "read",
    effect = "allow"
})

-- Configure anonymization rules
anonymizer:add_rule({
    pattern = "ip_address",
    func = function(ip)
        return string.gsub(ip, "%d+%.%d+$", "0.0")
    end
})

-- Load user script
controller:load_script("temp_monitor", example_script)

-- Start MQTT loop
controller.mqtt_client:start()

-- Example usage
local device_data = {
    temperature = 25,
    ip_address = "192.168.1.100",
    location = "server_room"
}

-- Anonymize data before sending
local safe_data = anonymizer:process_data(device_data)

-- Publish data if authorized
if iam:check_permission("user_token", "temperature", "read") then
    controller:publish_message("sensors/temperature", safe_data)
end
