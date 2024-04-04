@tool
extends PanelContainer
#class_name Terrain3DAssetDock


## TODO
# Clean up, Move things back to ready?
# grab focus too aggressive if not pinned and window in front, alt+tab
# pin and slider reverse position from bottom
# right-click edit material, then click terrain3d and it triggers double click (edit or focus)


# Replace these with function calls
signal resource_changed(resource: Resource, index: int)
signal resource_inspected(resource: Resource)
signal resource_selected

const PS_DOCK_SLOT: String = "terrain3d/config/dock_slot"
const PS_DOCK_TILE_SIZE: String = "terrain3d/config/dock_tile_size"
const PS_DOCK_FLOATING: String = "terrain3d/config/dock_floating"
const PS_DOCK_PINNED: String = "terrain3d/config/dock_always_on_top"
const PS_DOCK_WINDOW_POSITION: String = "terrain3d/config/dock_window_position"
const PS_DOCK_WINDOW_SIZE: String = "terrain3d/config/dock_window_size"

var list: ListContainer
var entries: Array[ListEntry]
var selected_index: int = 0
var focus_style: StyleBox

var placement_opt: OptionButton
var floating_btn: Button
var pinned_btn: Button
var size_slider: HSlider
var box: BoxContainer
var buttons: BoxContainer
var textures_btn: Button
var meshes_btn: Button
var asset_container: ScrollContainer

#@onready var placement_opt: OptionButton = $Box/Buttons/PlacementOpt
#@onready var pinned: Button = $Box/Pinned
#@onready var size_slider: HSlider = $Box/Buttons/SizeSlider
#@onready var box: BoxContainer = $Box
#@onready var buttons: BoxContainer = $Box/Buttons
#@onready var textures_btn: Button = $Box/Buttons/TexturesBtn
#@onready var meshes_btn: Button = $Box/Buttons/MeshesBtn
#@onready var asset_container: ScrollContainer = $Box/ScrollContainer

# Used only for editor, so change to single visible/hiddden
enum {
	HIDDEN = -1,
	SIDEBAR = 0,
	BOTTOM = 1,
	WINDOWED = 2,
}
var state: int = HIDDEN
var window: Window
var plugin: EditorPlugin

enum {
	POS_LEFT_UL = 0,
	POS_LEFT_BL = 1,
	POS_LEFT_UR = 2,
	POS_LEFT_BR = 3,
	POS_RIGHT_UL = 4,
	POS_RIGHT_BL = 5,
	POS_RIGHT_UR = 6,
	POS_RIGHT_BR = 7,
	POS_BOTTOM = 8,
	POS_MAX = 9,
}
var slot: int = POS_BOTTOM
var _initialized: bool = false
var _godot_editor_window: Window # The main Godot Editor window


func _ready() -> void:
	print(self, "_ready")
	if not _initialized:
		return
	
	# Setup styles
	set("theme_override_styles/panel", get_theme_stylebox("panel", "Panel"))
	focus_style = get_theme_stylebox("focus", "Button").duplicate()
	focus_style.set_border_width_all(2)
	focus_style.set_border_color(Color(1, 1, 1, .67))
	# Avoid saving icon resources in tscn when editing w/ a tool script
	if plugin.get_editor_interface().get_edited_scene_root() != self:
		pinned_btn.icon = get_theme_icon("Pin", "EditorIcons")
		pinned_btn.text = ""
		floating_btn.icon = get_theme_icon("MakeFloating", "EditorIcons")
		floating_btn.text = ""


	
