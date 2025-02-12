-- script_manager.lua
local ScriptManager = class('ScriptManager')

function ScriptManager:initialize(storage_path)
    self.storage_path = storage_path
    self.active_scripts = {}
    self.script_stats = {}
end

function ScriptManager:save_script(name, code)
    local file = io.open(self.storage_path .. "/" .. name .. ".lua", "w")
    if file then
        file:write(code)
        file:close()
        return true
    end
    return false
end

function ScriptManager:load_saved_scripts()
    for file in io.popen("ls " .. self.storage_path):lines() do
        if file:match("%.lua$") then
            local name = file:gsub("%.lua$", "")
            local f = io.open(self.storage_path .. "/" .. file, "r")
            if f then
                local code = f:read("*all")
                f:close()
                self:load_script(name, code)
            end
        end
    end
end

function ScriptManager:monitor_script(name)
    self.script_stats[name] = {
        start_time = os.time(),
        run_count = 0,
        errors = 0,
        last_run = nil
    }
end

function ScriptManager:update_stats(name, success)
    if self.script_stats[name] then
        self.script_stats[name].run_count = self.script_stats[name].run_count + 1
        self.script_stats[name].last_run = os.time()
        if not success then
            self.script_stats[name].errors = self.script_stats[name].errors + 1
        end
    end
end

