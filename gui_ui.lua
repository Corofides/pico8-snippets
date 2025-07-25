function window()

	local container = {
		children = {},
		justify = "center",
		align = "start",
		width = 100,
		height = 100,
		background = 7,
		_left = 0,
		_top = 0,
		left = 0,
		top = 0,
		dirty = true
	}

	draw = function(container)
		rectfill(
			container.left,
			container.top,
			container.left + container.width,
			container.top + container.height,
			container.background
		)
	end

	-- Position Children
	-- Assumption - Every child will have a width and the parent will have a left / top position set
	-- Assumption 2 - We don't care about top to bottom.
	local position_children = function(container)

		local curLeft = container.left
		local curTop = container.top


		for i, v in ipairs(container.children) do

			if v.dirty then
				v.left = curLeft
				v.top = curTop
			end

			v.dirty = false
            curLeft += v.width

		end

		if container.justify == start then
			return
		end

		if not container.dirty then
			return
		end

		for i, v in ipairs(container.children) do

			local move_amount = container.width - curLeft

			if container.justify == "center" then
				move_amount = move_amount / 2
			end

			v.left = v.left + (move_amount)
		end

		container.dirty = false


	end

	return {
		inflate = function()
			position_children(container)
		end,
		draw = function()
			draw(container)

			for k,v in ipairs(container.children) do
				draw(v)
			end
		end,
		new_container = function()
			local new_container = {}
			for k,v in pairs(container) do
				new_container[k] = v
			end
			return new_container
		end,
		add_child = function(child)
			add(container.children, child)
		end,
		debug = function()
			print("Children: " .. container.children[2]._left, 20, 20, 0)
			print("Children: " .. container.children[2]._top, 20, 30, 0)
		end
	}

end

local gui = window()

function _init()
	local menu = gui.new_container();

	menu.width = 20
	menu.height = 20
	menu.background = 0

	gui.add_child(menu)

	local item = gui.new_container();

	item.width = 20
	item.height = 20
	item.background = 3

	gui.add_child(item)
end

function _update()
	gui.inflate()
end

function _draw()
		cls()
		gui.draw()
		gui.debug()
end