extends CharacterBody3D

const LERP_VALUE : float = 0.15

var snap_vector : Vector3 = Vector3.DOWN
var speed : float

@export_group("Movement variables")
@export var walk_speed : float = 2.0
@export var run_speed : float = 5.0
@export var jump_strength : float = 15.0
@export var gravity : float = 50.0

const ANIMATION_BLEND : float = 7.0

@onready var player_mesh : Node3D = $Armature
@onready var spring_arm_pivot : Node3D = $SpringArmPivot
@onready var animator : AnimationTree = $AnimationTree

func _physics_process(delta):
	CollisionsSync()
	var move_direction : Vector3 = Vector3.ZERO
	move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_direction.z = Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forwards")
	move_direction = move_direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)
	
	velocity.y -= gravity * delta
	
	if Input.is_action_pressed("run"):
		speed = run_speed
	else:
		speed = walk_speed
	
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.z * speed
	
	if move_direction:
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(velocity.x, velocity.z), LERP_VALUE)
	
	var just_landed := is_on_floor() and snap_vector == Vector3.ZERO
	var is_jumping := is_on_floor() and Input.is_action_just_pressed("jump")
	if is_jumping:
		velocity.y = jump_strength
		snap_vector = Vector3.ZERO
	elif just_landed:
		snap_vector = Vector3.DOWN
	
	
	apply_floor_snap()
	move_and_slide()
	animate(delta)

func animate(delta):
	
	if is_on_floor():
		animator.set("parameters/ground_air_transition/transition_request", "grounded")
		
		if velocity.length() > 0:
			if speed == run_speed:
				animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 1.0, delta * ANIMATION_BLEND))
			
			else:
				animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 0.0, delta * ANIMATION_BLEND))
		else:
			animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), -1.0, delta * ANIMATION_BLEND))
	else:
		
		if global_position.y > 1.0:
			animator.set("parameters/ground_air_transition/transition_request", "air")

	
