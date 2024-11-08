extends Control

var server_port = 8000

var drawing = false
var brush_size = 10
var brush_color = Color(1, 0, 0, 1)  # 赤色のブラシ
var shared_image
@onready var canvas = find_child("Canvas")
var pen_size = 32

var http_request


var js_console
var js_window
var js_hugging
var _js_outh_callback = JavaScriptBridge.create_callback(_godot_outh_callback)

var hf_token = "" # get token via in ghugging.js # but broken now

@onready var scroll_container = find_child("ScrollContainer")
var is_web_os = false
func _ready():
	var os_name = OS.get_name()
	if os_name == "Web":
		is_web_os = true
		# initialize js objects
		js_window = JavaScriptBridge.get_interface("window")
		js_console = JavaScriptBridge.get_interface("console")
		js_hugging = JavaScriptBridge.get_interface("GHugging") #broken
		_get_oauth()
	
	# for bug confirm
	#print(find_child("TabContainer").current_tab)
	find_child("TabContainer").current_tab = 2 #BUG
	
	get_viewport().files_dropped.connect(on_files_dropped)
	http_request = HTTPRequest.new()
	add_child(http_request)
	
	#base_circle=ImageTexture.create_from_image(base_circle).get_image()
	#print(base_circle.get_format())
	#base_circle.decompress()
	#find_child("TextureRect").texture = base_circle
	
	
	
	
	shared_image = Image.create(512, 512, false, Image.FORMAT_RGBA8)
	shared_image.fill(Color(1, 1, 1, 1))  # 白で塗りつぶす
	var pos = Vector2(50,50)
	#shared_image.blend_rect(base_circle,base_rect,Vector2(0,0))
	
	var texture = ImageTexture.create_from_image(shared_image)
	canvas.color_picked.connect(_color_picked)
	#$Sprite2D.texture = texture
	var color_picker_button = find_child("ColorPickerButton")
	color_picker_button.get_picker().set_modes_visible(false)
	color_picker_button.get_picker().set_edit_alpha(false)
	color_picker_button.get_picker().set_hex_visible (false)
	color_picker_button.get_picker().set_presets_visible  (false)
	color_picker_button.get_picker().set_sampler_visible   (false)
	color_picker_button.get_picker().set_sliders_visible   (false)
	color_picker_button.picker_created.connect(_created)
	color_picker_button.popup_closed.connect(_closed)
	
	# setup buttons
	_setup_color_buttons()

func _setup_color_buttons():
	var colors = [Color.BLACK,Color("#888"),Color.WHITE,Color.RED,Color.GREEN,Color.BLUE,Color.BISQUE]
	var container = find_child("ColorButtons")
	for color in colors:
		var bt = Button.new()
		bt.set_custom_minimum_size(Vector2i(32,32))
		var style = StyleBoxFlat.new()
		style.bg_color = color # RGB値で緑色を指定
		bt.add_theme_stylebox_override("normal", style)
		bt.add_theme_stylebox_override("hover",style)
		#bt.modulate = color
		bt.pressed.connect(_click_color.bind(color))
		container.add_child(bt)
	
func _click_color(color):
	#_color_picked(color)
	_on_pen_button_pressed()
	canvas.update_pen_color(color)
	#_on_color_picker_button_color_changed(color)
	
	
	
func _created():
	print("create")
	
func _closed():
	var color = find_child("ColorPickerButton").color
	_on_pen_button_pressed()
	canvas.update_pen_color(color)
	#opend = false
func _get_oauth():
	js_hugging.get_huggingface_oauth(_js_outh_callback)
	
func _godot_outh_callback(values):
	print("godot_callback")
	#print(values)
	var value = values[0]
	var text = str(value)
	if text == "false": #check false freeze ,TODO bug report
		print("not sign in")
		find_child("SignInButton").disabled = false
		find_child("SignOutButton").disabled = true
		return
	else:
		find_child("SignInButton").disabled = true
		find_child("SignOutButton").disabled = false
		
	
	var dict = value
	
	hf_token = dict.accessToken
	
		

func _color_picked(color):
	find_child("ColorPickerButton").color = color
	#print($Sprite2D)
func on_files_dropped(files):
	for file in files:
		if file.ends_with(".jpg"):
			var datas = FileAccess.get_file_as_bytes(file)
			var image = Image.new()
			var error =image.load_jpg_from_buffer(datas)
			if error!=0:
				push_error("invalid jpeg: code=%s"%error)
			image = _fit_image(image)
			open_image(ImageTexture.create_from_image(image))
		elif file.ends_with(".png"):
			var datas = FileAccess.get_file_as_bytes(file)
			var image = Image.new()
			var error =image.load_png_from_buffer(datas)
			if error!=0:
				push_error("invalid png: code=%s"%error)
			
			image = _fit_image(image)
			open_image(ImageTexture.create_from_image(image))
		elif file.ends_with(".webp"):
			var datas = FileAccess.get_file_as_bytes(file)
			var image = Image.new()
			var error =image.load_webp_from_buffer(datas)
			if error!=0:
				push_error("invalid png: code=%s"%error)
			image = _fit_image(image)
			open_image(ImageTexture.create_from_image(image))
			
