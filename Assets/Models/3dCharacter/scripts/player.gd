extends CharacterBody3D

const LERP_VALUE : float = 0.18


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
@onready var spring_arm_pivot : Node3D = $SpringArmPivot
@onready var animator : AnimationTree = $AnimationTree

var CustomCollisions  = []

@export var crounching = false

@export var prone = false

@export var action = false

var SpringArmPivotPos = Vector3(0.995397, 0.041061, -38.90305)
var Prone_SpringArmPivotPos = Vector3(0.995397, -0.705003, -38.90305)
var SpringArmAnimation = false
var _SpringArmAnimation = false

@export var player_status = 'crounching_idle'
var bullet 

var action_animations = [["parameters/transition_default_idle_action/transition_request", "Action"], ["parameters/transition_default_walking_action/transition_request", "Action"], ["parameters/transition_default_running_action/transition_request", "Action"] ,["parameters/transition_default_jumping_action/transition_request", "Action"], ["parameters/transition_crounching_idle_action/transition_request", "Action"], ["parameters/transition_crounching_walking_action/transition_request", "Action"], ["parameters/transition_crounching_running_action/transition_request", "Action"], ["parameters/transition_crounching_jumping_action/transition_request", "Action"], ["parameters/transition_prone_idle_action/transition_request", "Action"]]
var release_action_animations  = [["parameters/transition_default_idle_action/transition_request", "NoAction"], ["parameters/transition_default_walking_action/transition_request", "NoAction"], ["parameters/transition_default_running_action/transition_request", "NoAction"] ,["parameters/transition_default_jumping_action/transition_request", "NoAction"], ["parameters/transition_crounching_idle_action/transition_request", "NoAction"], ["parameters/transition_crounching_walking_action/transition_request", "NoAction"], ["parameters/transition_crounching_running_action/transition_request", "NoAction"], ["parameters/transition_crounching_jumping_action/transition_request", "NoAction"], ["parameters/transition_prone_idle_action/transition_request", "NoAction"]]
@export var bullets_counter = 0
@export var bullets_hit = 0
@export var bullet_collinder = 'n/a'
func update_bullets_counter():
	
	$BulletCount.text = 'Bullets Counter : '+str(bullets_counter)
	$HitCounter.text = 'Hit Counter : '+str(bullets_hit)
	var accuracy = 0
	
	if bullets_hit > 0 and bullets_counter > 0:
		accuracy = (bullets_hit*100)/bullets_counter
	$BulletAccuracy.text = 'Bullet Raycast Accuracy : '+str(accuracy)
	$CrossHairRay.text = 'CrossHair Ray : '+$CrossHair/CrossHairTexture.ray_collinder
	$BulletRay.text = 'Latest BulletRay : '+str(bullet_collinder)

func _ready():

	update_bullets_counter()
	
	init_custom_collisions()
	
	bullet = preload("res://Assets/Models/paintball_gun/bullet.tscn")
	
	var _bullet = bullet.instantiate()
	
	_bullet.name = name_generator()
	
	_bullet.speed = 80

	#spring_arm_pivot.global_position = SpringArmPivotPos
	
	if crounching:
		$player_collision.get('shape').set("height", player_collision_crounching.y)

func PlayerStatus():
	$Status.text = str(player_status)

func _physics_process(delta):
	
	update_bullets_counter()
	
	CollisionsSync()
	
	PlayerStatus()
	
	_animations(delta)
	
	move_and_slide()
	
func _animations(delta):
	
	SprinArm()
	
	_sfxSync()
	
	gun_action()
	
	movement_animations(delta)
	
	movement(delta)

func SprinArm():
	
	if SpringArmAnimation == true:
		
		$SpringArmPivot.global_position.y = lerp($SpringArmPivot.global_position.y, Prone_SpringArmPivotPos.y, 0.08)
		if $SpringArmPivot.global_position.y <= Prone_SpringArmPivotPos.y:
			SpringArmAnimation = false
			$SpringArmPivot.global_position.y = Prone_SpringArmPivotPos.y
	
	if _SpringArmAnimation == true:
		
		$SpringArmPivot.global_position.y = lerp($SpringArmPivot.global_position.y, SpringArmPivotPos.y, 0.08)
		if $SpringArmPivot.global_position.y >= SpringArmPivotPos.y-0.0000068:
			_SpringArmAnimation = false
			$SpringArmPivot.global_position.y = SpringArmPivotPos.y
