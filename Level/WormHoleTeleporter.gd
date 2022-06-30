extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

export var teleport_position:NodePath

func _on_WormHoleTeleporter_body_entered(body):
	if body == Global.player and Global.dialog_manager.last_played_dialog != -1:
		Global.screen_flasher.flash()
		Global.player.teleport_to(get_node(teleport_position).global_position)
		Global.player.camera.limit_left = 0
		AudioStreamPlayer2d.autoplay=true
		AudioStreamPlayer2d.play()
		