func initialize(p_plugin: EditorPlugin) -> void:
	if p_plugin:
		plugin = p_plugin
	print(self, "initialize, Plugin: ", plugin!=null, ", Parent: ", get_parent(), ", state: ", state)

	# Get editor window. Structure is root:Window/EditorNode/Base Control
	_godot_editor_window = plugin.get_editor_interface().get_base_control().get_parent().get_parent()

	placement_opt = $Box/Buttons/PlacementOpt
	pinned_btn = $Box/Buttons/Pinned
	floating_btn = $Box/Buttons/Floating
	size_slider = $Box/Buttons/SizeSlider
	box = $Box
	buttons = $Box/Buttons
	textures_btn = $Box/Buttons/TexturesBtn
	meshes_btn = $Box/Buttons/MeshesBtn
	asset_container = $Box/ScrollContainer

	list = ListContainer.new()
	asset_container.add_child(list)

	load_project_settings()

	# Connect signals
	resized.connect(update_layout)
	textures_btn.pressed.connect(_on_textures_pressed)
	meshes_btn.pressed.connect(_on_meshes_pressed)
	placement_opt.item_selected.connect(set_slot)
	floating_btn.pressed.connect(make_dock_float)
	pinned_btn.toggled.connect(_on_pin_changed)
	pinned_btn.visible = false
	size_slider.value_changed.connect(_on_slider_changed)	
	resource_changed.connect(_on_resource_changed)
	resource_inspected.connect(_on_resource_inspected)
	resource_selected.connect(_on_resource_selected)

	print("Ready 4 Parent: ", get_parent(), ", state: ", state, ", slot: ", slot)
	_initialized = true
	print("initizalized, showing dock: ", plugin.visible)
	update_assets()
	update_dock(plugin.visible)
	update_layout()
	print("Ready 5 Parent: ", get_parent(), ", state: ", state)




## Window Management

func dump_window() -> void:
	return
	if window:
		window.print_tree()
		push_warning("Dumping window")
		for prop in window.get_property_list():
			print(prop.name, " = ", window.get(prop.name))
		push_warning("Dumping MarginContainer")
		var mc: MarginContainer = get_parent()
		for prop in mc.get_property_list():
			print(prop.name, " = ", mc.get(prop.name))
		push_warning("Dumping Self")
		for prop in get_property_list():
			print(prop.name, " = ", get(prop.name))
		push_warning("Dumping Box")
		for prop in $Box.get_property_list():
			print(prop.name, " = ", $Box.get(prop.name))
		print("-----done-------")
		
func make_dock_float() -> void:
	print(self, "make_dock_float, prev_slot: ", slot, ", current state: ", state)
	#dump_project_settings()
	# If already created (eg editor Make Floating)	
	if window:
		push_warning("Capturing Window already created from Editor/make_floating, slot: ", slot, ", state: ", state)
		print("Parent is: ", get_parent().name, ", gp: ", get_parent().get_parent().name)
	else:
		remove_dock()
		create_window()

	state = WINDOWED
	pinned_btn.visible = true
	floating_btn.visible = false
	placement_opt.visible = false
	window.title = "Terrain3D Asset Dock"
	window.always_on_top = pinned_btn.button_pressed
	window.close_requested.connect(remove_dock.bind(true))
	visible = true # Is hidden when pops off of bottom. ??

	print(self, "make_dock_float done, slot: ", slot, ", state: ", state)
	#dump_project_settings()
	#dump_window()
	#save_project_settings()


func create_window() -> void:
	print(self, "create_window")
	window = Window.new()
	window.wrap_controls = true
	var mc := MarginContainer.new()
	mc.set_anchors_preset(PRESET_FULL_RECT, false)
	mc.add_child(self)
	window.add_child(mc)
	window.set_transient(false)
	window.set_size(ProjectSettings.get_setting(PS_DOCK_WINDOW_SIZE, Vector2i(512, 512)))
	window.set_position(ProjectSettings.get_setting(PS_DOCK_WINDOW_POSITION, Vector2i(704, 284)))
	plugin.add_child(window)
	window.show()
	window.window_input.connect(_on_window_input)
	window.mouse_entered.connect(_on_window_mouse_entered)
	#window.mouse_exited.connect(_on_window_mouse_exited)
	_godot_editor_window.mouse_entered.connect(_on_godot_window_entered)


func _on_window_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_S and event.pressed and event.is_command_or_control_pressed():
		print("CTRL+S Pressed, saving scene")
		save_project_settings()
		plugin.get_editor_interface().save_scene()


func _on_window_mouse_entered() -> void:
	#print("Mouse entered asset dock")
	window.grab_focus()


func _on_godot_window_entered() -> void:
	#print("Mouse entered godot")
	_godot_editor_window.grab_focus()


#func _on_window_mouse_exited() -> void:
	#print("Mouse exited asset dock")
	#_godot_editor_window.grab_focus()
	#pass

## Dock placement