func _fit_image(image):
	# TODO keep aspect
	
	#image.resize(512,512)
	
	if image.get_format()!=Image.FORMAT_RGB8:
		print("convert from %s to RGB8"%[image.get_format()])
		image.convert(Image.FORMAT_RGB8)
	return image
		
var last_position = null

func _global_to_local(pos):
	var h_scroll = scroll_container.get_h_scroll()
	var v_scroll = scroll_container.get_v_scroll()
	return pos-canvas.global_position#+Vector2(h_scroll,v_scroll)
	
func _input(event):

				
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if canvas.is_pick_mode:
				var click_pos = _global_to_local(event.position)
				if click_pos.x < 0 or click_pos.y <0:
					return
				var color = canvas.base_texture.get_image().get_pixel(click_pos.x,click_pos.y)
				canvas.emit_signal("color_picked",color)
				drawing = false
			else:
				drawing = false
				if event.pressed:
					var rect = canvas.get_global_rect()
					if rect.has_point(event.position):
						drawing = true
				
				last_position = null
			
			
			
	elif event is InputEventMouseMotion:
		if drawing:
			var local_position = _global_to_local(event.position)
			#print("%s to %s"%[event.position,local_position])
			if last_position == null:
				paint(local_position)
			else:
				var pos = local_position
				var distance = last_position.distance_to(pos)
				
				var pen_size = canvas.pen_size/2
				#print("distance = %s pen_size=%s"%[distance,pen_size])
				var div = int(distance)/pen_size
				if div > 0:
					#print(div)
					var sp = 1.0/(div+1)
					for i in range(div):
						#print("lear %s"%i)
						var lerp_point = last_position.lerp(pos,(i+1)*sp)
						paint(lerp_point)
				paint(local_position,last_position)
			last_position = local_position
	


func paint(position,last_position=null):
	#print(position)
	#shared_image.blend_rect(base_circle,base_rect,position - Vector2(half_size,half_size))
	
	#print("position %s"%position)
	#useless
	#var local_position = (canvas.get_global_transform_with_canvas().affine_inverse() * position)
	#print("position local %s"%local_position)
	canvas.add_point(position,last_position)
	canvas.queue_redraw()
	

func _on_color_picker_button_color_changed(color):
	#find_child("ColorPickerButton").get_popup().visible = false
	_on_pen_button_pressed()
	canvas.update_pen_color(color)
	


func _on_h_slider_value_changed(value):
	canvas.update_pen_size(value)


func _on_erase_button_pressed():
	canvas.set_erase_mode(true)
	canvas.set_pick_mode(false)


func _on_pen_button_pressed():
	canvas.set_erase_mode(false)
	canvas.set_pick_mode(false)
	canvas.is_layer_mode = false
	canvas.is_smudge_mode = false

func open_image(image):
	find_child("OutputTextureRect1").set_texture(null)
	find_child("OutputTextureRect2").set_texture(null)
	canvas.open_image(image)

var mask_image
var composite_image
var inpaint_image
func _on_submit_button_pressed():
	
		
	find_child("SubmitButton").disabled = true
	find_child("ErrorLineEdit").visible = false
	
	var base_image = Image.new()
	base_image.copy_from(canvas.opned_texture.get_image())
	
	composite_image = canvas.get_composite_image()
	

	mask_image = canvas.get_mask_image()
	
	var option:OptionButton =find_child("UrlOptionButton")
	var id = option.get_selected_id()
	if id == 0:
		find_child("SubmitButton").disabled = false
		find_child("ErrorLineEdit").visible = false
		open_image(ImageTexture.create_from_image(composite_image))
		find_child("OutputTextureRect2").set_texture(ImageTexture.create_from_image(mask_image))
		var texture = ImageTexture.create_from_image(base_image)#
		find_child("OutputTextureRect3").texture = texture
		find_child("OutputTextureRect1").set_texture(ImageTexture.create_from_image(composite_image))
	
		inpaint_image = base_image
		return
	else:
		find_child("OutputTextureRect2").set_texture(ImageTexture.create_from_image(mask_image))
		find_child("OutputTextureRect1").set_texture(ImageTexture.create_from_image(composite_image))
		
	if not is_web_os:
		OS.shell_open("http://localhost:%s"%[server_port])
	else:
		_send_gradio()

func _on_download_1_button_pressed():
	JavaScriptBridge.download_buffer(composite_image.save_jpg_to_buffer(0.85), "composite.jpg")


func _on_download_2_button_pressed():
	JavaScriptBridge.download_buffer(mask_image.save_jpg_to_buffer(0.85), "mask.jpg")



func _on_pick_button_pressed():
	canvas.set_erase_mode(false)
	canvas.set_pick_mode(true)


func _on_download_3_button_pressed():
	JavaScriptBridge.download_buffer(inpaint_image.save_jpg_to_buffer(0.85), "inpainted.jpg")


var _js_callback = JavaScriptBridge.create_callback(_godot_callback)
var console = JavaScriptBridge.get_interface("console")

