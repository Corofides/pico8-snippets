local default_line_height = 4
local default_text_right_spacing = 2

function window()

	local container = {
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

		if (container.text) then

			local text_top = container._top

			if (container.line_height != default_line_height) then
				text_top += ceil((container.line_height - default_line_height) / 2)
			end

			print(container.text, container._left, text_top, container.color)
		end
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

			printh("Move Amount: " .. move_amount)

			if (container.justify == "start") then
				move_amount = 0;
			end

			if (container.justify == "center") then
				move_amount = ceil(move_amount / 2)
			end

			printh("Move Amount: " .. move_amount)

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

			--[[ draw(root)

			for k,v in ipairs(root.children) do
				local child = window.elements[v]
				draw(child)
			end ]]--
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
gui.get_window().align = "center"
gui.get_window().justify = "center"

function _init()
	local menu = gui.new_container();

	menu.width = 75
	menu.height = 21
	menu.background = 0
	menu.align = "center"
	menu.justify = "center"
	menu.direction = "column"

	-- menu.justify = "start"

	gui.add_child(menu)

	local text_element = gui.new_container()

	text_element.width = nil
	text_element.height = nil
	text_element.background = 7
	text_element.text = "Start Game"
	text_element.color = 0
	text_element.line_height = 14

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

end

function _draw()
		cls()
		gui.draw()
end