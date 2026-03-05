class_name RunUiPayload
extends RefCounted

var phase: int = -1
var title: String = ""
var body: String = ""
var subtitle: String = ""
var hint: String = ""
var footer: String = ""
var choices: Array[String] = []
var show_push_your_luck: bool = false
var show_mid_choice: bool = false
var meta: Dictionary = {}
