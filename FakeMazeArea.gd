extends Area2D

export var partice_systems = []

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	for path in partice_systems:
		var ps:CPUParticles2D = get_node(path)
		ps.global_rotation_degrees = Global.current_clock_rotation

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
