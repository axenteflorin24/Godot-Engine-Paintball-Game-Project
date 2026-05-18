extends CharacterBody3D

const LERP_VALUE : float = 0.8


var speed : float
@onready var bullet_sounds = [$sfx/bullet_a, $sfx/bullet_b, $sfx/bullet_c, $sfx/bullet_d]

@export var walk_speed : float = 2.0
@export var run_speed : float = 4.48
@export var crounching_run_speed : float = 3.687
@export var jump_speed : float = 2.878
@export var prone_speed : float = 1.3899999999
@export var jump_strength : float = 3.68
@export var gravity : float = 9.8

@onready var BulletSpawnLocation = $Armature/Skeleton3D/Animated_collision_r_hand/paintball_gun/bullet_spawn_location


@onready var world = $".."

var player_collision_deff = Vector2(0.285, 1.733)
var player_collision_crounching = Vector2(0.18, 1.383)

const ANIMATION_BLEND : float = 8.0

@onready var player_mesh : Node3D = $Armature

@onready var animator : AnimationTree = $AnimationTree
var CustomCollisions  = []

@export var crounching = false

@export var prone = false

@export var action = false

var SpringArmPivotPos = Vector3(0.995397, 0.041061, -38.90305)
var Prone_SpringArmPivotPos = Vector3(0.995397, -0.705003, -38.90305)


@export var player_status = 'crounching_idle'
var bullet 

var action_animations = [["parameters/transition_default_idle_action/transition_request", "Action"], ["parameters/transition_default_walking_action/transition_request", "Action"], ["parameters/transition_default_running_action/transition_request", "Action"] ,["parameters/transition_default_jumping_action/transition_request", "Action"], ["parameters/transition_crounching_idle_action/transition_request", "Action"], ["parameters/transition_crounching_walking_action/transition_request", "Action"], ["parameters/transition_crounching_running_action/transition_request", "Action"], ["parameters/transition_crounching_jumping_action/transition_request", "Action"], ["parameters/transition_prone_idle_action/transition_request", "Action"]]
var release_action_animations  = [["parameters/transition_default_idle_action/transition_request", "NoAction"], ["parameters/transition_default_walking_action/transition_request", "NoAction"], ["parameters/transition_default_running_action/transition_request", "NoAction"] ,["parameters/transition_default_jumping_action/transition_request", "NoAction"], ["parameters/transition_crounching_idle_action/transition_request", "NoAction"], ["parameters/transition_crounching_walking_action/transition_request", "NoAction"], ["parameters/transition_crounching_running_action/transition_request", "NoAction"], ["parameters/transition_crounching_jumping_action/transition_request", "NoAction"], ["parameters/transition_prone_idle_action/transition_request", "NoAction"]]

func _ready():
	name = name_generator()
	init_custom_collisions()
	

func _physics_process(delta):
	
	
	CollisionsSync()
	
	
	move_and_slide()
	

func _animations(delta):
	
	_sfxSync()
	gun_action()
	movement_animations(delta)
	movement(delta)

func update_action_animations(Type='release'):

	pass

func name_generator():
	
	var random_a = randi_range(1, 100)
	var random_b = randi_range(1, 1000)
	var random_c = randi_range(1, 10000)
	
	var random_name = 'AIPlayer_'+str(random_a)+'_'+str(random_b)+'_'+str(random_c)
	return random_name
func check_node(_Node, Name):
	var array = _Node.get_children()
	for row in array:
		
		if row.name == Name:
			return true
	return false	
		
func gun_action():
	pass
	
func movement(delta):
	pass

func movement_animations(delta):
	pass

func _sfxSync():
	$sfx.global_position = global_position	

func CollisionsSync():
	
	
	$player_collision.global_rotation = $Armature/Skeleton3D/Animated_collision_hips/Animated_collision_hips.global_rotation
	if prone:
		$player_collision.global_position.y = $Armature/Skeleton3D/Animated_collision_hips/Animated_collision_hips.global_position.y+0.18
	else:
		if crounching:
			$player_collision.global_position.y = $Armature/Skeleton3D/Animated_collision_hips/Animated_collision_hips.global_position.y
		else:
			$player_collision.global_position.y = $Armature/Skeleton3D/Animated_collision_hips/Animated_collision_hips.global_position.y
	
	for row in CustomCollisions:
		
		if not row['target'] == null and not row['source'] == null:
			row['target'].global_position = row['source'].global_position
			row['target'].global_rotation = row['source'].global_rotation
			if not row['angle'] == null:
				row['target'].global_rotation.z = row['angle']


