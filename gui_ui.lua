local default_line_height = 4
local default_text_right_spacing = 2

function assign(args)
	local newTable = {}
	for i, tab in ipairs(args) do
		for k,v in pairs(tab) do
			newTable[k] = v;
		end
	end
	return newTable
end

function window()

	local container = {
		border_color = 0,
		border_top = 0,
		border_bottom = 0,
		border_left = 0,
		border_right = 0,
		children = {},
		justify = "start",
		align = "start",
		direction = "row",
		width = 100,
		height = 100,
		background = 7,
		line_height = default_line_height,
		_left = 0,
		_top = 0,
		left = 0,
		top = 0,
		_index = 1,
		_parent = nil,
		-- add a table consisting of a function and table, if the function returns
		-- true assign the table to the container.
		states = {},
	}

	local construct_container = function()
		local new_container = {}
		for k,v in pairs(container) do
			new_container[k] = v
		end
		new_container.children = {}

		return new_container
	end

	local window = {
		elements = {construct_container(container)},
		breadth = {},
		depth = {},
		container = 1,
		debug = ""
	}

	draw = function(container)

		local styles = container

		for v in all(container.states) do
			if (v[1]()) then
				styles = assign({styles, v[2]})
			end
		end

		--[[ if (container.is_focused) then
			--printh("Focused")
			styles = assign({container, container.focus})
			-- styles = assign(container, container.focus)
		end ]]--

		if (styles.border_left > 0) then
			rectfill(
				styles._left,
				styles._top,
				styles._left + styles.border_left - 1,
				styles._top + styles.height,
				styles.border_color
			)
		end

		if (styles.border_right > 0) then
			rectfill(
				(styles._left + styles.width) - styles.border_right + 1,
				styles._top,
				styles._left + styles.width,
				styles._top + styles.height,
				styles.border_color
			)
		end

		if (styles.border_top > 0) then
			rectfill(
				styles._left,
				styles._top,
				styles._left + styles.width,
				styles._top + styles.border_top - 1,
				styles.border_color
			)
		end

		if (styles.border_bottom > 0) then
			rectfill(
				styles._left,
				styles._top + styles.height - styles.border_bottom + 1,
				styles._left + styles.width,
				styles._top + styles.height,
				styles.border_color
			)
		end

		if (styles.background != "transparent") then
			rectfill(
				styles._left + styles.border_left,
				styles._top + styles.border_top,
				styles._left + styles.width - styles.border_right,
				styles._top + styles.height - styles.border_bottom,
				styles.background
			)
		end

		if (styles.text) then

			local text_top = styles._top

			if (styles.line_height != default_line_height) then
				text_top += ceil((styles.line_height - default_line_height) / 2)
			end

			print(styles.text, styles._left, text_top, styles.color)
		end
	end

	-- little helper function, to check if a value exists in a table
	function contains(table, value)
		local contains = false

		foreach(table, function(element)
			if (element == value) then
				contains = true;
				return;
			end
		end)

		return contains

	end

	function construct_depth(container)
		local depth = {}
		local nodes = {}

		add(nodes, container._index)
		local index = 1

		while (#nodes > 0) do

			-- if we have no children add the current node to depth,
			-- and remove it from nodes
			local node_index = nodes[#nodes]

			-- printh("Node Count: " .. #nodes)
			-- printh("Node Index: " .. node_index)

			local child = window.elements[node_index]
			local can_add = false

			if (#child.children == 0) then
				can_add = true
			else
				can_add = true

				foreach(child.children, function(element)

					local in_depth = contains(depth, element)

					if (not in_depth) then
						can_add = false
						add(nodes, element)

						-- return early as we only want to add the first child.
						-- this can be improved as there's a lot of looping.
						return
					end
				end)
			end

			if (can_add) then
				add(depth,node_index)
				del(nodes, node_index)
			end

		end

		return depth
	end

	function construct_breadth(container)

		local breadth = {}
		local nodes = {}

		add(nodes, container._index)
		local index = 1

		-- window.debug = index .. ", " .. #nodes

		while (index <= #nodes) do
			local node_index = nodes[index]
			local child = window.elements[node_index]

			add(breadth, node_index)

			for i, v in pairs(child.children) do
				add(nodes, v)
			end

			index += 1

		end

		return breadth;

	end

	local calculate_size = function(container)

		if not container.height then
			if container.text then
				container.height = container.line_height
			end
		end

		if container.width == nil then
			if container.text then
				container.width = print(container.text, 0, 0) - default_text_right_spacing
			end
		end

		return container

	end

	-- Position Children
	-- Assumption - Every child will have a width and the parent will have a left / top position set
	local position_children = function(container)

		local cur_left = container._left or 0
		local cur_top = container._top or 0
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

		-- removes the added one for positioning without me having to think about it.
		cur_top -= 1
		cur_left -= 1

		-- there's probably a way to not do this second pass (future me problems)

		for i, v in ipairs(container.children) do
			local child = window.elements[v]
			local move_amount = container._left + container.width - flr(cur_left)

			if (container.direction == "column") then
				move_amount = container._top + container.height - flr(cur_top);
			end

			if (container.justify == "start") then
				move_amount = 0;
			end

			if (container.justify == "center") then
				move_amount = ceil(move_amount / 2)
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
					move_amount = ceil(move_amount / 2)
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

			-- this will need changing when we start doing stuff based on nil
			-- height / widths and children / parents
			foreach(window.breadth, function(index)
				local element = window.elements[index]
				calculate_size(element)
			end)

			foreach(window.breadth, function(index)
				local element = window.elements[index]
				position_children(element)
			end)
		end,
		get_window = function()
			return window.elements[window.container]
		end,
		draw = function()

			local root = window.elements[window.container]
			for k, v in ipairs(window.breadth) do
				local element = window.elements[v]
				draw(element)
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
				parent = window.elements[window.container]
			end

			child._parent = parent._index

			add(window.elements, child)
			add(parent.children, #window.elements)
			window.breadth = construct_breadth(container)
			window.depth = construct_depth(container)

		end,
	}

end

local gui = window()
gui.get_window().align = "center"
gui.get_window().justify = "center"

local menu = nil

function _init()

	menu = gui.new_container();

	menu.width = 50
	menu.height = 15
	menu.background = 8
	menu.align = "center"
	menu.justify = "center"
	menu.direction = "column"
	menu.border_color = 0
	menu.border_left = 1
	menu.border_right = 1
	menu.border_top = 1
	menu.border_bottom = 1
	menu.is_focused = false

	menu.states = {{
		function()
			return menu.is_focused
		end,
		{
			background = "transparent"
		}
	}}

	-- menu.justify = "start"

	gui.add_child(menu)

	local block = gui.new_container();

	block.width = 15;
	block.height = 15;
	block.background = 11;

	gui.add_child(block);

	local text_element = gui.new_container()

	text_element.width = nil
	text_element.height = nil
	text_element.background = "transparent"
	text_element.text = "Start Game"
	text_element.color = 0
	text_element.line_height = 9

	gui.add_child(text_element, menu)

	local subitem = gui.new_container()



	-- subitem.left = 0
	-- subitem.top = 0
	subitem.width = 5
	subitem.height = 5
	subitem.background = 10
	--subitem.align = "center"
	--subitem.justify = "center"

	local subitem2 = gui.new_container()

	subitem2.width = 5
	subitem2.height = 5
	subitem2.background = 8

	-- gui.add_child(subitem, menu)
	-- gui.add_child(subitem2, menu)

	--[[ local item = gui.new_container();

	item.width = 20
	item.height = 20
	item.background = 3

	gui.add_child(item) ]]--

	gui.inflate()
end

function _update()
	if (btnp(5)) then
		menu.is_focused = not menu.is_focused
	end
end

function _draw()
		cls()
		gui.draw()
end