extends Node3D


@export var change_fov_on_run : bool
@export var normal_fov : float = 108.0
@export var run_fov : float = 118.68
@export var shoot_gun = true
const CAMERA_BLEND : float = 0.05

@onready var spring_arm : SpringArm3D = $SpringArm3D
@onready var camera : Camera3D = $SpringArm3D/Camera3D
@onready var animator = $"../AnimationTree"
@onready var crosshair = $"../CrossHair/CrossHairTexture"
@onready var player = $".."

var target_rotation_y: float = 0.0
var target_rotation_x: float = 0.0


var rot_y: float = 0.0
var rot_x: float = 0.0


const SENS_MIN = 0.00248 
const SENS_MAX = SENS_MIN*PI/2
const Acceleration = PI*10
var crosshair_pose = 'player'

func _ready():
	
	SetCrossHairPosition()
	
	change_fov_on_run = true
	
	target_rotation_y = rotation.y
	
	target_rotation_x = spring_arm.rotation.x
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	
	if event is InputEventMouseMotion:
		
		var mouse_speed = event.relative.length()

		var current_sens = remap(mouse_speed, 0, Acceleration, SENS_MIN, SENS_MAX)
		
		current_sens = clamp(current_sens, SENS_MIN, SENS_MAX)

		rot_y -= event.relative.x * current_sens
		
		rot_x -= event.relative.y * current_sens
		
		rot_x = clamp(rot_x, -PI/4, PI/4)
		
		rotation.y = rot_y
		
		spring_arm.rotation.x = rot_x

func SetCrossHairPosition(mode='player'):
	
	if mode == 'player':
		
		var x = (get_viewport().size.x/2)*1.133
		
		var y = (get_viewport().size.y/2)/1.1
		
		crosshair.position.x = int(x)
		
		crosshair.position.y = int(y)
	
	if mode == "crounching":
		
		var x = (get_viewport().size.x/2)*1.133
		
		var y = (get_viewport().size.y/2)
		
		crosshair.position.x = int(x)
		
		crosshair.position.y = int(y)
	
	if mode == 'prone':
		
		var x = (get_viewport().size.x/2)
		
		var y = (get_viewport().size.y/2)/1.668
		
		crosshair.position.x = int(x)
		
		crosshair.position.y = int(y)
		
func get_player_status():
	
	return player.player_status.split("_")[0]

func _physics_process(delta):
	
	#IK
	var player_status = get_player_status()
	if not $"../Timers/action".is_stopped():
		
		animator.set("parameters/ik_default_walking_pos/blend_amount", lerp(animator.get("parameters/ik_default_walking_pos/blend_amount"), rot_x, delta * 8.0))
		animator.set("parameters/ik_default_idle_pos/blend_amount", lerp(animator.get("parameters/ik_default_idle_pos/blend_amount"), rot_x, delta * 8.0))
		animator.set("parameters/ik_default_running_pos/blend_amount", lerp(animator.get("parameters/ik_default_running_pos/blend_amount"), rot_x, delta * 8.0))
		animator.set("parameters/ik_default_jumping_pos/blend_amount", lerp(animator.get("parameters/ik_default_jumping_pos/blend_amount"), rot_x*1.668, delta * 8.0))
		animator.set("parameters/ik_crounching_idle_pos/blend_amount", lerp(animator.get("parameters/ik_crounching_idle_pos/blend_amount"), rot_x, delta * 8.0))
		animator.set("parameters/ik_crounching_walking_pos/blend_amount", lerp(animator.get("parameters/ik_crounching_walking_pos/blend_amount"), rot_x*2.268, delta * 8.0))	
		animator.set("parameters/ik_crounching_running_pos/blend_amount", lerp(animator.get("parameters/ik_crounching_running_pos/blend_amount"), rot_x*1.268, delta * 8.0))		
		animator.set("parameters/ik_crounching_jumping_pos/blend_amount", lerp(animator.get("parameters/ik_crounching_jumping_pos/blend_amount"), rot_x*1.268, delta * 8.0))		
		animator.set("parameters/ik_prone_idle_pos/blend_amount", lerp(animator.get("parameters/ik_prone_idle_pos/blend_amount"), rot_x*3.68, delta * 8.0))		
	
	
	var _player_status = player_status

	if not _player_status == crosshair_pose:
		crosshair_pose = _player_status
		SetCrossHairPosition(_player_status)
	
	if change_fov_on_run:
		if owner.is_on_floor():
			
			if Input.is_action_pressed("run"):
				
				camera.fov = lerp(camera.fov, run_fov, CAMERA_BLEND)
			else:
				camera.fov = lerp(camera.fov, normal_fov, CAMERA_BLEND)
		else:
			camera.fov = lerp(camera.fov, normal_fov, CAMERA_BLEND)
