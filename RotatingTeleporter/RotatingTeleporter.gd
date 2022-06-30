extends Node2D

class_name RotatingTeleporter

var STABLE = 0
var UNSTABLE = 1

var appear_threshold_degrees = 18

var state = STABLE

export var gravitating_bodies = []
var gravitating_body_index = 0

var rotating_speed = 8
var current_magnetizing_position = -1

func set_as_visible(index):
	if current_magnetizing_position == -1:
		$Tween.interpolate_property( 
			$"RotatingPart", "modulate:a",    
			0, 1,   
			1,                  
			Tween.TRANS_BACK, Tween.EASE_OUT          
		)
		$Tween.start()
	current_magnetizing_position = index
	
func set_as_invisible():
	if current_magnetizing_position != -1:
		$Tween.interpolate_property( 
			$"RotatingPart", "modulate:a",    
			1, 0,   
			1,                  
			Tween.TRANS_BACK, Tween.EASE_OUT          
		)
		$Tween.start()
	current_magnetizing_position = -1
	

func _process(delta):
	$RotatingPart.rotation_degrees+=delta*rotating_speed
	var rotation_thresholds = [0, 90, 180, 270, 360]
	var formated_rotation = format_rotation()
	Global.current_clock_rotation = formated_rotation
	for threshold_index in range (5):
		var threshold = rotation_thresholds[threshold_index]
		threshold_index = threshold_index % 4
		if abs (threshold - formated_rotation) <= appear_threshold_degrees:
			set_as_visible(threshold_index)
			return
	set_as_invisible()	
	
func format_rotation():
	var current_rotation = fmod( $RotatingPart.rotation_degrees,360)
	while current_rotation < 0:
		current_rotation += 360
	return current_rotation

func _ready():
	Global.clock = self

var already_doing_teleportation = false
func apply_and_get_teleporting_position():
	if already_doing_teleportation or current_magnetizing_position == -1:
		return null
	already_doing_teleportation = true
	var position_to_teleport:Vector2
	if state == STABLE:
		var orbited_body = get_node(gravitating_bodies[gravitating_body_index])
		position_to_teleport = orbited_body.get_node(orbited_body\
			.rotation_to_unstable_position[current_magnetizing_position])\
			.global_position
		state = UNSTABLE
	elif state == UNSTABLE:
		gravitating_body_index = get_strongest_gravitating_body_index()
		var orbited_body = get_node(gravitating_bodies[gravitating_body_index])
		position_to_teleport = orbited_body.get_node(orbited_body.stable_position).global_position
		state = STABLE
	global_position = position_to_teleport
	return global_position

func do_player_teleportation():
	var offset_from_player = Global.player.global_position - global_position
	if apply_and_get_teleporting_position() == null:
		return
	Global.player.teleport_to(global_position + offset_from_player)
	yield(Global.screen_flasher.flash(), "finished")
	already_doing_teleportation = false
func do_station_teleportation():
	var offset_from_station = Global.moving_station.global_position - global_position
	if apply_and_get_teleporting_position() == null:
		return
	Global.moving_station.teleport_to(global_position + offset_from_station)
	if Global.moving_station.being_controlled:
		yield(Global.screen_flasher.flash(), "finished")
	else:
		yield(get_tree().create_timer(0.1), "timeout")
	already_doing_teleportation = false

func get_strongest_gravitating_body_index():
	var strongest_force = -1
	var strongest_index = -1
	for body_index in range(len(gravitating_bodies)):
		if not get_node(gravitating_bodies[body_index]).is_teleportable:
			continue
		var gravity  = get_node(gravitating_bodies[body_index]).force
		var distance = (get_node(gravitating_bodies[body_index]).global_position - global_position).length()
		var current_force = gravity/distance
		if current_force >= strongest_force:
			strongest_force = current_force
			strongest_index = body_index
	return strongest_index

func _on_TeleportingBody_body_entered(body):
	if body == Global.player:
		do_player_teleportation()
	if body == Global.moving_station:
		do_station_teleportation()
