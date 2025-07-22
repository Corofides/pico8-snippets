--[[

Function to draw a box of a given border colour and background colour

Returns function that when passed a width, height, padding, border and content (function)
will draw a bordered box of the correct dimensions with content displayed inside.

Needs further work.

It returns the next pixel from the right and bottom of the box drawn for convenience.

Todo: Clipping the content.

]]--


function draw_box(bg_col, border_col)

    return function(x, y, width, height, padding, border, content)

        local x1 = x + width + (border * 2) + (padding * 2);
        local y1 = x + height + (border * 2) + (padding * 2);

        rectfill(x, y, x1, y1, border_col);
        rectfill(x + border, y + border, x1 - border, y1 - border, bg_col);

        if (content) then
            content(x + border + padding, y + border + padding)
        end

        return {
            x = x1 + 1,
            y = y1 + 1,
        }

    end

end