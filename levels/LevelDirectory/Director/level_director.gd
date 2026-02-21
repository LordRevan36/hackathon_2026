extends Node2D

enum SetupType { L_BLOCKS, HALVES }
#how many stages ahead of the player's current stage to prepare
@export var stages_to_build: int = 2

# Arrays to hold variants
@export var left_l_blocks: Array[PackedScene]
@export var right_l_blocks: Array[PackedScene]

@export var left_halves: Array[PackedScene]
@export var right_halves: Array[PackedScene]

@export var player: CharacterBody2D
@export var monster: CharacterBody2D
#@export var chunk_height: float = 1080.0


# Node references
@onready var start_point = $GenerationStartPoint
@onready var environment = $Environment
@onready var game_over_label = $Camera/ScreenFader/GameOver
@onready var title_label = $Camera/ScreenFader/Title
@onready var end_background = $EndBackground

const SPAWN_DISTANCE = 2000.0 #distance away to spawn new stages and delete old ones
const MONSTER_AVOID_DIST = 500.0 #lose if monster ever above you and within 500px distance of you
const MONSTER_Y_GAP = 500.0 #lose if ever 500px below monster
#Tracking stages
var active_stages: Array[Dictionary] = [] 
var highest_generated_stage: int = -1
var start_y: float
var next_spawn_y: float
var last_setup_type: int = -1
var is_game_over : bool = false

func _ready() -> void:
	randomize() # Ensures truly random seed every game
	start_y = start_point.global_position.y
	next_spawn_y = start_y
	_check_and_update_chunks()

func _process(delta: float) -> void:
	if not player:
		return
	#var distance_climbed = start_y - player.global_position.y
	_check_and_update_chunks()
	if not is_game_over:
		_check_for_game_over()


func _check_for_game_over() -> void:
	if player.position.y > monster.position.y:
		if player.position.y > monster.position.y + MONSTER_Y_GAP or player.position.distance_to(monster.position) < MONSTER_AVOID_DIST:
			global_player.monsterGotPlayer.emit()
			monster._trigger_endgame_pounce(player)
			is_game_over = true
			game_over_label.visible = true
			title_label.visible = true


func _get_random_stage_pair() -> Dictionary:
	var available_setups = [SetupType.L_BLOCKS, SetupType.HALVES]
	if last_setup_type != -1:
		available_setups.erase(last_setup_type)
	var chosen_setup = available_setups.pick_random()
	last_setup_type = chosen_setup
	var left_scene : PackedScene
	var right_scene : PackedScene
	match chosen_setup:
		SetupType.L_BLOCKS:
			left_scene = left_l_blocks.pick_random()
			right_scene = right_l_blocks.pick_random()
		SetupType.HALVES:
			left_scene = left_halves.pick_random()
			right_scene = right_halves.pick_random()
	return {"left": left_scene, "right": right_scene}

func _check_and_update_chunks() -> void:
	#add new
	while next_spawn_y > player.position.y - SPAWN_DISTANCE:
		_spawn_stage()
		print("spawn stage")
	
	#remove old
	for i in range(active_stages.size() - 1, -1, -1):
		var stage_data = active_stages[i]
		if stage_data["left"].position.y > player.position.y + SPAWN_DISTANCE:
			stage_data["left"].queue_free()
			stage_data["right"].queue_free()
			active_stages.remove_at(i)
			print("Unloaded stage")

func _spawn_stage() -> void:
	var stage_scenes = _get_random_stage_pair()
	
	# Instantiate into nodes
	var left_instance = stage_scenes["left"].instantiate()
	var right_instance = stage_scenes["right"].instantiate()
	
	#position
	var spawn_pos = Vector2(0, next_spawn_y)
	next_spawn_y -= left_instance.chunk_height
	left_instance.position = spawn_pos
	right_instance.position = spawn_pos
	
	# add to environment tree
	environment.add_child(left_instance)
	environment.add_child(right_instance)
	
	# Save to delete later
	active_stages.append({
		"left": left_instance,
		"right": right_instance
	})
