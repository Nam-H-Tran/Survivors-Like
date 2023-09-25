extends Node

const SPAWN_RADIUS = 375

@export var basic_enemy_scene: PackedScene = preload("res://scenes/game_object/basic_enemy/basic_enemy.tscn")
@export var wizard_enemy_scene: PackedScene = preload("res://scenes/game_object/wizard_enemy/wizard_enemy.tscn")
@export var megarat_enemy_scene: PackedScene = preload("res://scenes/game_object/megarat_enemy/megarat_enemy.tscn")
@export var crab_enemy_scene: PackedScene = preload("res://scenes/game_object/crab_enemy/crab_enemy.tscn")
@export var bat_enemy_scene: PackedScene = preload("res://scenes/game_object/bat_enemy/bat_enemy.tscn")
@export var cyclops_enemy_scene: PackedScene = preload("res://scenes/game_object/cyclops_enemy/cyclops_enemy.tscn")
@export var arena_time_manager: Node

@onready var timer = $Timer

var base_spawn_time = 0
var number_to_spawn = 1
var enemy_table = WeightedTable.new()
var add_wizard_enemy = false
var add_megarat_enemy = false
var add_crab_enemy = false
var add_cyclops_boss = false

func _ready():
	enemy_table.add_item(basic_enemy_scene, 50)
	enemy_table.add_item(bat_enemy_scene, 30)
	base_spawn_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)


func get_spawn_position():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return Vector2.ZERO
	
	var spawn_position = Vector2.ZERO
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	for i in 4:
		spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)
		
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position, 1 << 0)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		
		if result.is_empty():
			break
		else:
			random_direction = random_direction.rotated(deg_to_rad(90))
	
	return spawn_position

func on_timer_timeout():
	timer.start()
	
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	for i in number_to_spawn:
		var enemy_scene = enemy_table.pick_item()
		var enemy = enemy_scene.instantiate() as Node2D
		
		var entities_layer = get_tree().get_first_node_in_group("entities_layer")
		entities_layer.add_child(enemy)
		enemy.global_position = get_spawn_position()


func on_arena_difficulty_increased(arena_difficulty: int):
	var time_off = (0.15 / 12) * arena_difficulty
	var boss = cyclops_enemy_scene.instantiate() as Node2D
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	time_off = min(time_off, 0.9)
	timer.wait_time = base_spawn_time - time_off
	
	if arena_difficulty == 6 and add_wizard_enemy == false:
		number_to_spawn += 1
		enemy_table.add_item(wizard_enemy_scene, 25)
		add_wizard_enemy = true
	
	if arena_difficulty == 18 and add_crab_enemy == false:
		enemy_table.add_item(crab_enemy_scene, 20)
		add_crab_enemy = true
	
	if arena_difficulty == 30 and add_megarat_enemy == false:
		number_to_spawn += 1
		enemy_table.add_item(megarat_enemy_scene, 1)
		add_megarat_enemy = true
	
	if arena_difficulty == 48 and add_cyclops_boss == false:
		entities_layer.add_child(boss)
		boss.global_position = get_spawn_position()
		add_cyclops_boss = true
