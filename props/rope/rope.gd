extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
var playerInMe = false
func _process(delta: float) -> void:
	if not get_overlapping_bodies().is_empty():
		for element in get_overlapping_bodies():
			if element.is_in_group("player"):
				global_player.climbEntr.emit(global_position.x)
				playerInMe = true
			elif playerInMe == true:
				playerInMe = false
				global_player.climbExit.emit()
	elif playerInMe == true:
		playerInMe = false
		global_player.climbExit.emit()