func update_action_animations(Type='release'):

	var array = action_animations
	if Type == 'release':
		
		action = false
		
		$Action.text = 'Action : false'
		
		array = release_action_animations
	
	if Type == 'apply':
		
		action = true
		
		$Action.text = 'Action : true'
	
	for row in array:
		
		animator.set(row[0], row[1])

func name_generator():
	
	var random_a = randi_range(1, 100)
	var random_b = randi_range(1, 1000)
	var random_c = randi_range(1, 10000)
	
	var random_name = 'bullet_'+str(random_a)+'_'+str(random_b)+'_'+str(random_c)
	
	return random_name

func check_node(_Node, Name):
	
	var array = _Node.get_children()
	for row in array:
		
		if row.name == Name:
			return true
	return false	
		
func gun_action():
	
	if not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_backwards"):
		if $Timers/bullets_animation.is_stopped():
				
				$bulet_animation.play("bullet_transparency")
		
		if not $CrossHair/CrossHairTexture.ray_collinder == 'player':
				
			if Input.is_action_just_pressed("action"):
				
				$Timers/bullets_animation.start()
				if $Timers/look_up.is_stopped():
					$Timers/look_up.start()
				
				if $Timers/action.is_stopped():
					$Timers/action_wait.start()
					
					update_action_animations('apply')	
				
				
				if $Timers/action_wait.is_stopped():
					
					$bulet_animation.play("bulet_animation")
					
					bullets_counter = bullets_counter+1
					
					var _bullet = bullet.instantiate()
					
					_bullet.name = name_generator()
					
					
					if not check_node(BulletSpawnLocation, _bullet.name):
						
						BulletSpawnLocation.add_child(_bullet)
						bullet_sounds[randi_range(0, bullet_sounds.size()-1)].play()



				$Timers/action.set("wait_time" , 1.368)
				$Timers/action.start()
					
			if not $Timers/look_up.is_stopped():
				$Armature.rotation.y = lerp_angle($Armature.rotation.y, spring_arm_pivot.rotation.y+deg_to_rad(180), 0.138)



func movement(delta):
	
	if Input.is_action_just_pressed("crounch"):
		if crounching == true:
			$player_collision.get('shape').set("height", player_collision_deff.y)
			crounching = false
		else:
			$player_collision.get('shape').set("height", player_collision_crounching.y)
			crounching = true
	if Input.is_action_just_pressed("prone"):
		
		var logical = true
		if crounching == true and prone == false:
			_SpringArmAnimation = false
			SpringArmAnimation = true
			$player_collision.get('shape').set("height", player_collision_deff.y)
			logical = false
			crounching = false
			prone = true
		if prone == true and logical == true:
			
			SpringArmAnimation = false
			
			_SpringArmAnimation = true
			
			$player_collision.get('shape').set("height", player_collision_crounching.y)
			
			crounching = true
			
			prone = false

	var move_direction : Vector3 = Vector3.ZERO
	move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_direction.z = Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forwards")
	move_direction = move_direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)	

	velocity.y -= gravity * delta
	
	if Input.is_action_pressed("run"):
		
		if prone:
			
			speed = prone_speed
		
		else:
			
			if crounching:
				
				speed = crounching_run_speed
			
			else:
				
				if not is_on_floor():
					
					speed = jump_speed
				
				else:
					
					speed = run_speed
		
	else:
		
		if prone:
			
			speed = prone_speed	
		
		else:	
			
			if not is_on_floor():
				
				speed = jump_speed
			
			else:		

				speed = walk_speed
	
	velocity.x = move_direction.x * speed
	
	velocity.z = move_direction.z * speed
	
	if move_direction:
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(velocity.x, velocity.z), LERP_VALUE)
	
	
	var is_jumping := is_on_floor() and Input.is_action_just_pressed("jump")
	
	if is_jumping:
		if not prone == true:
			velocity.y = jump_strength

