extends "res://nholes/nhole.gd"


export var tails  = []
export var free_tweens = []

export var min_time = 0.2
export var max_time = 1

export var min_mod = 0.1
export var max_mod = 0.7

export var min_scale = 0.1
export var max_scale = 0.7

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func make_tail():
	var tween = free_tweens.pop_back()
	var tail = tails.pop_front()
	var tail_node = get_node(tail)
	var tween_node = get_node(tween)
	
	tail_node.modulate.a = rand_range(min_mod,max_mod)
	
	tween_node.interpolate_property(tail_node, "scale"
		, Vector2 (0,0), Vector2 (1,1)*rand_range(min_scale,max_scale), rand_range(min_time,max_time)
		, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	
	tween_node.start()
	yield(tween_node,"tween_completed")
	
	tween_node.interpolate_property(tail_node, "scale"
		, tail_node.scale, Vector2 (0,0), rand_range(min_time,max_time)
		, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	
	
	
	tween_node.start()
	yield(tween_node,"tween_completed")
	
	tails.append(tail)
	free_tweens.append(tween)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if len(free_tweens) > 0:
		make_tail()
