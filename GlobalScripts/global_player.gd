extends Node

#these signals are called as: global_player.jumped
signal landed(collider) #collider is whatever object it collided with
signal jumped
signal fellToDeath
