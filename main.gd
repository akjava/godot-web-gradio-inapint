extends Node2D

# broken,maybe remove next release
var _my_js_callback = JavaScriptBridge.create_callback(myCallback) # This reference must be kept
# keep this one global
var _my_js_callback3 = JavaScriptBridge.create_callback(myCallback3)

# very helpful
var console = JavaScriptBridge.get_interface("console")
# Called when the node enters the scene tree for the first time.
func _ready():
	find_child("UrlLineEdit").text = " http://localhost:7861"
	http_request = HTTPRequest.new()
	add_child(http_request)
	#print(JavaScriptBridge.get_interface("Window"))
	#print(JavaScriptBridge.get_interface("Window").console)
	pass # Replace with function body.

# args is always array even 1 value return
func myCallback(args):
	console.log(args)
	#print(len(args))	#Godot array return 1
	#print(args[0])	# javascriptobject {}
	#var json_string = 
	var json_object = args[0]
	#print(JSON.stringify(json_object))
	var result_text = (json_object["data"][0])
	find_child("AddButton").disabled = false
	find_child("ResultTextEdit").text = result_text
	#print(json_string)
	#var parse_result = JSON.parse_string(json_string)
	#print(parse_result)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
var http_request
func _process(delta):	 
	pass


	
func _on_add_button_pressed():
	
	find_child("AddButton").disabled = true
	
	var body = ""
	
	
	var url = find_child("UrlLineEdit").text
	
	#url = "https://a86351367d79a3da22.gradio.live"
	
	
	var client = JavaScriptBridge.get_interface("Client")
	#client.finished(callback)
	# https://huggingface.co/spaces/Akjava/qwen2-05b
	# need Error: There is no endpoint matching that name of fn_index matching that number.
	# async action
	var text = find_child("InputLineEdit").text
	# for cancel https://www.gradio.app/docs/js-client#client
	var submission = client.connect2(client,url,text,_my_js_callback)
	
	
	#print(result)
	#print(result.data[0])
	#console.log(result)
	
	#var app = w.Client.connect("abidlabs/whisper")
	#await get_tree().create_timer(10.0).timeout
	#var value = app.view_api()
	#await get_tree().create_timer(2.0).timeout
	#print(value)
	#w.alert("hello")
	
	#var app = client.connect2("abidlabs/whisper")
	#print(app)
	#print(app.predict("hello"))
	#var app = client.call("connect","huggingface-projects/gemma-2-2b-it")
	#print(app)
	return ""
	
	var error = http_request.request(url, ["Content-Type: application/html"], HTTPClient.METHOD_GET, body)
	if error != OK:
		push_error("requested but error happen code = %s"%error)
		return
	var res = await http_request.request_completed
	var response = _get_response_text(res[0],res[1],res[2],res[3])
	find_child("ResultTextEdit").text = response

func _get_response_text(result, responseCode, headers, body):
	print("result = %s"%result)
	print("responseCode = %s"%responseCode)
	print("headers = %s"%headers)
	var body_text = body.get_string_from_utf8()
	print("body = %s"% body_text)
	return body_text
	
	var json = JSON.new()
	#json.parse()
	var response = json.get_data()
	print("#### response")
	print(response)
	
	if response == null:
		print("response is null")
		find_child("FinishedLabel").text = "No Response"
		find_child("FinishedLabel").visible = true
		return
	
	
	
	if response.has("error"):
		find_child("FinishedLabel").text = "ERROR"
		find_child("FinishedLabel").visible = true
		find_child("ResponseEdit").text = str(response.error)
		#maybe blocked
		return
	
	#No Answer
	if !response.has("choices"):
		find_child("FinishedLabel").text = "No Choices"
		find_child("FinishedLabel").visible = true
		find_child("ResponseEdit").text = ""
		#maybe blocked
		return
		
	#I can not talk about
	if response.choices[0].finish_reason != "stop":
		find_child("FinishedLabel").text = response.choices[0].finish_reason
		find_child("FinishedLabel").visible = true
		find_child("ResponseEdit").text = ""
	else:
		find_child("FinishedLabel").text = ""
		find_child("FinishedLabel").visible = false
		var newStr = response.choices[0].message.content
		return newStr


func _on_button_1_pressed():
	var image =get_viewport().get_texture().get_image()
	#print(image)
	#print(image.save_jpg_to_buffer())
	var client = JavaScriptBridge.get_interface("Client")
	console.log(client)	#client undefined
	var buffer = image.save_jpg_to_buffer()
	#buffer = PackedByteArray()
	#buffer.append(0)
	#buffer.append(1)
	#print(buffer)
	var byteArrayAsArray = []
	for byte in buffer:
		byteArrayAsArray.append(byte)
	
	#var args =  ["ArrayBuffer"] + byteArrayAsArray
	var args =  ["Array"] + byteArrayAsArray
	# TODO benchmark
	var array =JavaScriptBridge.callv("create_object",args)
	#var uint8arr =JavaScriptBridge.create_object("Uint8Array",array_buffer)
	#print(array_buffer)
	#var arr = JavaScriptBridge.create_object("Array", buffer)
	#var uint8arr = JavaScriptBridge.create_object("Uint8Array", buffer) # new Uint8Array(buf)
	
	#print(uint8arr)
	
	# array faild
	client.test1(array,_my_js_callback3)
	
	#client.test1(uint8arr)
	
func myCallback3(values):
	print("myCallback2")
	print(values)
	
	var args = values
	
	console.log(args[0])
	var url = args[0]
	var image = await _create_image_from_url(url)
	var texture = ImageTexture.create_from_image(image)#
	find_child("TextureRect").texture = texture
	
func _get_response_image(result, responseCode, headers, body):
	print("_get_response_image")
	print("result = %s"%result)
	print("responseCode = %s"%responseCode)
	print("headers = %s"%headers)
	var image = Image.new()
	image.load_webp_from_buffer(body)
	print("format=%s w=%s h=%s"%[image.get_format(),image.get_width(),image.get_height()])
	image.resize(64,64)
	return image
	
func _create_image_from_url(url):
	var error = http_request.request(url)
	if error!=OK:
		print("error %s"%error)
	var res = await http_request.request_completed
	var response = _get_response_image(res[0],res[1],res[2],res[3])
	return response
	