func set_slot(p_slot: int) -> void:
	print("set_slot call: ", p_slot)
	p_slot = clamp(p_slot, 0, POS_MAX-1)
	
	if slot != p_slot:
		print("set_slot changing slot: ", p_slot)
		slot = p_slot
		placement_opt.selected = slot
		save_project_settings()

		plugin.select_terrain()

		print("Setting slot: ", slot, ", showing dock: ", plugin.visible)
		update_dock(plugin.visible)


func remove_dock(p_force: bool = false) -> void:
	print(self, "remove_dock, force: ", p_force)
	if state == SIDEBAR:
		print(self, "Remove dock from sidebar")
		plugin.remove_control_from_docks(self)
		state = HIDDEN

	elif state == BOTTOM:
		print(self, "Remove dock from bottom panel")
		plugin.remove_control_from_bottom_panel(self)
		state = HIDDEN

	# If windowed and destination is not window or final exit, otherwise leave
	elif state == WINDOWED and p_force: #( slot != POS_WINDOW or p_force ):
		print("Removing window")
		if not window:
			push_error("State is windowed, but no window to remove. Shouldn't happen. Returning")
			return
		var parent: Node = get_parent()
		if parent:
			parent.remove_child(self)
			_godot_editor_window.mouse_entered.disconnect(_on_godot_window_entered)
			window.hide() # Maybe even if not parent?
			window.queue_free()
			window = null
		floating_btn.button_pressed = false
		floating_btn.visible = true
		pinned_btn.visible = false
		placement_opt.visible = true
		state = HIDDEN
		update_dock(plugin.visible) # return window to side/bottom

	# Hide pin
	# Show make floating
	# show slot changer
	print(self, "remove dock end, state: ", state, ", slot: ", slot, ", visible: ", plugin.visible)
	#dump_project_settings()
	

func update_dock(p_visible: bool) -> void:
	print(self, "Show dock: ", p_visible, ", initialized: ", _initialized)
	if not _initialized:
		print(self, "Show dock: not initiazlied, returning")
		return

	if window:
		print("already window, returning")
		return
	elif floating_btn.button_pressed:
		# No window, but floating button pressed happens if loading while open. Create window
		push_warning("Loading window that was saved open - should happen only once at startup")
		make_dock_float()
		return

	remove_dock()
	# Add dock to new destination
	# Sidebar
	if slot < POS_BOTTOM: # and not pinned.button_pressed:
		#print(self, "Adding dock to side slot: ", slot, ", old state: ", state)
		state = SIDEBAR
		plugin.add_control_to_dock(slot, self)
		#print(self, "state: ", state)
	elif slot == POS_BOTTOM: # and not pinned.button_pressed:
		#print(self, "Adding dock to bottom: ", slot, ", old state: ", state)
		state = BOTTOM
		plugin.add_control_to_bottom_panel(self, "Terrain3D")
		#print(self, "Making bottom visible")
		if p_visible:
			plugin.make_bottom_panel_item_visible(self)
		#print(self, "state: ", state)
		
	#update_layout()



func update_layout() -> void:
	#print(self, "Updating layout. Slot: %d, State: %d, plugin: %s" % [ slot, state, plugin ])
	if not _initialized:
		return
	print("update_layout: State: %d, slot: %d, parent: %s" % [ state, slot, get_parent().name ])

	
	# Take care here to detect if we have a new window (from Make floating)
	# and convert to our window so it can be freed properly
	# If not set to windowed and suddenly is, user hit `Make Floating`, grab it
	if not window and get_parent() and get_parent().get_parent() is Window:
		push_warning("Editor/Make Floating - should happen only once")
		window = get_parent().get_parent()
		make_dock_float()
		return # Will return here upon display


	var size_parent: Control = size_slider.get_parent()
	# Vertical layout
	if window or slot < POS_BOTTOM:
		box.vertical = true
		buttons.vertical = false

		if size.x >= 500 and size_parent != buttons:
			size_slider.reparent(buttons)
			buttons.move_child(size_slider, 3)
		elif size.x < 500 and size_parent != box:
			size_slider.reparent(box)
			box.move_child(size_slider, 1)
		floating_btn.reparent(buttons)
		buttons.move_child(floating_btn, 4)

	# Wide layout
	else:
		size_slider.reparent(buttons)
		floating_btn.reparent(box)
		box.vertical = false
		buttons.vertical = true

	save_project_settings()


