extends Node

@export var axe_ability_scene: PackedScene

var base_damage = 15
var additional_damage_percent = 1
var axe_count = 0

func _ready():
	$Timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	var foreground = get_tree().get_first_node_in_group("foreground_layer") as Node2D
	if foreground == null:
		return
	
	var direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var additional_rotation_degrees = 360.0 / (axe_count + 1)
	for i in axe_count + 1:
		var adjusted_direction = direction.rotated(deg_to_rad(i * additional_rotation_degrees))
		var axe_instance = axe_ability_scene.instantiate() as Node2D
		foreground.add_child(axe_instance)
		axe_instance.global_position = player.global_position + adjusted_direction
		axe_instance.hitbox_component.damage = base_damage * additional_damage_percent


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "axe_damage":
		additional_damage_percent = 1 + (current_upgrades["axe_damage"]["quantity"] * 0.1)
	if upgrade.id == "axe_count":
		axe_count = current_upgrades["axe_count"]["quantity"]
