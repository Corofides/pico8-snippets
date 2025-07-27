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
		dirty = true,
		_index = 1,
		_parent = nil,
	}

	local window = {
		elements = {container},
		breadth = {},
		container = 1,
		debug = ""
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

	function construct_breadth(container)

		printh("")

		local breadth = {}
		local nodes = {}

		add(nodes, container._index)
		local index = 1

		-- window.debug = index .. ", " .. #nodes

		while (index <= #nodes) and (index <= 4) do
			local node_index = nodes[index]

			window.debug = window.debug .. index .. ", " .. node_index
			printh("Index: " .. index)
			printh("Node Index: " .. node_index)
			printh("Node Size: " .. #nodes)

			-- window.debug = node_index
			local child = window.elements[node_index]

			add(breadth, node_index)

			for i, v in pairs(child.children) do
				printh("Add Child " .. i)
				-- window.debug = window.debug .. i .. "," .. v .. " "
				add(nodes, v)
			end

			index += 1

		end

		--[[add(breadth, container._index)

		for v in all(container.children) do
			local child = window.elements[v]
			add(breadth, child._index)

			for v2 in all(child.children) do
				add(nodes, v2)
			end
		end]]--

		return breadth;

	end

	-- Position Children
	-- Assumption - Every child will have a width and the parent will have a left / top position set
	local position_children = function(container)

		local cur_left = container._left
		local cur_top = container._top
		local max_cross = 0

		for i, v in ipairs(container.children) do

			local child = window.elements[v]

			child._left = cur_left
			child._top = cur_top

			if container.direction == "column" then
				cur_top += child.height + 1

				if (child.width > max_cross) then
					max_cross = child.width
				end

			else
				cur_left += child.width + 1

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

			local root = window.elements[window.container]

			draw(root)

			for k,v in ipairs(root.children) do
				local child = window.elements[v]
				draw(child)
			end
		end,
		new_container = function()
			local new_container = {}
			for k,v in pairs(container) do
				new_container[k] = v
			end
			new_container.children = {}

			return new_container
		end,
		add_child = function(child, parent)
			child._index = #window.elements + 1

			if (not parent) then
				parent = container
			end

			child._index = parent._index

			add(window.elements, child)
			add(parent.children, #window.elements)
			window.breadth = construct_breadth(container)

			printh("Window Breadth")
			for i, v in ipairs(window.breadth) do
				printh(v)
			end

		end,
		debug = function()

			local child = window.elements[container.children[1]]

			print("Children: " .. child._index, 20, 20, 0)
			print("Children: " .. child._top, 20, 30, 0)
			print("Breadth: " .. window.debug, 20, 10, 0)
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

	local subitem = gui.new_container()

	subitem.width = 6
	subitem.height = 6
	subitem.background = 7

	gui.add_child(subitem, menu)

	local item = gui.new_container();

	item.width = 20
	item.height = 20
	item.background = 3

	gui.add_child(item)

	gui.inflate()
end

function _update()

end

function _draw()
		cls()
		--gui.inflate()
		gui.draw()
end