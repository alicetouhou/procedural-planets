extends Node3D
class_name BodyManager

const G = 1

var bodies: Array[Planet] = []

func add_body(body: Planet) -> void:
    bodies.append(body)
