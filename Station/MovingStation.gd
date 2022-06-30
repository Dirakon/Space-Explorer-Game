extends KinematicBody2D

class_name MovingStation


var acceleration = 800
var friction = 3
var rotation_speed = 1

var max_speed = 300
var current_motion:Vector2 = Vector2.ZERO

var oldPlayerParent


func turn_off_partices():
	$AudioStreamPlayer.stream_paused=true
	$AudioStreamPlayer.playing=false
	$AudioStreamPlayer.volume_db = -100
	$CPUParticles2D2.emitting=false

var particles_strength_modifier = 2

func turn_on_particles(strength:float):
	var really_on = strength>1
	$AudioStreamPlayer.playing=really_on
	$AudioStreamPlayer.stream_paused=not really_on
	$AudioStreamPlayer.volume_db =-80+ strength/4
	$CPUParticles2D2.emitting=strength>0
	$CPUParticles2D2.initial_velocity = strength*particles_strength_modifier

func teleport_to(new_position):
	if being_controlled:
		var old_camera_offset = Global.player.remember_camera_position()
		global_position = new_position
		Global.player.recreate_camera_position(old_camera_offset)
	else:
		global_position = new_position

func _ready():
	Global.moving_station = self
	$LandingArea.take_control_option = funcref(self,"become_controlled_by_player")
	
	$LandingArea.connect("on_player_takes_off",
		self,
		"become_free")

var being_controlled = false
	
func _physics_process(delta):
	if not being_controlled:
		turn_off_partices()
		return
	
	process_rotation(delta)
	process_movement(delta)
	
func become_controlled_by_player():
	Global.player.disable_collisions()
	
	var old_position = Global.player.global_position
	var old_rotation = Global.player.global_rotation_degrees
	
	var pos = Global.player.remember_camera_position()
	
	oldPlayerParent = Global.player.get_parent()
	oldPlayerParent.remove_child(Global.player)
	
	add_child(Global.player)
	
	Global.player.global_position = old_position
	Global.player.global_rotation_degrees = old_rotation
	Global.player.recreate_camera_position(pos)
	
	being_controlled = true
	Global.station_menu.close_menu()
	Global.player.increase_camera_size()
	
func become_free():
	if not being_controlled:
		return
	
	Global.player.enable_collisions()
	
	var old_position = Global.player.global_position
	var old_rotation = Global.player.global_rotation_degrees
	
	var pos = Global.player.remember_camera_position()
	
	
	remove_child(Global.player)
	oldPlayerParent.add_child(Global.player)
	being_controlled = false
	
	
	Global.player.global_position = old_position
	Global.player.global_rotation_degrees = old_rotation
	
	Global.player.recreate_camera_position(pos)
	Global.player.decrease_camera_size()

func process_rotation(delta):
	var rotation_velocity = rotation_speed*delta
	if Input.is_action_pressed("rotate_right"):
		pass
	elif Input.is_action_pressed("rotate_left"):
		rotation_velocity*=-1
	else:
		rotation_velocity*=0
	rotate(rotation_velocity)
	
func process_movement(delta):
	var added_motion = delta* Vector2.RIGHT.rotated(transform.get_rotation()) * acceleration
	if Input.is_action_pressed("move_forward"):
		pass
	elif Input.is_action_pressed("move_backwards"):
		added_motion *= -1
	else:
		added_motion = -current_motion.normalized()*friction;
	current_motion = (current_motion+added_motion).clamped(max_speed)
	var collision = move_and_collide(current_motion*delta)
	if collision != null:
		current_motion *= 0.05
	turn_on_particles(current_motion.length())
	