## Manage Project Settings

func dump_project_settings() -> void:
	print("PS floating button: ", ProjectSettings.get_setting(PS_DOCK_FLOATING, ""))
	print("PS pinned button: ", ProjectSettings.get_setting(PS_DOCK_PINNED, ""))
	print("PS tile size: ", ProjectSettings.get_setting(PS_DOCK_TILE_SIZE, ""))
	print("PS slot: ", ProjectSettings.get_setting(PS_DOCK_SLOT, ""))
	print("PS window pos: ", ProjectSettings.get_setting(PS_DOCK_WINDOW_POSITION, ""))
	print("PS window size: ", ProjectSettings.get_setting(PS_DOCK_WINDOW_SIZE, ""))

	
func load_project_settings() -> void:
	print("Loading project settings")
	print("---- pre")
	dump_project_settings()
	floating_btn.button_pressed = ProjectSettings.get_setting(PS_DOCK_FLOATING, false)
	pinned_btn.button_pressed = ProjectSettings.get_setting(PS_DOCK_PINNED, true)
	size_slider.value = ProjectSettings.get_setting(PS_DOCK_TILE_SIZE, 83)
	set_slot(ProjectSettings.get_setting(PS_DOCK_SLOT, POS_BOTTOM))
	_on_slider_changed(size_slider.value)
	# Window pos/size set on window creation in update_dock
	print("---- post")
	dump_project_settings()

	update_dock(plugin.visible)
	
	
func save_project_settings() -> void:
	if not _initialized:
		return
	#print("Saving project settings, previous:")
	#dump_project_settings()
	ProjectSettings.set_setting(PS_DOCK_SLOT, slot)
	ProjectSettings.set_setting(PS_DOCK_TILE_SIZE, size_slider.value)
	ProjectSettings.set_setting(PS_DOCK_FLOATING, floating_btn.button_pressed)
	ProjectSettings.set_setting(PS_DOCK_PINNED, pinned_btn.button_pressed)
	if window:
		ProjectSettings.set_setting(PS_DOCK_WINDOW_SIZE, window.size)
		ProjectSettings.set_setting(PS_DOCK_WINDOW_POSITION, window.position)

	ProjectSettings.save()
	print("Saved project settings:")
	dump_project_settings()


## Panel Button handlers

func _on_pin_changed(toggled: bool) -> void:
	print("Pin toggled: ", toggled)
	if window:
		window.always_on_top = pinned_btn.button_pressed
	save_project_settings()


func _on_slider_changed(value: float) -> void:
	print("Slider changed: ", value)
	if list:
		list.set_entry_width(value)
	save_project_settings()


func _on_textures_pressed() -> void:
	print("Textures pressed")
	pass


func _on_meshes_pressed() -> void:
	print("Meshes pressed")
	pass


## Tile handlers

func _on_resource_changed(p_texture: Resource, p_index: int) -> void:
	print("Resource changed: ", p_texture, p_index)
	if plugin.is_terrain_valid():
		# If removing last entry and its selected, clear inspector
		if not p_texture and p_index == get_selected_index() and \
				get_selected_index() == entries.size() - 2:
			plugin.get_editor_interface().inspect_object(null)			
		plugin.terrain.get_assets().set_texture(p_index, p_texture)


func _on_resource_selected() -> void:
	print(plugin, ": Resource selected----------")
	plugin.select_terrain()

	# If not on a texture painting tool, then switch to Paint
	if plugin.editor.get_tool() != Terrain3DEditor.TEXTURE:
		var paint_btn: Button = plugin.ui.toolbar.get_node_or_null("PaintBaseTexture")
		if paint_btn:
			paint_btn.set_pressed(true)
			plugin.ui._on_tool_changed(Terrain3DEditor.TEXTURE, Terrain3DEditor.REPLACE)
	plugin.ui._on_setting_changed()
	print("Resource selected done")


func _on_resource_inspected(p_texture: Resource) -> void:
	print(plugin, ": Resource inspected: ", p_texture)
	plugin.get_editor_interface().inspect_object(p_texture, "", true)
	print("Resource inspected done")


