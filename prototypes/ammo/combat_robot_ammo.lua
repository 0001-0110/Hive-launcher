local utils = require("utils.utils")
local capsule_ammo = require("capsule_ammo")

local combat_robot_ammo = {}

-- Create a custom combat robot that stays idle
-- Setting the `follows_player` to false is not enough, because that causes the robots to drift aimlessly
local function create_custom_combat_robot(name)
    local custom_combat_robot = table.deepcopy(data.raw["combat-robot"][name])
    custom_combat_robot.name = utils.prefix("custom-" .. name)
    custom_combat_robot.max_speed = 0
    return custom_combat_robot
end

local function create_action(name, entity_count, custom_combat_robot)
    return {
        type = "direct",
        action_delivery =
        {
            type = "instant",
            target_effects =
            {
                {
                    type = "create-entity",
                    show_in_tooltip = true,
                    entity_name = custom_combat_robot and custom_combat_robot.name or name,
                    -- TODO This can only work for up to five entities, find a more generic solution
                    -- The number of offsets will dictate the number of entities created
                    -- Each offset is a position relative to the impact point of the projectile
                    offsets = utils.take({ {0, 0}, {1, 1}, {1, -1}, {-1, 1}, {-1, -1}, }, entity_count)
                },
                -- Small particle effects when the projectile hits
                {
                    type = "create-entity",
                    entity_name = name .. "-robot-explosion",
                },
                {
                    type = "create-entity",
                    entity_name = "small-scorchmark-tintable",
                    check_buildability = true,
                },
            },
        },
    }
end

function combat_robot_ammo.create_all_prototypes(capsule, name, entity_count)
    capsule.prototypes = {}

    -- Combat robots shouldn't go back to the turret that shot them, so we create a custom combat robot that doesn't
    -- follow its owner
    if data.raw["combat-robot"][name].follows_player then
        capsule.custom_combat_robot = create_custom_combat_robot(name)
        table.insert(capsule.prototypes, capsule.custom_combat_robot)
    end

    local action = create_action(name, entity_count, capsule.custom_combat_robot)
    capsule_ammo.create_all_prototypes(capsule, name, action, data.raw["technology"][name])
end

return combat_robot_ammo
