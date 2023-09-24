extends CanvasLayer

signal transitioned_halfway

var skip_emit = false

func transition():
	$AnimationPlayer.play("default")
	await $AnimationPlayer.animation_finished
	transitioned_halfway.emit()
	$AnimationPlayer.play_backwards("default")


func transition_to_scene(scene_path: String):
	transition()
	await transition()
	get_tree().change_scene_to_file(scene_path)


func emit_transitioned_halfway():
	if skip_emit:
		skip_emit = false
		return
	transitioned_halfway.emit()