func update_assets(p_args: Array = Array()) -> void:
	#print("update_assets, initizialized: ", _initialized, ", args: ", p_args)
	
	if not _initialized:
		print(self, "update_assets, not initizialized, returning")
		return

	if plugin.terrain and plugin.terrain.assets:
		if not plugin.terrain.assets.textures_changed.is_connected(update_assets):
			plugin.terrain.assets.textures_changed.connect(update_assets)

	clear()
	
	if plugin.is_terrain_valid() and plugin.terrain.assets:
		var texture_count: int = plugin.terrain.assets.get_texture_count()
		for i in texture_count:
			var texture: Terrain3DTexture = plugin.terrain.assets.get_texture(i)
			add_item(texture)
			
		if texture_count < Terrain3DAssets.MAX_TEXTURES:
			add_item()
				

func clear() -> void:
	for i in entries:
		i.get_parent().remove_child(i)
		i.queue_free()
	entries.clear()


func add_item(p_resource: Resource = null) -> void:
	var entry: ListEntry = ListEntry.new()
	entry.focus_style = focus_style
	var index: int = entries.size()
	
	entry.set_edited_resource(p_resource)
	entry.selected.connect(set_selected_index.bind(index))
	entry.inspected.connect(notify_resource_inspected)
	entry.changed.connect(notify_resource_changed.bind(index))
	
	if p_resource:
		entry.set_selected(index == selected_index)
		if not p_resource.id_changed.is_connected(set_selected_after_swap):
			p_resource.id_changed.connect(set_selected_after_swap)
	
	list.add_child(entry)
	entries.push_back(entry)


func set_selected_after_swap(p_old_index: int, p_new_index: int) -> void:
	set_selected_index(clamp(p_new_index, 0, entries.size() - 2))


func set_selected_index(p_index: int) -> void:
	selected_index = p_index
	emit_signal("resource_selected")
	
	for i in entries.size():
		var entry: ListEntry = entries[i]
		entry.set_selected(i == selected_index)


func get_selected_index() -> int:
	return selected_index


func notify_resource_inspected(p_resource: Resource) -> void:
	emit_signal("resource_inspected", p_resource)


func notify_resource_changed(p_resource: Resource, p_index: int) -> void:
	emit_signal("resource_changed", p_resource, p_index)
	if !p_resource:
		var last_offset: int = 2
		if p_index == entries.size()-2:
			last_offset = 3
		selected_index = clamp(selected_index, 0, entries.size() - last_offset)	


##############################################################
## class ListContainer
##############################################################

	
class ListContainer extends Container:
	var height: float = 0
	var width: float = 83

	
	func _ready() -> void:
			set_v_size_flags(SIZE_EXPAND_FILL)
			set_h_size_flags(SIZE_EXPAND_FILL)


	func get_entry_width() -> float:
		return width

	
	func set_entry_width(value: float) -> void:
		width = clamp(value, 56, 256)
		redraw()


	func redraw() -> void:
		height = 0
		var index: int = 0
		var separation: float = 4
		var columns: int = 3
		columns = clamp(size.x / width, 1, 100)
		
		for c in get_children():
			if is_instance_valid(c):
				c.size = Vector2(width, width) - Vector2(separation, separation)
				c.position = Vector2(index % columns, index / columns) * width + \
					Vector2(separation / columns, separation / columns)
				height = max(height, c.position.y + width)
				index += 1


	func _get_minimum_size() -> Vector2:
		return Vector2(0, height)

		
	func _notification(p_what) -> void:
		if p_what == NOTIFICATION_SORT_CHILDREN:
			redraw()


##############################################################
## class ListEntry
##############################################################


