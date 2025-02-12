local DataAnonymizer = class('DataAnonymizer')

function DataAnonymizer:initialize()
    self.rules = {}
end

function DataAnonymizer:add_rule(rule_def)
    -- Rule format: {field_pattern, anonymization_func}
    table.insert(self.rules, rule_def)
end

function DataAnonymizer:process_data(data)
    local result = {}
    for k, v in pairs(data) do
        local anonymized = v
        for _, rule in ipairs(self.rules) do
            if string.match(k, rule.pattern) then
                anonymized = rule.func(v)
                break
            end
        end
        result[k] = anonymized
    end
    return result
end

-- Example user script
local example_script = [[
    -- Temperature monitoring script
    local function check_temperature()
        local temp = sensors.temperature:read()
        if temp > 30 then
            actuators.fan:set_speed(100)
            publish("alerts/temperature", {
                level = "warning",
                value = temp
            })
        end
    end
    
    -- Run check every 5 seconds
    while true do
        check_temperature()
        sleep(5000)
    end
]]
