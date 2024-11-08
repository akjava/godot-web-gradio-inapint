extends Node2D
#broken maybe remove next release
# Javascript interfaces
var js_console
var js_window
var js_hugging
var _js_callback = JavaScriptBridge.create_callback(_godot_callback)


func _ready():
	var os_name = OS.get_name()
	if os_name == "Web":
		# initialize js objects
		js_window = JavaScriptBridge.get_interface("window")
		js_console = JavaScriptBridge.get_interface("console")
		js_hugging = JavaScriptBridge.get_interface("GHugging")
		_get_oauth()
		
	else:
		find_child("TextEdit").text = "This Demo for Web"
	
	
	#console.log(JavaScriptBridge.get_interface("signin_huggingface"))
	#window.signin_huggingface()

func _godot_callback(values):
	print("godot_callback")
	print(values)
	var value = values[0]
	var text = str(value)
	if text == "false": #check false freeze ,TODO bug report
		print("not sign in")
		return
		
	js_console.log(value)
	var dict = value
	#print(dict.accessToken)
	#print(dict["accessToken"])
	find_child("TextEdit").text = dict.accessToken

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_button_pressed():
	pass # Replace with function body.
	
func _get_oauth():
	js_hugging.get_huggingface_oauth(_js_callback)


func _on_sign_in_button_pressed():
	js_hugging.signin_huggingface()


func _on_sign_out_button_pressed():
	js_hugging.signout_huggingface()
