@tool
extends Node2D
class_name platform

@onready var collision_shape = $CollisionShape
@onready var polygon = $Polygon
@onready var border_lines = $BorderLines

@export var borderTexture : Texture
@export var borderWidth : float
@export var enableSnap : bool = true
@export var centerRect : bool = false

#when adding platforms, make sure to right click on the platform node and select editable children

#makes collision handle visible and draggable in editor
func _update_editor_visibility() -> void:
	if not collision_shape or not polygon:
		return
	if Engine.is_editor_hint():
		collision_shape.visible = true
	else:
		collision_shape.visible = false
		polygon.visible = true
		for child in border_lines.get_children():
			child.visible = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_editor_visibility()
	_sync_shapes()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_snap_function()
		_sync_shapes()

func _snap_function() -> void:
	if not enableSnap or not Engine.is_editor_hint():
		return
	var current_position = collision_shape.position
	var new_position = Vector2()
	new_position.x = snapped(current_position.x, borderWidth/2)
	new_position.y = snapped(current_position.y, borderWidth/2)
	if not new_position.is_equal_approx(current_position):
		collision_shape.position = new_position
	
	var current_size = collision_shape.shape.size
	var new_size = Vector2()
	new_size.x = snapped(current_size.x, borderWidth/2)
	new_size.y = snapped(current_size.y, borderWidth/2)
	if not new_size.is_equal_approx(current_size):
		collision_shape.shape.size = new_size

func _center_node() -> void:
	global_position = collision_shape.global_position
	collision_shape.position = Vector2.ZERO
	collision_shape.force_update_transform()
	centerRect = false

func _get_points(size : Vector2) -> PackedVector2Array:
	var half_size = size/2
	var pts = PackedVector2Array()
	for v in range(-1, 2, 2):
		for h in range(-1, 2, 2):
			pts.push_back(Vector2(h * (-v) * half_size.x, v * half_size.y))
	return pts

func _sync_shapes() -> void:
	if not collision_shape or not polygon or not border_lines:
		return
	if centerRect:
		_center_node()
	var size_vector = collision_shape.shape.size
	var adjusted_size_vector = size_vector - Vector2(borderWidth, borderWidth)
	polygon.polygon = _get_points(adjusted_size_vector)
	#polygon.transform = collision_shape.
	_generate_border_lines(polygon.polygon)
	polygon.transform = collision_shape.transform
	border_lines.transform = collision_shape.transform
	
func _clear_children(parent_node) -> void:
	for child in parent_node.get_children():
		child.queue_free()

func _generate_border_lines(pts : PackedVector2Array) -> void:
	_clear_children(border_lines)
	var border_points = pts
	for i in border_points.size():
		var start_position = border_points.get(i)
		var end_position = border_points.get((i + 1) % border_points.size())
		var line_points = PackedVector2Array()
		line_points.push_back(Vector2())
		line_points.push_back(end_position - start_position)
		var line = Line2D.new()
		line.points = line_points
		line.position = start_position
		line.texture = borderTexture
		line.width = borderWidth
		line.texture_mode = Line2D.LINE_TEXTURE_TILE
		line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		border_lines.add_child(line)
	
	