func CollisionsSync():
	
	
	
	if not $Animated_collision_head == null and not $Armature/Skeleton3D/Animated_collision_head/Animated_collision_head == null:
		
		$Animated_collision_head.global_position = $Armature/Skeleton3D/Animated_collision_head/Animated_collision_head.global_position
		
		$Animated_collision_head.global_rotation = $Armature/Skeleton3D/Animated_collision_head/Animated_collision_head.global_rotation
	
	if not $Animated_collision_neck == null and not $Armature/Skeleton3D/Animated_collision_neck/Animated_collision_neck == null: 
		
		$Animated_collision_neck.global_position = $Armature/Skeleton3D/Animated_collision_neck/Animated_collision_neck.global_position
		
		$Animated_collision_neck.global_rotation = $Armature/Skeleton3D/Animated_collision_neck/Animated_collision_neck.global_rotation
	
	if not $Animated_collision_upper_body == null and not $Armature/Skeleton3D/Animated_collision_upper_body/Animated_collision_upper_body == null: 
		
		$Animated_collision_upper_body.global_position = $Armature/Skeleton3D/Animated_collision_upper_body/Animated_collision_upper_body.global_position
		$Animated_collision_upper_body.global_rotation = $Armature/Skeleton3D/Animated_collision_upper_body/Animated_collision_upper_body.global_rotation 
		$Animated_collision_upper_body.global_rotation.z -= deg_to_rad(89.8)
	
	
	if not $Animated_collision_body == null and not $Armature/Skeleton3D/Animated_collision_body/Animated_collision_body == null: 
		$Animated_collision_body.global_position = $Armature/Skeleton3D/Animated_collision_body/Animated_collision_body.global_position
		$Animated_collision_body.global_rotation = $Armature/Skeleton3D/Animated_collision_body/Animated_collision_body.global_rotation
		
	if not $Animated_collision_hips == null and not $Armature/Skeleton3D/Animated_collision_hips/Animated_collision_hips == null: 
		$Animated_collision_hips.global_position = $Armature/Skeleton3D/Animated_collision_hips/Animated_collision_hips.global_position
		$Animated_collision_hips.global_rotation = $Armature/Skeleton3D/Animated_collision_hips/Animated_collision_hips.global_rotation
			
	
	if not $Animated_collision_r_up_leg == null and not $Armature/Skeleton3D/Animated_collision_r_up_leg/Animated_collision_r_up_leg == null: 
		$Animated_collision_r_up_leg.global_position = $Armature/Skeleton3D/Animated_collision_r_up_leg/Animated_collision_r_up_leg.global_position
		$Animated_collision_r_up_leg.global_rotation = $Armature/Skeleton3D/Animated_collision_r_up_leg/Animated_collision_r_up_leg.global_rotation
			
	
	if not $Animated_collision_l_up_leg == null and not $Armature/Skeleton3D/Animated_collision_l_up_leg/Animated_collision_l_up_leg == null: 
		$Animated_collision_l_up_leg.global_position = $Armature/Skeleton3D/Animated_collision_l_up_leg/Animated_collision_l_up_leg.global_position
		$Animated_collision_l_up_leg.global_rotation = $Armature/Skeleton3D/Animated_collision_l_up_leg/Animated_collision_l_up_leg.global_rotation
				
	if not $Animated_collision_r_leg == null and not $Armature/Skeleton3D/Animated_collision_r_leg/Animated_collision_r_leg == null: 
		$Animated_collision_r_leg.global_position = $Armature/Skeleton3D/Animated_collision_r_leg/Animated_collision_r_leg.global_position
		$Animated_collision_r_leg.global_rotation = $Armature/Skeleton3D/Animated_collision_r_leg/Animated_collision_r_leg.global_rotation
				
	if not $Animated_collision_l_leg == null and not $Armature/Skeleton3D/Animated_collision_l_leg/Animated_collision_l_leg == null: 
		$Animated_collision_l_leg.global_position = $Armature/Skeleton3D/Animated_collision_l_leg/Animated_collision_l_leg.global_position
		$Animated_collision_l_leg.global_rotation = $Armature/Skeleton3D/Animated_collision_l_leg/Animated_collision_l_leg.global_rotation
				
	
	if not $Animated_collision_r_foot == null and not $Armature/Skeleton3D/Animated_collision_r_foot/Animated_collision_r_foot == null: 
		$Animated_collision_r_foot.global_position = $Armature/Skeleton3D/Animated_collision_r_foot/Animated_collision_r_foot.global_position
		$Animated_collision_r_foot.global_rotation = $Armature/Skeleton3D/Animated_collision_r_foot/Animated_collision_r_foot.global_rotation
					
	
	if not $Animated_collision_l_foot == null and not $Armature/Skeleton3D/Animated_collision_l_foot/Animated_collision_l_foot == null: 
		$Animated_collision_l_foot.global_position = $Armature/Skeleton3D/Animated_collision_l_foot/Animated_collision_l_foot.global_position
		$Animated_collision_l_foot.global_rotation = $Armature/Skeleton3D/Animated_collision_l_foot/Animated_collision_l_foot.global_rotation
					
	if not $Animated_collision_r_foot_toe == null and not $Armature/Skeleton3D/Animated_collision_r_foot_toe/Animated_collision_r_foot_toe== null: 
		$Animated_collision_r_foot_toe.global_position = $Armature/Skeleton3D/Animated_collision_r_foot_toe/Animated_collision_r_foot_toe.global_position
		$Animated_collision_r_foot_toe.global_rotation = $Armature/Skeleton3D/Animated_collision_r_foot_toe/Animated_collision_r_foot_toe.global_rotation
					
	if not $Animated_collision_l_foot_toe == null and not $Armature/Skeleton3D/Animated_collision_l_foot_toe/Animated_collision_l_foot_toe == null: 
		$Animated_collision_l_foot_toe.global_position = $Armature/Skeleton3D/Animated_collision_l_foot_toe/Animated_collision_l_foot_toe.global_position
		$Animated_collision_l_foot_toe.global_rotation = $Armature/Skeleton3D/Animated_collision_l_foot_toe/Animated_collision_l_foot_toe.global_rotation
				
	if not $Animated_collision_r_upper_arm == null and not $Armature/Skeleton3D/Animated_collision_r_upper_arm/Animated_collision_r_upper_arm == null: 
		$Animated_collision_r_upper_arm.global_position = $Armature/Skeleton3D/Animated_collision_r_upper_arm/Animated_collision_r_upper_arm.global_position
		$Animated_collision_r_upper_arm.global_rotation = $Armature/Skeleton3D/Animated_collision_r_upper_arm/Animated_collision_r_upper_arm.global_rotation
				
	if not $Animated_collision_l_upper_arm == null and not $Armature/Skeleton3D/Animated_collision_l_upper_arm/Animated_collision_l_upper_arm == null: 
		$Animated_collision_l_upper_arm.global_position = $Armature/Skeleton3D/Animated_collision_l_upper_arm/Animated_collision_l_upper_arm.global_position
		$Animated_collision_l_upper_arm.global_rotation = $Armature/Skeleton3D/Animated_collision_l_upper_arm/Animated_collision_l_upper_arm.global_rotation
				
	if not $Animated_collision_r_arm == null and not $Armature/Skeleton3D/Animated_collision_r_arm/Animated_collision_r_arm == null: 
		$Animated_collision_r_arm.global_position = $Armature/Skeleton3D/Animated_collision_r_arm/Animated_collision_r_arm.global_position
		$Animated_collision_r_arm.global_rotation = $Armature/Skeleton3D/Animated_collision_r_arm/Animated_collision_r_arm.global_rotation
				
	if not $Animated_collision_l_arm == null and not $Armature/Skeleton3D/Animated_collision_l_arm/Animated_collision_l_arm == null: 
		$Animated_collision_l_arm.global_position = $Armature/Skeleton3D/Animated_collision_l_arm/Animated_collision_l_arm.global_position
		$Animated_collision_l_arm.global_rotation = $Armature/Skeleton3D/Animated_collision_l_arm/Animated_collision_l_arm.global_rotation
					
	if not $Animated_collision_r_hand == null and not $Armature/Skeleton3D/Animated_collision_r_hand/Animated_collision_r_hand == null: 
		$Animated_collision_r_hand.global_position = $Armature/Skeleton3D/Animated_collision_r_hand/Animated_collision_r_hand.global_position
		$Animated_collision_r_hand.global_rotation = $Armature/Skeleton3D/Animated_collision_r_hand/Animated_collision_r_hand.global_rotation
				
	if not $Animated_collision_l_hand == null and not $Armature/Skeleton3D/Animated_collision_l_hand/Animated_collision_l_hand == null: 
		$Animated_collision_l_hand.global_position = $Armature/Skeleton3D/Animated_collision_l_hand/Animated_collision_l_hand.global_position
		$Animated_collision_l_hand.global_rotation = $Armature/Skeleton3D/Animated_collision_l_hand/Animated_collision_l_hand.global_rotation
								
	if not $Animated_collision_l_pinky1 == null and not $Armature/Skeleton3D/Animated_collision_l_pinky1/Animated_collision_l_pinky1 == null: 
			$Animated_collision_l_pinky1.global_position = $Armature/Skeleton3D/Animated_collision_l_pinky1/Animated_collision_l_pinky1.global_position
			$Animated_collision_l_pinky1.global_rotation = $Armature/Skeleton3D/Animated_collision_l_pinky1/Animated_collision_l_pinky1.global_rotation
									
	if not $Animated_collision_l_pinky2 == null and not $Armature/Skeleton3D/Animated_collision_l_pinky2/Animated_collision_l_pinky2 == null: 
			$Animated_collision_l_pinky2.global_position = $Armature/Skeleton3D/Animated_collision_l_pinky2/Animated_collision_l_pinky2.global_position
			$Animated_collision_l_pinky2.global_rotation = $Armature/Skeleton3D/Animated_collision_l_pinky2/Animated_collision_l_pinky2.global_rotation
																	
	if not $Animated_collision_l_pinky3 == null and not $Armature/Skeleton3D/Animated_collision_l_pinky3/Animated_collision_l_pinky3 == null: 
			$Animated_collision_l_pinky3.global_position = $Armature/Skeleton3D/Animated_collision_l_pinky3/Animated_collision_l_pinky3.global_position
			$Animated_collision_l_pinky3.global_rotation = $Armature/Skeleton3D/Animated_collision_l_pinky3/Animated_collision_l_pinky3.global_rotation

	if not $Animated_collision_l_ring1 == null and not $Armature/Skeleton3D/Animated_collision_l_ring1/Animated_collision_l_ring1 == null: 
			$Animated_collision_l_ring1.global_position = $Armature/Skeleton3D/Animated_collision_l_ring1/Animated_collision_l_ring1.global_position
			$Animated_collision_l_ring1.global_rotation = $Armature/Skeleton3D/Animated_collision_l_ring1/Animated_collision_l_ring1.global_rotation
									
	if not $Animated_collision_l_ring2 == null and not $Armature/Skeleton3D/Animated_collision_l_ring2/Animated_collision_l_ring2 == null: 
			$Animated_collision_l_ring2.global_position = $Armature/Skeleton3D/Animated_collision_l_ring2/Animated_collision_l_ring2.global_position
			$Animated_collision_l_ring2.global_rotation = $Armature/Skeleton3D/Animated_collision_l_ring2/Animated_collision_l_ring2.global_rotation
									
	if not $Animated_collision_l_ring3 == null and not $Armature/Skeleton3D/Animated_collision_l_ring3/Animated_collision_l_ring3 == null: 
			$Animated_collision_l_ring3.global_position = $Armature/Skeleton3D/Animated_collision_l_ring3/Animated_collision_l_ring3.global_position
			$Animated_collision_l_ring3.global_rotation = $Armature/Skeleton3D/Animated_collision_l_ring3/Animated_collision_l_ring3.global_rotation
									
	if not $Animated_collision_l_middle1 == null and not $Armature/Skeleton3D/Animated_collision_l_middle1/Animated_collision_l_middle1 == null: 
			$Animated_collision_l_middle1.global_position = $Armature/Skeleton3D/Animated_collision_l_middle1/Animated_collision_l_middle1.global_position
			$Animated_collision_l_middle1.global_rotation = $Armature/Skeleton3D/Animated_collision_l_middle1/Animated_collision_l_middle1.global_rotation
									
	if not $Animated_collision_l_middle2 == null and not $Armature/Skeleton3D/Animated_collision_l_middle2/Animated_collision_l_middle2 == null: 
			$Animated_collision_l_middle2.global_position = $Armature/Skeleton3D/Animated_collision_l_middle2/Animated_collision_l_middle2.global_position
			$Animated_collision_l_middle2.global_rotation = $Armature/Skeleton3D/Animated_collision_l_middle2/Animated_collision_l_middle2.global_rotation
									
	if not $Animated_collision_l_middle3 == null and not $Armature/Skeleton3D/Animated_collision_l_middle3/Animated_collision_l_middle3 == null: 
			$Animated_collision_l_middle3.global_position = $Armature/Skeleton3D/Animated_collision_l_middle3/Animated_collision_l_middle3.global_position
			$Animated_collision_l_middle3.global_rotation = $Armature/Skeleton3D/Animated_collision_l_middle3/Animated_collision_l_middle3.global_rotation
									
	if not $Animated_collision_l_index1 == null and not $Armature/Skeleton3D/Animated_collision_l_index1/Animated_collision_l_index1 == null: 
			$Animated_collision_l_index1.global_position = $Armature/Skeleton3D/Animated_collision_l_index1/Animated_collision_l_index1.global_position
			$Animated_collision_l_index1.global_rotation = $Armature/Skeleton3D/Animated_collision_l_index1/Animated_collision_l_index1.global_rotation
									
	if not $Animated_collision_l_index2 == null and not $Armature/Skeleton3D/Animated_collision_l_index2/Animated_collision_l_index2 == null: 
			$Animated_collision_l_index2.global_position = $Armature/Skeleton3D/Animated_collision_l_index2/Animated_collision_l_index2.global_position
			$Animated_collision_l_index2.global_rotation = $Armature/Skeleton3D/Animated_collision_l_index2/Animated_collision_l_index2.global_rotation
									
	if not $Animated_collision_l_index3 == null and not $Armature/Skeleton3D/Animated_collision_l_index3/Animated_collision_l_index3 == null: 
			$Animated_collision_l_index3.global_position = $Armature/Skeleton3D/Animated_collision_l_index3/Animated_collision_l_index3.global_position
			$Animated_collision_l_index3.global_rotation = $Armature/Skeleton3D/Animated_collision_l_index3/Animated_collision_l_index3.global_rotation
									
	if not $Animated_collision_l_thumb1 == null and not $Armature/Skeleton3D/Animated_collision_l_thumb1/Animated_collision_l_thumb1 == null: 
			$Animated_collision_l_thumb1.global_position = $Armature/Skeleton3D/Animated_collision_l_thumb1/Animated_collision_l_thumb1.global_position
			$Animated_collision_l_thumb1.global_rotation = $Armature/Skeleton3D/Animated_collision_l_thumb1/Animated_collision_l_thumb1.global_rotation
									
	if not $Animated_collision_l_thumb2 == null and not $Armature/Skeleton3D/Animated_collision_l_thumb2/Animated_collision_l_thumb2 == null: 
			$Animated_collision_l_thumb2.global_position = $Armature/Skeleton3D/Animated_collision_l_thumb2/Animated_collision_l_thumb2.global_position
			$Animated_collision_l_thumb2.global_rotation = $Armature/Skeleton3D/Animated_collision_l_thumb2/Animated_collision_l_thumb2.global_rotation
									
	if not $Animated_collision_l_thumb3 == null and not $Armature/Skeleton3D/Animated_collision_l_thumb3/Animated_collision_l_thumb3 == null: 
			$Animated_collision_l_thumb3.global_position = $Armature/Skeleton3D/Animated_collision_l_thumb3/Animated_collision_l_thumb3.global_position
			$Animated_collision_l_thumb3.global_rotation = $Armature/Skeleton3D/Animated_collision_l_thumb3/Animated_collision_l_thumb3.global_rotation
									
	if not $Animated_collision_r_pinky1 == null and not $Armature/Skeleton3D/Animated_collision_r_pinky1/Animated_collision_r_pinky1 == null: 
			$Animated_collision_r_pinky1.global_position = $Armature/Skeleton3D/Animated_collision_r_pinky1/Animated_collision_r_pinky1.global_position
			$Animated_collision_r_pinky1.global_rotation = $Armature/Skeleton3D/Animated_collision_r_pinky1/Animated_collision_r_pinky1.global_rotation
									
	if not $Animated_collision_r_pinky2 == null and not $Armature/Skeleton3D/Animated_collision_r_pinky2/Animated_collision_r_pinky2 == null: 
			$Animated_collision_r_pinky2.global_position = $Armature/Skeleton3D/Animated_collision_r_pinky2/Animated_collision_r_pinky2.global_position
			$Animated_collision_r_pinky2.global_rotation = $Armature/Skeleton3D/Animated_collision_r_pinky2/Animated_collision_r_pinky2.global_rotation
									
	if not $Animated_collision_r_pinky3 == null and not $Armature/Skeleton3D/Animated_collision_r_pinky3/Animated_collision_r_pinky3 == null: 
			$Animated_collision_r_pinky3.global_position = $Armature/Skeleton3D/Animated_collision_r_pinky3/Animated_collision_r_pinky3.global_position
			$Animated_collision_r_pinky3.global_rotation = $Armature/Skeleton3D/Animated_collision_r_pinky3/Animated_collision_r_pinky3.global_rotation
									
	if not $Animated_collision_r_ring1 == null and not $Armature/Skeleton3D/Animated_collision_r_ring1/Animated_collision_r_ring1 == null: 
			$Animated_collision_r_ring1.global_position = $Armature/Skeleton3D/Animated_collision_r_ring1/Animated_collision_r_ring1.global_position
			$Animated_collision_r_ring1.global_rotation = $Armature/Skeleton3D/Animated_collision_r_ring1/Animated_collision_r_ring1.global_rotation
									
	if not $Animated_collision_r_ring2 == null and not $Armature/Skeleton3D/Animated_collision_r_ring2/Animated_collision_r_ring2 == null: 
			$Animated_collision_r_ring2.global_position = $Armature/Skeleton3D/Animated_collision_r_ring2/Animated_collision_r_ring2.global_position
			$Animated_collision_r_ring2.global_rotation = $Armature/Skeleton3D/Animated_collision_r_ring2/Animated_collision_r_ring2.global_rotation
									
	if not $Animated_collision_r_ring3 == null and not $Armature/Skeleton3D/Animated_collision_r_ring3/Animated_collision_r_ring3 == null: 
			$Animated_collision_r_ring3.global_position = $Armature/Skeleton3D/Animated_collision_r_ring3/Animated_collision_r_ring3.global_position
			$Animated_collision_r_ring3.global_rotation = $Armature/Skeleton3D/Animated_collision_r_ring3/Animated_collision_r_ring3.global_rotation
									
	if not $Animated_collision_r_middle1 == null and not $Armature/Skeleton3D/Animated_collision_r_middle1/Animated_collision_r_middle1 == null: 
			$Animated_collision_r_middle1.global_position = $Armature/Skeleton3D/Animated_collision_r_middle1/Animated_collision_r_middle1.global_position
			$Animated_collision_r_middle1.global_rotation = $Armature/Skeleton3D/Animated_collision_r_middle1/Animated_collision_r_middle1.global_rotation
									
	if not $Animated_collision_r_middle2 == null and not $Armature/Skeleton3D/Animated_collision_r_middle2/Animated_collision_r_middle2 == null: 
			$Animated_collision_r_middle2.global_position = $Armature/Skeleton3D/Animated_collision_r_middle2/Animated_collision_r_middle2.global_position
			$Animated_collision_r_middle2.global_rotation = $Armature/Skeleton3D/Animated_collision_r_middle2/Animated_collision_r_middle2.global_rotation
									
	if not $Animated_collision_r_middle3 == null and not $Armature/Skeleton3D/Animated_collision_r_middle3/Animated_collision_r_middle3 == null: 
			$Animated_collision_r_middle3.global_position = $Armature/Skeleton3D/Animated_collision_r_middle3/Animated_collision_r_middle3.global_position
			$Animated_collision_r_middle3.global_rotation = $Armature/Skeleton3D/Animated_collision_r_middle3/Animated_collision_r_middle3.global_rotation
									
	if not $Animated_collision_r_index1 == null and not $Armature/Skeleton3D/Animated_collision_r_index1/Animated_collision_r_index1 == null: 
			$Animated_collision_r_index1.global_position = $Armature/Skeleton3D/Animated_collision_r_index1/Animated_collision_r_index1.global_position
			$Animated_collision_r_index1.global_rotation = $Armature/Skeleton3D/Animated_collision_r_index1/Animated_collision_r_index1.global_rotation
									
	if not $Animated_collision_r_index2 == null and not $Armature/Skeleton3D/Animated_collision_r_index2/Animated_collision_r_index2 == null: 
			$Animated_collision_r_index2.global_position = $Armature/Skeleton3D/Animated_collision_r_index2/Animated_collision_r_index2.global_position
			$Animated_collision_r_index2.global_rotation = $Armature/Skeleton3D/Animated_collision_r_index2/Animated_collision_r_index2.global_rotation
									
	if not $Animated_collision_r_index3 == null and not $Armature/Skeleton3D/Animated_collision_r_index3/Animated_collision_r_index3 == null: 
			$Animated_collision_r_index3.global_position = $Armature/Skeleton3D/Animated_collision_r_index3/Animated_collision_r_index3.global_position
			$Animated_collision_r_index3.global_rotation = $Armature/Skeleton3D/Animated_collision_r_index3/Animated_collision_r_index3.global_rotation
									
	if not $Animated_collision_r_thumb1 == null and not $Armature/Skeleton3D/Animated_collision_r_thumb1/Animated_collision_r_thumb1 == null: 
			$Animated_collision_r_thumb1.global_position = $Armature/Skeleton3D/Animated_collision_r_thumb1/Animated_collision_r_thumb1.global_position
			$Animated_collision_r_thumb1.global_rotation = $Armature/Skeleton3D/Animated_collision_r_thumb1/Animated_collision_r_thumb1.global_rotation
									
	if not $Animated_collision_r_thumb2 == null and not $Armature/Skeleton3D/Animated_collision_r_thumb2/Animated_collision_r_thumb2 == null: 
			$Animated_collision_r_thumb2.global_position = $Armature/Skeleton3D/Animated_collision_r_thumb2/Animated_collision_r_thumb2.global_position
			$Animated_collision_r_thumb2.global_rotation = $Armature/Skeleton3D/Animated_collision_r_thumb2/Animated_collision_r_thumb2.global_rotation
									
	if not $Animated_collision_r_thumb3 == null and not $Armature/Skeleton3D/Animated_collision_r_thumb3/Animated_collision_r_thumb3 == null: 
			$Animated_collision_r_thumb3.global_position = $Armature/Skeleton3D/Animated_collision_r_thumb3/Animated_collision_r_thumb3.global_position
			$Animated_collision_r_thumb3.global_rotation = $Armature/Skeleton3D/Animated_collision_r_thumb3/Animated_collision_r_thumb3.global_rotation
									