func _godot_callback(values):
	find_child("SubmitButton").disabled = false
	print("godot_callback")
	print(values)
	
	var args = values
	console.log("size of godot callback = %s"%args.size())
	
	console.log(args[0])
	# possible value null error message
	var url_or_error_message = "" if args[0] == null  else args[0].strip_escapes()
	
	#print((int)url_or_error_message[0])
	if _is_image_url(url_or_error_message):
		var iteration = 5
		for i in range(iteration):
			inpaint_image = await _create_image_from_url(url_or_error_message)
			if inpaint_image!=null:
				break
			else:
				print("retry waiting")
				await get_tree().create_timer(3.0).timeout
		var texture = ImageTexture.create_from_image(inpaint_image)#
		find_child("OutputTextureRect3").texture = texture
	else:
		print("error message='%s'"%url_or_error_message)
		find_child("ErrorLineEdit").visible = true
		find_child("ErrorLineEdit").text = url_or_error_message
	
	
		
	
func _is_image_url(url:String):
	return url.begins_with("http") #web export not check grammer at all
	
func get_inpaint_strength():
	return find_child("InpaintStrengthSlider").value
	
func _send_gradio():
	# seems work without token?
	#if hf_token == "":
	#	print("need sign in for submit")
	#	return
		
	var client = JavaScriptBridge.get_interface("Client")
	console.log(client)	#client undefined
	
	
	#var uint8arr =JavaScriptBridge.create_object("Uint8Array",array_buffer)
	#print(array_buffer)
	#var arr = JavaScriptBridge.create_object("Array", buffer)
	#var uint8arr = JavaScriptBridge.create_object("Uint8Array", buffer) # new Uint8Array(buf)
	
	#print(uint8arr)
	
	var dict = JavaScriptBridge.create_object("Object")
	console.log(dict)
	dict.image = image_to_js_array(composite_image)
	dict.mask = image_to_js_array(mask_image)
	console.log(dict)
	
	var url = _get_connect_url()
	if url == "":
		print("no url")
		return
	var prompt = find_child("PromptLineEdit").text
	var strength = get_inpaint_strength()
	client.send_image_dict(url,hf_token,prompt,dict,strength,_js_callback)
	
		

func _get_connect_url():
	var option:OptionButton =find_child("UrlOptionButton")
	var text = option.get_item_text(option.get_selected_id())
	return text
	
func image_to_js_array(image):	
	var buffer = image.save_jpg_to_buffer()
	#var byteArrayAsArray = []
	
	
		#byteArrayAsArray.append(byte)
	#var args =  ["Array"] + byteArrayAsArray
	# TODO benchmark
	var array =JavaScriptBridge.create_object( "Array")
	for byte in buffer:
		array.push(byte)
	return array
	
# TODO make class
func _create_image_from_url(url):
	var authorization = "Authorization: Bearer %s"%hf_token
	print("create image from url au=%s"%[authorization])
	var error = http_request.request(url,[authorization],HTTPClient.METHOD_GET)
	
	#var error = http_request.request(url)
	
	
	if error!=OK:
		print("error %s"%error)
	var res = await http_request.request_completed
	if res[1]!=200:
		return null
	var response = _get_response_image(res[0],res[1],res[2],res[3],url)
	return response

func _get_response_image(result, responseCode, headers, body,url):
	var extension = url.get_extension().to_lower()
	print("_get_response_image")
	print("result = %s"%result)
	print("responseCode = %s"%responseCode)
	print("headers = %s"%headers)
	var image = Image.new()
	if extension == "webp":
		image.load_webp_from_buffer(body)
	elif extension == "png":
		image.load_png_from_buffer(body)
	elif extension =="jpg" or extension == "jpeg":
		image.load_jpg_from_buffer(body)
	else:
		console.log("not supported image format:%s"%extension)
	print("format=%s w=%s h=%s"%[image.get_format(),image.get_width(),image.get_height()])
	#image.resize(64,64)
	return image

func _on_sign_in_button_pressed():
	js_hugging.signin_huggingface()


func _on_sign_out_button_pressed():
	js_hugging.signout_huggingface()

var opend = false
func _on_color_picker_button_pressed() -> void:
	
	if opend:
		find_child("ColorPickerButton").get_popup().hide()
		opend=false
	else:
		opend=true
	#if find_child("ColorPickerButton").get_popup().popup_window:
	#	


func _on_copy_to_base_button_pressed() -> void:
	if inpaint_image == null:
		return
	open_image(ImageTexture.create_from_image(inpaint_image))


func _on_prompt_line_edit_text_changed(new_text: String) -> void:
	find_child("SubmitButton").disabled = (new_text == "")


func _on_layer_button_pressed() -> void:
	_on_pen_button_pressed()
	canvas.is_layer_mode = true


func _on_blend_smudge_slider_value_changed(value: float) -> void:
	canvas.smudge_blend = value


func _on_factor_smudge_slider_value_changed(value: float) -> void:
	canvas.smudge_factor = value


func _on_smudge_button_pressed() -> void:
	_on_pen_button_pressed()
	canvas.is_smudge_mode = true


func _on_github_button_pressed() -> void:
	OS.shell_open("https://github.com/akjava/godot-web-gradio-inapint")