func movement_animations(delta):
	
	if is_on_floor():
		
		
		if prone == true:
			
			animator.set("parameters/prone_transition/transition_request", "prone_walking")
			animator.set("parameters/movement/transition_request", "prone")
		else:
			if crounching == true:
				animator.set("parameters/Crounching/transition_request", "walking")
			else:
				animator.set("parameters/ground_air_transition/transition_request", "grounded")
					
			
			if crounching == true:
				
				animator.set("parameters/movement/transition_request", "crounching")
			else:
				
				animator.set("parameters/movement/transition_request", "default")
		
		
		
		if velocity.length() > 0:
			if speed == run_speed:
				if prone == true:
					player_status = 'prone_walking'
					animator.set("parameters/prone_movement/blend_amount", lerp(animator.get("parameters/prone_movement/blend_amount"), 0.0, delta * ANIMATION_BLEND))
				else:				
						if crounching == true:
							
							player_status = 'crounching_running'
							animator.set("parameters/crouch_blend/blend_amount", lerp(animator.get("parameters/crouch_blend/blend_amount"), 1.0, delta * ANIMATION_BLEND))
						
						else:
							
							player_status = 'player_running'
							animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 1.0, delta * ANIMATION_BLEND))
			else:
				if prone == true:
					player_status = 'prone_walking'
					animator.set("parameters/prone_movement/blend_amount", lerp(animator.get("parameters/prone_movement/blend_amount"), 1.0, delta * ANIMATION_BLEND))
				else:
						if crounching == true:
							player_status = 'crounching_walking'
							animator.set("parameters/crouch_blend/blend_amount", lerp(animator.get("parameters/crouch_blend/blend_amount"), 0.0, delta * ANIMATION_BLEND))
						else:
							player_status = 'player_walking'
							animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 0.0, delta * ANIMATION_BLEND))
		
		else:
			
			if prone == true:
				
				player_status = 'prone_idle'
				
				animator.set("parameters/prone_movement/blend_amount", lerp(animator.get("parameters/prone_movement/blend_amount"), 0.0, delta * ANIMATION_BLEND))
			
			else:			
				
				if crounching == true:
					
					player_status = 'crounching_idle'
					
					animator.set("parameters/crouch_blend/blend_amount", lerp(animator.get("parameters/crouch_blend/blend_amount"), -1.0, delta * ANIMATION_BLEND))
				
				else:
					
					player_status = 'player_idle'
					
					animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), -1.0, delta * ANIMATION_BLEND))
		
	else:
		
		
		if crounching == true:
			
			if global_position.y > 0.36:
				player_status = 'crounching_jump'
				animator.set("parameters/Crounching/transition_request", "jump")
		else:
			
			if global_position.y <= 0.25:
				if global_position.y > 0.18:
					player_status = 'player_jump'
					animator.set("parameters/ground_air_transition/transition_request", "air")
			if global_position.y > 0.25:
				if global_position.y > 1.0:
					player_status = 'player_jump'
					animator.set("parameters/ground_air_transition/transition_request", "air")
func _sfxSync():
	$sfx.global_position = global_position	

func CollisionsSync():
	
	
	$player_collision.global_rotation = $Armature/Skeleton3D/Animated_collision_hips/Animated_collision_hips.global_rotation
	if prone:
		$player_collision.global_position.y = $Armature/Skeleton3D/Animated_collision_hips/Animated_collision_hips.global_position.y+0.17368
	else:
		if crounching:
			$player_collision.global_position.y = $Armature/Skeleton3D/Animated_collision_hips/Animated_collision_hips.global_position.y-0.08
			$player_collision.global_rotation.x = $player_collision.global_rotation.x*1.48
		else:
			$player_collision.global_position.y = $Armature/Skeleton3D/Animated_collision_hips/Animated_collision_hips.global_position.y-0.138
			
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
