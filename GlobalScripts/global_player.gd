extends Node

#these signals are called as: GlobalPlayer.jumped
signal landed(collider) #collider is whatever object it collided with
signal jumped
signal fellToDeath

signal climbEntr(ladder) #ladder is the ladder emitting
signal climbLeave(ladder) #ladder is the ladder emitting

signal monsterGotPlayer()
