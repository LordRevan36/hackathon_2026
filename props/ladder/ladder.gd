extends Area2D
func _process(delta: float) -> void:
	if monitoring == true and get_overlapping_bodies()[1] == Player:
		global_player.climbEntr.emit(self.position.x)
