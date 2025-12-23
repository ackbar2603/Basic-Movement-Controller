extends CharacterBody3D

#region @ready variables
@onready var _head: Node3D = $Head
@onready var _stdCollision: CollisionShape3D = $StdCollision
@onready var _crhCollision: CollisionShape3D =$CrhCollision
@onready var _rayCast3D: RayCast3D = $RayCast3D
#endregion
#region debug
var _crouchDepth = -0.5
var _jumpVel = 3.5
var _lerpSpeed = 10
var _direction = Vector3.ZERO
#endregion
#region Speed variables
var _mainspeed = 4.0
const _walkSpeed = 4.0
const _sprintSpeed = 5.5
const _crouchSpeed = 3.0
#endregion
#region camera variables
var _mouseInput : bool = false			#check mouse movement
var _rotationInput : float				#X rotation
var _tiltInput : float					#Y rotation
#endregion
#region Rotation Variables
var _mouseRotation : Vector3
var _playerRotation : Vector3
var _cameraRotation : Vector3
#endregion
#region Export Variables
@export var _mouseSensitivity = 0.1				#Mouse sens
@export var _tiltUpperLimit = deg_to_rad(89)	#Upper tilt limit
@export var _tiltLowerLimit = deg_to_rad(-89)	#Lower tilt limit
@export var _cameraController = Camera3D		#Assigned camera3D in the properties
#endregion

#region testing
@export_group("headbob")
@export var headbob_freq := 2.0
@export var headbob_ampl := 0.04
var headbob_time := 0.0
#endregion

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func headbob(headbob_time):
	var headbob_position = Vector3.ZERO
	headbob_position.y = sin(headbob_time * headbob_freq) * headbob_ampl
	headbob_position.x = sin(headbob_time * headbob_freq / 2) * headbob_ampl
	return headbob_position

func _unhandled_input(event: InputEvent) -> void:
	_mouseInput = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	
	if _mouseInput:
		_rotationInput = -event.relative.x * _mouseSensitivity			#X rotation
		_tiltInput = -event.relative.y * _mouseSensitivity				#Y rotation

func update_camera(delta) -> void:
	#region Rotate camera using euler rotation
	_mouseRotation.x += _tiltInput * delta
	_mouseRotation.x = clamp(_mouseRotation.x, _tiltLowerLimit, _tiltUpperLimit)
	_mouseRotation.y += _rotationInput * delta
	#endregion
	#region Camera rotation
	_playerRotation = Vector3(0.0, _mouseRotation.y, 0.0)
	_cameraRotation = Vector3( _mouseRotation.x, 0.0, 0.0)
	#endregion
	#region Camera transform
	_cameraController.transform.basis = Basis.from_euler(_cameraRotation)
	global_transform.basis = Basis.from_euler(_playerRotation)
	#Debug
	_cameraController.rotation.z = 0.0
	#endregion
	#region Restart input of rotation and tilt
	_rotationInput = 0.0
	_tiltInput = 0.0
	#endregion

func _physics_process(delta: float) -> void:
	update_camera(delta)
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	#region Crouch and sprint
	if Input.is_action_pressed("crouch") and is_on_floor():
		_mainspeed = _crouchSpeed
		_head.position.y = lerp(_head.position.y, 1.8 + _crouchDepth, delta * _lerpSpeed)
		#Boolean crouching
		_stdCollision.disabled = true
		_crhCollision.disabled = false
	elif !_rayCast3D.is_colliding():
		_stdCollision.disabled = false
		_crhCollision.disabled = true
		
		#sprint
		_head.position.y = lerp(_head.position.y, 1.8, delta * _lerpSpeed)
		if Input.is_action_pressed("sprint"):
			_mainspeed = _sprintSpeed
		else:
			_mainspeed = _walkSpeed
	#endregion
	#region Jump
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = _jumpVel
	#endregion
		#region headbob
	headbob_time += delta * velocity.length() * float(is_on_floor())
	$Head/Camera3D.transform.origin = headbob(headbob_time)
	#endregion
	#region Movement basic
		# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var _inputDir = Input.get_vector("left", "right", "forward", "backward")
	_direction = lerp(_direction,(transform.basis * Vector3(_inputDir.x, 0, _inputDir.y)).normalized(),_lerpSpeed * delta)
	#movement
	if _direction:
		velocity.x = _direction.x * _mainspeed
		velocity.z = _direction.z * _mainspeed
	else:
		velocity.x = move_toward(velocity.x, 0, _mainspeed)
		velocity.z = move_toward(velocity.z, 0, _mainspeed)
	
	move_and_slide()
	#endregion
