local IAMAgent = class('IAMAgent')

function IAMAgent:initialize(config)
    self.device_id = config.device_id
    self.policies = {}
    self.roles = {}
    self.cached_permissions = {}
end

function IAMAgent:load_policy(policy_def)
    -- Policy format: {resource, action, effect}
    self.policies[policy_def.name] = policy_def
end

function IAMAgent:check_permission(token, resource, action)
    if not self.cached_permissions[token] then
        return false
    end
    
    local role = self.cached_permissions[token].role
    for _, policy in pairs(self.policies) do
        if policy.role == role and 
           policy.resource == resource and 
           policy.action == action then
            return policy.effect == "allow"
        end
    end
    return false
end
