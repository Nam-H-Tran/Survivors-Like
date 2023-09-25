extends Node
class_name HealthComponent

signal died
signal health_changed

@export var max_health: float = 10

var current_health
var adjusted_max_health = max_health

func _ready():
	var health_gain_upgrade_count = MetaProgression.get_upgrade_count("more_health")
	if health_gain_upgrade_count > 0:
		adjusted_max_health += 5
	current_health = max_health



func damage(damage_amount: float):
	current_health = max(current_health - damage_amount, 0)
	health_changed.emit()
	Callable(check_death).call_deferred()


func get_health_percent():
	if adjusted_max_health <= 0:
		return 0
	return min(current_health / adjusted_max_health, 1)


func check_death():
	if current_health == 0:
		died.emit()
		owner.queue_free()
