function window()

	local container = {
		children = {},
		justify = "center",
		align = "center",
		direction = "row",
		width = 100,
		height = 100,
		background = 7,
		_left = 0,
		_top = 0,
		left = 0,
		top = 0,
		dirty = true
	}

	local window = {
		elements = {}
	}

	draw = function(container)
		rectfill(
			container._left,
			container._top,
			container._left + container.width,
			container._top + container.height,
			container.background
		)
	end

	-- Position Children
	-- Assumption - Every child will have a width and the parent will have a left / top position set
	local position_children = function(container)

		local cur_left = container.left
		local cur_top = container.top
		local max_cross = 0

		for i, v in ipairs(container.children) do

			local child = window.elements[v]

			child._left = cur_left
			child._top = cur_top

			if container.direction == "column" then
				cur_top += child.height

				if (child.width > max_cross) then
					max_cross = child.width
				end

			else
				cur_left += child.width

				if (child.height > max_cross) then
					max_cross = child.height
				end

			end

		end

		-- there's probably a way to not do this second pass (future me problems)

		for i, v in ipairs(container.children) do
			local child = window.elements[v]
			local move_amount = container.width - cur_left

			if (container.direction == "column") then
				move_amount = container.height - cur_top;
			end

			if (container.justify == "start") then
				move_amount = 0;
			end

			if (container.justify == "center") then
				move_amount = move_amount / 2
			end

			if (container.direction == "column") then
				child._top = child._top + move_amount
			else
				child._left = child._left + move_amount
			end

			-- this is getting very if / elsey
			if (container.align != "start") then

				move_amount = container.width - max_cross

				if (container.direction == "row") then
					move_amount = container.height - max_cross
				end

				if (container.align == "center") then
					move_amount = move_amount / 2
				end

				if (container.direction == "column") then
					child._left = child._left + move_amount
				else
					child._top = child._top + move_amount
				end

			end

		end

	end

	return {
		inflate = function()
			position_children(container)
		end,
		draw = function()
			draw(container)

			for k,v in ipairs(container.children) do
				local child = window.elements[v]
				draw(child)
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
			add(window.elements, child)
			add(container.children, #window.elements)
		end,
		debug = function()

			local child = window.elements[container.children[2]]

			print("Children: " .. child._left, 20, 20, 0)
			print("Children: " .. child._top, 20, 30, 0)
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
		--gui.inflate()
		gui.draw()
		gui.debug()
end