class ListEntry extends VBoxContainer:
	signal selected()
	signal changed(resource: Terrain3DTexture)
	signal inspected(resource: Terrain3DTexture)
	
	var resource: Terrain3DTexture
	var drop_data: bool = false
	var is_hovered: bool = false
	var is_selected: bool = false
	
	var button_clear: TextureButton
	var button_edit: TextureButton
	var name_label: Label
	
	@onready var add_icon: Texture2D = get_theme_icon("Add", "EditorIcons")
	@onready var clear_icon: Texture2D = get_theme_icon("Close", "EditorIcons")
	@onready var edit_icon: Texture2D = get_theme_icon("Edit", "EditorIcons")
	@onready var background: StyleBox = get_theme_stylebox("pressed", "Button")
	var focus_style: StyleBox
	

	func _ready() -> void:
		var icon_size: Vector2 = Vector2(12, 12)
		
		button_clear = TextureButton.new()
		button_clear.set_texture_normal(clear_icon)
		button_clear.set_custom_minimum_size(icon_size)
		button_clear.set_h_size_flags(Control.SIZE_SHRINK_END)
		button_clear.set_visible(resource != null)
		button_clear.pressed.connect(clear)
		add_child(button_clear)
		
		button_edit = TextureButton.new()
		button_edit.set_texture_normal(edit_icon)
		button_edit.set_custom_minimum_size(icon_size)
		button_edit.set_h_size_flags(Control.SIZE_SHRINK_END)
		button_edit.set_visible(resource != null)
		button_edit.pressed.connect(edit)
		add_child(button_edit)
		
		name_label = Label.new()
		add_child(name_label, true)
		name_label.visible = false
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		name_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		name_label.add_theme_color_override("font_shadow_color", Color.BLACK)
		name_label.add_theme_constant_override("shadow_offset_x", 1)
		name_label.add_theme_constant_override("shadow_offset_y", 1)
		name_label.add_theme_font_size_override("font_size", 15)
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		name_label.text = "Add New"
		
		
	func _notification(p_what) -> void:
		match p_what:
			NOTIFICATION_DRAW:
				var rect: Rect2 = Rect2(Vector2.ZERO, get_size())
				if !resource:
					draw_style_box(background, rect)
					draw_texture(add_icon, (get_size() / 2) - (add_icon.get_size() / 2))
				else:
					name_label.text = resource.get_name()
					self_modulate = resource.get_albedo_color()
					var texture: Texture2D = resource.get_albedo_texture()
					if texture:
						draw_texture_rect(texture, rect, false)
						texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
				name_label.add_theme_font_size_override("font_size", 4 + rect.size.x/10)
				if drop_data:
					draw_style_box(focus_style, rect)
				if is_hovered:
					draw_rect(rect, Color(1,1,1,0.2))
				if is_selected:
					draw_style_box(focus_style, rect)
			NOTIFICATION_MOUSE_ENTER:
				is_hovered = true
				name_label.visible = true
				queue_redraw()
			NOTIFICATION_MOUSE_EXIT:
				is_hovered = false
				name_label.visible = false
				drop_data = false
				queue_redraw()

	
	func _gui_input(p_event: InputEvent) -> void:
		if p_event is InputEventMouseButton:
			if p_event.is_pressed():
				match p_event.get_button_index():
					MOUSE_BUTTON_LEFT:
						# If `Add new` is clicked
						if !resource:
							set_edited_resource(Terrain3DTexture.new(), false)
							edit()
						else:
							emit_signal("selected")
					MOUSE_BUTTON_RIGHT:
						if resource:
							edit()
					MOUSE_BUTTON_MIDDLE:
						if resource:
							clear()


	func _can_drop_data(p_at_position: Vector2, p_data: Variant) -> bool:
		drop_data = false
		if typeof(p_data) == TYPE_DICTIONARY:
			if p_data.files.size() == 1:
				queue_redraw()
				drop_data = true
		return drop_data

		
	func _drop_data(p_at_position: Vector2, p_data: Variant) -> void:
		if typeof(p_data) == TYPE_DICTIONARY:
			var res: Resource = load(p_data.files[0])
			if res is Terrain3DTexture:
				set_edited_resource(res, false)
			if res is Texture2D:
				var surf: Terrain3DTexture = Terrain3DTexture.new()
				surf.set_albedo_texture(res)
				set_edited_resource(surf, false)

	
	func set_edited_resource(p_res: Terrain3DTexture, p_no_signal: bool = true) -> void:
		resource = p_res
		if resource:
			resource.setting_changed.connect(_on_texture_changed)
			resource.file_changed.connect(_on_texture_changed)
		
		if button_clear:
			button_clear.set_visible(resource != null)
			
		queue_redraw()
		if !p_no_signal:
			emit_signal("changed", resource)


	func _on_texture_changed() -> void:
		emit_signal("changed", resource)


	func set_selected(value: bool) -> void:
		is_selected = value
		queue_redraw()


	func clear() -> void:
		if resource:
			set_edited_resource(null, false)

	
	func edit() -> void:
		emit_signal("selected")
		emit_signal("inspected", resource)
