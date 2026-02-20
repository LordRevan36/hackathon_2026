extends Node2D

#how many stages ahead of the player's current stage to prepare
@export var stages_to_build: int = 2

# Arrays to hold variants
@export var left_l_blocks: Array[PackedScene]
@export var right_l_blocks: Array[PackedScene]

@export var player: CharacterBody2D
@export var chunk_height: float = 1080.0

# Node references
@onready var start_point = $GenerationStartPoint
@onready var environment = $Environment

#Tracking stages
var active_stages: Array[Dictionary] = [] 
var highest_generated_stage: int = -1
var start_y: float

func _ready() -> void:
	randomize() # Ensures truly random seed every game
	start_y = start_point.global_position.y
	_check_and_update_chunks(0)

func _process(delta: float) -> void:
	if not player:
		return
	var distance_climbed = start_y - player.global_position.y
	var current_stage = floor(distance_climbed / chunk_height)
	_check_and_update_chunks(current_stage)

func _check_and_update_chunks(current_stage : int) -> void:
	#add new
	while highest_generated_stage < current_stage + 2:
		highest_generated_stage += 1
		_spawn_stage(highest_generated_stage)
	
	#remove old
	for i in range(active_stages.size() - 1, -1, -1):
		var stage_data = active_stages[i]
		if stage_data["stage_index"] < current_stage - 2:
			stage_data["left"].queue_free()
			stage_data["right"].queue_free()
			active_stages.remove_at(i)
			print("Unloaded stage: ", stage_data["stage_index"])

func _spawn_stage(stage_index: int) -> void:
	var left_scene = left_l_blocks.pick_random()
	var right_scene = right_l_blocks.pick_random()
	
	# Instantiate into nodes
	var left_instance = left_scene.instantiate()
	var right_instance = right_scene.instantiate()
	
	#position
	var spawn_y = start_y - chunk_height * stage_index
	var spawn_pos = Vector2(0, spawn_y)
	left_instance.position = spawn_pos
	right_instance.position = spawn_pos
	
	# add to environment tree
	environment.add_child(left_instance)
	environment.add_child(right_instance)
	
	# Save to delete later
	active_stages.append({
		"stage_index": stage_index,
		"left": left_instance,
		"right": right_instance
	})
