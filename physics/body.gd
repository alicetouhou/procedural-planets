extends Node3D
class_name Planet

@export var inital_vel: Vector3 = Vector3()
@export var mass: int = 10 # Can tweak gravitational constant to improve this

@export var manager: BodyManager

var velocity = Vector3()

func _ready():
	velocity = inital_vel
	manager.add_body(self)

func _physics_process(delta):
	position += velocity * delta

	var acceleration = Vector3()
	for body in manager.bodies:
		if body == self:
			continue
		acceleration += position.direction_to(body.position) * manager.G * body.mass / (position.distance_to(body.position) ** 2)
	
	velocity += acceleration * delta
