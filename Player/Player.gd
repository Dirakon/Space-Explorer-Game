extends KinematicBody2D

class_name Player

var LANDING = 0
var LANDED = 1
var TAKING_OFF = 2
var FLIGHT = 3

var LANDING_TRESHOLD = 0.001

var MAX_HEALTH = 10
var health = MAX_HEALTH

var minimum_speed_to_damage = 210
var damage_per_speed = 0.01

var taking_off_time = 0.5
var acceleration = 1000
var friction = 4
var rotation_speed = 4
var current_landing_area:LandingArea = null
var current_landing_point:Node2D = null
var state = FLIGHT
onready var respawn_location : Vector2 = global_position

onready var camera:Camera2D = $Camera

var max_speed = 400
var current_motion:Vector2 = Vector2.ZERO

var time_left_to_take_off: float

func disable_collisions():
	collision_layer = 0
	collision_mask = 0
	pass

func enable_collisions():
	collision_layer = 1
	collision_mask = 1
	pass

func remember_camera_position():
	var current_camera_offset = global_position \
		 - camera.get_camera_screen_center()
	return current_camera_offset

func recreate_camera_position(offset):
	var new_position = global_position
	var new_camera_position = new_position - offset
	global_position = new_camera_position
	camera.align()
	camera.reset_smoothing()
	camera.force_update_scroll()
	global_position = new_position
	pass

func increase_camera_size():
	$Camera.zoom = Vector2(1.5,1.5)
func decrease_camera_size():
	$Camera.zoom =  Vector2(1,1)
	
func _ready():
	Global.player=self
	$Animation.play("FLIGHT")


func _physics_process(delta):
	if state == FLIGHT:
		process_rotation(delta)
		process_movement(delta)
		consider_landing(delta)
	elif state == LANDED:
		consider_taking_off(delta)
	elif state == LANDING:
		attempt_landing(delta)
	elif state == TAKING_OFF:
		attempt_taking_off(delta)


func process_rotation(delta):
	var rotation_velocity = rotation_speed*delta
	if Input.is_action_pressed("rotate_right"):
		pass
	elif Input.is_action_pressed("rotate_left"):
		rotation_velocity*=-1
	else:
		rotation_velocity*=0
	rotate(rotation_velocity)
	
#func take_damage(damage):
#	health -= damage
#	print(health)
#	if health <= 0:
#		get_tree().change_scene("res://my_scene.tscn")
	#	health = MAX_HEALTH
	#	teleport_to(respawn_location)
		
		
#func save(location):
#	var packed_scene = PackedScene.new()
#	packed_scene.pack(get_tree().get_current_scene())
#	ResourceSaver.save("res://my_scene.tscn", packed_scene)
#	#respawn_location = location
		
func process_movement(delta):
	var added_motion = delta* Vector2.RIGHT.rotated(transform.get_rotation()) * acceleration
	if Input.is_action_pressed("move_forward"):
		pass
	elif Input.is_action_pressed("move_backwards"):
		added_motion *= -1
	else:
		added_motion = -current_motion.normalized()*friction;
	current_motion = (current_motion+added_motion).clamped(max_speed)
	turn_on_particles(current_motion.length())
	var collision = move_and_collide(current_motion*delta)
	if collision != null:
		var collider = collision.collider
#		if current_motion.length() > minimum_speed_to_damage \
#			and collider.is_in_group("DamagingColliders"):
#			take_damage(current_motion.length() * damage_per_speed)
		current_motion *= 0.05
	
	
func consider_landing(delta):
	if not Input.is_action_just_pressed("ship_land"):
		return
	if current_landing_point == null:
		return
	turn_off_partices()
	state = LANDING
	var animation = $Animation.get_animation("LANDING")
	var track = animation.find_track(".:rotation_degrees")
	animation.track_set_key_value(track,0,rotation_degrees)
	animation.track_set_key_value(track,1,current_landing_area.global_rotation_degrees)
	$Animation.play("LANDING")
	
	
func consider_taking_off(delta):
	if (not Input.is_action_just_pressed("ship_land")) \
		or (not current_landing_area.player_control_is_allowed):
		return
	current_landing_area.player_takes_off()
	state = TAKING_OFF
	$Animation.play("TAKING_OFF")
	time_left_to_take_off = taking_off_time
#	save(global_position)

func cancel_landing():
	state = FLIGHT
	$Animation.play("FLIGHT")
	current_landing_point = null
	

func attempt_landing(delta):
	if current_landing_point == null:
		cancel_landing()
		return
	var movement_to_make = current_landing_point.global_position - global_position
	var distance_to_move = movement_to_make.length()
	if distance_to_move <= LANDING_TRESHOLD:
		if $Animation.current_animation_position < $Animation.current_animation_length:
			return
		state = LANDED
		$Animation.play("LANDED")
#		save(global_position)
		current_landing_area.open_station()
		global_position= current_landing_point.global_position
		return
	var distance_this_tick = min (max_speed*delta,distance_to_move)
	var direction = movement_to_make.normalized()
	
	global_position += direction*distance_this_tick
	
	
func attempt_taking_off(delta):
	time_left_to_take_off -= delta
	if time_left_to_take_off <= 0:
		state = FLIGHT
		$Animation.play("FLIGHT")
		return
	pass
	
func turn_off_partices():
	$AudioStreamPlayer.stream_paused=true
	$AudioStreamPlayer.playing=false
	$AudioStreamPlayer.volume_db = -100
	$CPUParticles2D.emitting=false
	$CPUParticles2D2.emitting=false

var particles_strength_modifier = 0.2

func turn_on_particles(strength:float):
	var really_on = strength>1
	$AudioStreamPlayer.playing=really_on
	$AudioStreamPlayer.stream_paused=not really_on
	$AudioStreamPlayer.volume_db =-80+ strength/6
	$CPUParticles2D.emitting=really_on
	$CPUParticles2D2.emitting=really_on
	$CPUParticles2D.initial_velocity = strength*particles_strength_modifier
	$CPUParticles2D2.initial_velocity =strength*particles_strength_modifier


func teleport_to(new_position):
	var old_camera_offset = remember_camera_position()
	#global_position \
	#	 - camera.get_camera_screen_center()
	#var new_camera_position =  new_position - old_camera_offset
	#global_position = new_camera_position
#	camera.align()
#	camera.reset_smoothing()
#	camera.force_update_scroll()
	global_position = new_position
	recreate_camera_position(old_camera_offset)

	
# Signal callbacks

func _on_LandingArea_body_exited_area(body,area):
	if not body == self:
		return
	var landingPoint = area.get_landing_point()
	if landingPoint == current_landing_point:
		current_landing_point = null

func _on_LandingArea_body_entered_area(body, area):
	if body!=self:
		return
	var landingPoint = area.get_landing_point()
	if landingPoint != current_landing_point:
		current_landing_area = area
		current_landing_point = landingPoint

