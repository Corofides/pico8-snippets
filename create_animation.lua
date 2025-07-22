--[[
Create Animation

Function takes a table of sprites, and a delay length, it will return a
function to return the sprite that should be displayed depending on its
internal frame state.

Assumed function is called once while animation is active.

]]--

function create_animation(sprites, delay)

    local total_sprites = #sprites
    local count = 0
    local current_frame = 1

    return function()

        if (count < delay) then
            count += 1
            return sprites[current_frame]
        end

        count = 0
        current_frame = (current_frame % total_sprites) + 1
        return sprites[current_frame];

    end

end