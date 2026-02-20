extends Node

#these signals are called as: GlobalPlayer.jumped
signal landed(collider) #collider is whatever object it collided with
signal jumped

signal climbEntr(ladder) #ladder is the ladder emitting
