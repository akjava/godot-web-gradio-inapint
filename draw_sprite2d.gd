extends Control



var points = []
# Called when the node enters the scene tree for the first time.

var image : Image
var image_texture : ImageTexture

var layer : Image
var layer_texture : ImageTexture

var pen_color = Color.BLACK

var pen_texture
var erase_pen_texture
var layer_pen_texture
var base_pen_image = load("res://files/redcircle.png").get_image()
var color_image

var pen_size = 32

var base_texture

var is_erase_mode = false
var is_pick_mode = false

var is_layer_mode = true
var is_smudge_mode = false

var smudge_blend = 0.2
var smudge_factor = 0.95

signal color_picked(color)
func set_pick_mode(mode):
	if mode:
		set_default_cursor_shape(Control.CURSOR_CROSS)
	else:
		if is_erase_mode:
			set_default_cursor_shape(Control.CURSOR_POINTING_HAND)
		else:
			set_default_cursor_shape(Control.CURSOR_ARROW)
	is_pick_mode = mode
func set_erase_mode(mode):
	if mode:
		set_default_cursor_shape(Control.CURSOR_POINTING_HAND)
	else:
		set_default_cursor_shape(Control.CURSOR_ARROW)
		
	is_erase_mode = mode
	update_pen_color(pen_color)
	
func _ready():
	var texture = load("res://files/catman.jpg")
	open_image(texture)
	set_default_cursor_shape(Control.CURSOR_ARROW)
	color_picked.connect(update_pen_color)
	
		
		
		
		
		
	

var opned_texture
func open_image(texture):
	opned_texture = ImageTexture.create_from_image(texture.get_image())
	base_texture = texture
	var image_size = Vector2(base_texture.get_width(),base_texture.get_height())
	print("image size = %s"%[image_size])
	set_size(image_size)
	set_custom_minimum_size(image_size)
	#print(position,size)
	
	#var pen_image = base_circle.get_image()
	#var data = pen_image.save_jpg_to_buffer()
	
	#pen_image.load_jpg_from_buffer(data)
	#print(pen_image)
	
	update_pen_color(pen_color)
	
	
	image = Image.create(base_texture.get_width(), base_texture.get_height(), false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 0))  # 透明で塗りつぶし
	image_texture = ImageTexture.create_from_image(image)
	
	layer = Image.create(base_texture.get_width(), base_texture.get_height(), false, Image.FORMAT_RGBA8)
	layer.fill(Color(1, 1, 1, 0))  # 透明で塗りつぶし
	layer_texture = ImageTexture.create_from_image(layer)
	
	queue_redraw()

func update_pen_size(value):
	pen_size = value
	var resized = Image.new()
	resized.copy_from(color_image)
	resized.resize(pen_size,pen_size) 
	pen_texture = ImageTexture.create_from_image(resized)
	
	var erase_pen_image = resized.duplicate()
	erase_pen_image.fill(Color(0,0,0,0))
	erase_pen_texture = ImageTexture.create_from_image(erase_pen_image)
	
	
	var layer_pen_image = resized.duplicate()
	update_layer_pen_color(layer_pen_image)
	layer_pen_texture = ImageTexture.create_from_image(layer_pen_image)

func update_layer_pen_color(pen_image):
	for x in pen_image.get_width():
			for y in pen_image.get_height():
				var color = pen_image.get_pixel(x,y)
				if color.a !=0:
					var new_color = Color(0.5,0.5,0.5,0.5)
					pen_image.set_pixel(x,y,new_color)
	
func update_pen_color(color):
	#print(color)
	pen_color = color
	color_image = Image.create(64,64,false,Image.FORMAT_RGBA8)
	color_image.copy_from(base_pen_image)
	
	for x in color_image.get_width():
		for y in color_image.get_height():
			var base_color = base_pen_image.get_pixel(x,y)
			var new_color = Color(color*base_color.r,base_color.a)
			color_image.set_pixel(x,y,new_color)
			
	update_pen_size(pen_size)


