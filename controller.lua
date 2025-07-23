-- Mainly for my sanity.
local _button = {
    left = 0,
    right = 1,
    up = 2,
    down = 3,
    action1 = 4,
    action2 = 5,
}

--[[
  Creates a fairly simple way of registering actions on inputs with some utility
  functions
]]--

function create_controller(player)

    local controller = {
        key = 0,
        on = {},
    }

    -- controller.on probably shouldn't be an array because this
    -- possibly will get intensive
    return {
        add = function(type, on)

            local button_read = {
                type = type,
                on = on,
                key = controller.key
            }

            add(controller.on, button_read)

            local oldKey = controller.key
            controller.key = controller.key + 1

            return oldKey;

        end,
        clear = function(type)
            if not type then
                controller.on = {}
                controller.key = 0
                return
            end

            local index = 1;
            while index <= #controller.on do
                local value = controller.on[index]

                if value.type == type then
                    deli(controller.on,index)
                else
                    index += 1
                end
            end

        end,
        remove = function(key)
            local index = 1;
            while index <= #controller.on do
                if controller.on[index].key == key then
                    deli(controller.on, index)
                    break;
                end
                index += 1
            end
        end,
        update = function()
            for i,v in ipairs(controller.on) do

                if (btn(v.type)) then
                    v.on()
                end
            end
        end,
        debug = function()
           print("Key: " .. controller.key, 20, 80, 7);
           print("Ons: " .. #controller.on, 20, 90, 7);
        end
    }

end