func init_custom_collisions():
	CustomCollisions = [{ "target" : $Animated_collision_head, "source" : $Armature/Skeleton3D/Animated_collision_head/Animated_collision_head, "angle" : null}, { "target" : $Animated_collision_neck, "source" : $Armature/Skeleton3D/Animated_collision_neck/Animated_collision_neck, "angle" : null}, { "target" : $Animated_collision_upper_body, "source" : $Armature/Skeleton3D/Animated_collision_upper_body/Animated_collision_upper_body,"angle" : 89.8}, { "target" : $Animated_collision_body, "source" : $Armature/Skeleton3D/Animated_collision_body/Animated_collision_body, "angle" : null}, { "target" : $Animated_collision_hips, "source" : $Armature/Skeleton3D/Animated_collision_hips/Animated_collision_hips, "angle" : null}, { "target" : $Animated_collision_r_up_leg, "source" : $Armature/Skeleton3D/Animated_collision_r_up_leg/Animated_collision_r_up_leg, "angle" : null}, { "target" : $Animated_collision_l_up_leg, "source" : $Armature/Skeleton3D/Animated_collision_l_up_leg/Animated_collision_l_up_leg, "angle" : null}, { "target" : $Animated_collision_r_leg, "source" : $Armature/Skeleton3D/Animated_collision_r_leg/Animated_collision_r_leg, "angle" : null}, { "target" : $Animated_collision_l_leg, "source" : $Armature/Skeleton3D/Animated_collision_l_leg/Animated_collision_l_leg, "angle" : null}, { "target" : $Animated_collision_r_foot, "source" : $Armature/Skeleton3D/Animated_collision_r_foot/Animated_collision_r_foot, "angle" : null}, { "target" : $Animated_collision_l_foot, "source" : $Armature/Skeleton3D/Animated_collision_l_foot/Animated_collision_l_foot, "angle" : null}, { "target" : $Animated_collision_r_foot_toe, "source" : $Armature/Skeleton3D/Animated_collision_r_foot_toe/Animated_collision_r_foot_toe, "angle" : null}, { "target" : $Animated_collision_l_foot_toe, "source" : $Armature/Skeleton3D/Animated_collision_l_foot_toe/Animated_collision_l_foot_toe, "angle" : null}, { "target" : $Animated_collision_r_upper_arm, "source" : $Armature/Skeleton3D/Animated_collision_r_upper_arm/Animated_collision_r_upper_arm, "angle" : null}, { "target" : $Animated_collision_l_upper_arm, "source" : $Armature/Skeleton3D/Animated_collision_l_upper_arm/Animated_collision_l_upper_arm, "angle" : null}, { "target" : $Animated_collision_r_arm, "source" : $Armature/Skeleton3D/Animated_collision_r_arm/Animated_collision_r_arm, "angle" : null}, { "target" : $Animated_collision_l_arm, "source" : $Armature/Skeleton3D/Animated_collision_l_arm/Animated_collision_l_arm, "angle" : null}, { "target" : $Animated_collision_r_hand, "source" : $Armature/Skeleton3D/Animated_collision_r_hand/Animated_collision_r_hand, "angle" : null}, { "target" : $Animated_collision_l_hand, "source" : $Armature/Skeleton3D/Animated_collision_l_hand/Animated_collision_l_hand, "angle" : null}, { "target" : $Animated_collision_l_pinky1, "source" : $Armature/Skeleton3D/Animated_collision_l_pinky1/Animated_collision_l_pinky1, "angle" : null}, { "target" : $Animated_collision_l_pinky2, "source" : $Armature/Skeleton3D/Animated_collision_l_pinky2/Animated_collision_l_pinky2, "angle" : null}, { "target" : $Animated_collision_l_pinky3, "source" : $Armature/Skeleton3D/Animated_collision_l_pinky3/Animated_collision_l_pinky3, "angle" : null}, { "target" : $Animated_collision_l_ring1, "source" : $Armature/Skeleton3D/Animated_collision_l_ring1/Animated_collision_l_ring1, "angle" : null}, { "target" : $Animated_collision_l_ring2, "source" : $Armature/Skeleton3D/Animated_collision_l_ring2/Animated_collision_l_ring2, "angle" : null}, { "target" : $Animated_collision_l_ring3, "source" : $Armature/Skeleton3D/Animated_collision_l_ring3/Animated_collision_l_ring3, "angle" : null}, { "target" : $Animated_collision_l_middle1, "source" : $Armature/Skeleton3D/Animated_collision_l_middle1/Animated_collision_l_middle1, "angle" : null}, { "target" : $Animated_collision_l_middle2, "source" : $Armature/Skeleton3D/Animated_collision_l_middle2/Animated_collision_l_middle2, "angle" : null}, { "target" : $Animated_collision_l_middle3, "source" : $Armature/Skeleton3D/Animated_collision_l_middle3/Animated_collision_l_middle3, "angle" : null}, { "target" : $Animated_collision_l_index1, "source" : $Armature/Skeleton3D/Animated_collision_l_index1/Animated_collision_l_index1, "angle" : null}, { "target" : $Animated_collision_l_index2, "source" : $Armature/Skeleton3D/Animated_collision_l_index2/Animated_collision_l_index2, "angle" : null}, { "target" : $Animated_collision_l_index3, "source" : $Armature/Skeleton3D/Animated_collision_l_index3/Animated_collision_l_index3, "angle" : null}, { "target" : $Animated_collision_l_thumb1,   "source" : $Armature/Skeleton3D/Animated_collision_l_thumb1/Animated_collision_l_thumb1, "angle" : null}, { "target" : $Animated_collision_l_thumb2, "source" : $Armature/Skeleton3D/Animated_collision_l_thumb2/Animated_collision_l_thumb2, "angle" : null}, { "target" : $Animated_collision_l_thumb3, "source" : $Armature/Skeleton3D/Animated_collision_l_thumb3/Animated_collision_l_thumb3, "angle" : null}, { "target" : $Animated_collision_r_pinky1, "source" : $Armature/Skeleton3D/Animated_collision_r_pinky1/Animated_collision_r_pinky1, "angle" : null}, { "target" : $Animated_collision_r_pinky2, "source" : $Armature/Skeleton3D/Animated_collision_r_pinky2/Animated_collision_r_pinky2, "angle" : null}, { "target" : $Animated_collision_r_pinky3, "source" : $Armature/Skeleton3D/Animated_collision_r_pinky3/Animated_collision_r_pinky3, "angle" : null}, { "target" : $Animated_collision_r_ring1, "source" : $Armature/Skeleton3D/Animated_collision_r_ring1/Animated_collision_r_ring1, "angle" : null}, { "target" : $Animated_collision_r_ring2, "source" : $Armature/Skeleton3D/Animated_collision_r_ring2/Animated_collision_r_ring2, "angle" : null}, { "target" : $Animated_collision_r_ring3, "source" : $Armature/Skeleton3D/Animated_collision_r_ring3/Animated_collision_r_ring3, "angle" : null}, { "target" : $Animated_collision_r_middle1, "source" : $Armature/Skeleton3D/Animated_collision_r_middle1/Animated_collision_r_middle1, "angle" : null}, { "target" : $Animated_collision_r_middle2, "source" : $Armature/Skeleton3D/Animated_collision_r_middle2/Animated_collision_r_middle2, "angle" : null}, { "target" : $Animated_collision_r_middle3, "source" : $Armature/Skeleton3D/Animated_collision_r_middle3/Animated_collision_r_middle3, "angle" : null}, { "target" : $Animated_collision_r_index1, "source" : $Armature/Skeleton3D/Animated_collision_r_index1/Animated_collision_r_index1, "angle" : null}, { "target" : $Animated_collision_r_index2, "source" : $Armature/Skeleton3D/Animated_collision_r_index2/Animated_collision_r_index2, "angle" : null}, { "target" : $Animated_collision_r_index3, "source" : $Armature/Skeleton3D/Animated_collision_r_index3/Animated_collision_r_index3, "angle" : null}, { "target" : $Animated_collision_r_thumb1, "source" : $Armature/Skeleton3D/Animated_collision_r_thumb1/Animated_collision_r_thumb1, "angle" : null}, { "target" : $Animated_collision_r_thumb2, "source" : $Armature/Skeleton3D/Animated_collision_r_thumb2/Animated_collision_r_thumb2, "angle" : null}, { "target" : $Animated_collision_r_thumb3, "source" : $Armature/Skeleton3D/Animated_collision_r_thumb3/Animated_collision_r_thumb3, "angle" : null}]


func _on_action_timeout() -> void:
	update_action_animations('release')