func is_valid_pos(pos,w,h):
	if pos.x<0:
		return false
	if pos.y<0:
		return false
	if pos.x>=w:
		return false
	if pos.y>=h:
		return false
	return true
func smudge(image,pt,pt2,radius,blend,factor):
	var origin = Image.new()
	origin.copy_from(image)
	var w = origin.get_width()
	var h = origin.get_height()
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			var sample_pos = pt + Vector2(x, y)
			var target_pos = pt2 + Vector2(x, y) * factor
			
			if not is_valid_pos(sample_pos,w,h):
				continue
			if not is_valid_pos(target_pos,w,h):
				continue
			
			
			
			var color = origin.get_pixelv(sample_pos)
			var origin_color = origin.get_pixelv(target_pos)
			image.set_pixelv(target_pos, origin_color.lerp(color,blend))
	origin = null
			
			
func add_point(pt,last_position = null):
	if is_pick_mode:
		return
		
	var half_size = int(pen_size/2)
	
	var target_image 
	var target_texture
	var target_pen
	if  is_layer_mode :
		target_image = layer
		target_texture = layer_texture
		target_pen = layer_pen_texture
	else :
		target_image = image
		target_texture = image_texture
		target_pen = pen_texture
	
	if is_erase_mode:
		layer.blit_rect_mask(erase_pen_texture.get_image(),pen_texture.get_image(), Rect2(Vector2.ZERO, target_pen.get_size()), pt - Vector2(half_size, half_size))	
		image.blit_rect_mask(erase_pen_texture.get_image(),pen_texture.get_image(), Rect2(Vector2.ZERO, target_pen.get_size()), pt - Vector2(half_size, half_size))	
	
	else:
		if is_layer_mode:
			target_image.blit_rect_mask(target_pen.get_image(),target_pen.get_image(), Rect2(Vector2.ZERO, target_pen.get_size()), pt - Vector2(half_size, half_size))
		else:
			var smudge_image = base_texture.get_image()
			# minimu work,
			if is_smudge_mode:
				if last_position!=null:
					smudge(smudge_image,last_position,pt,pen_size,smudge_blend,smudge_factor)
					base_texture = ImageTexture.create_from_image((smudge_image))
			else:
				target_image.blend_rect(target_pen.get_image(), Rect2(Vector2.ZERO, target_pen.get_size()), pt - Vector2(half_size, half_size))
	
	#image.save_jpg("tmp.jpg")
	if is_erase_mode:
		layer_texture.update(layer)
		image_texture.update(image)
	else:
		target_texture.update(target_image)  # テクスチャを更新
	#texture = ImageTexture.create_from_image(image)
	queue_redraw()
	#points.append(pt)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _draw():
	draw_texture(base_texture,Vector2.ZERO)
	draw_texture(layer_texture,Vector2.ZERO)
	draw_texture(image_texture,Vector2.ZERO)
	#texture = get_viewport().get_texture()
	
func get_composite_image():
	# TODO fix same input size
	var img = self.get_viewport().get_texture().get_image()
	# Crop the image so we only have canvas area.
	#print(position,size)
	#print(self.position,self.size)
	var rect = Rect2(self.position, self.size)
	var cropped_image = img.get_region(rect)
	#return cropped_image
	var layer1 = base_texture.get_image().duplicate()
	layer1.convert(image.get_format())
	
	
	layer1.blend_rect(image,Rect2(Vector2.ZERO, image.get_size()),Vector2.ZERO)
	return layer1
	

var base_color_min_alpha = 0.8	
func get_mask_image():
	var img = Image.create(image.get_width(),image.get_height(),false,Image.FORMAT_RGB8)
	#print(image.get_width(),",",image.get_height())
	#return
	for x in image.get_width():
			for y in image.get_height():
				var base_color = image.get_pixel(x,y)
				var layer_color = layer.get_pixel(x,y)
				
				var new_color = Color(base_color.a,base_color.a,base_color.a,base_color.a)
				if layer_color.a != 0:
				#if base_color.a < base_color_min_alpha and layer_color.a != 0:
					new_color = Color(1,1,1,layer_color.a)
				img.set_pixel(x,y,new_color)
	return img
