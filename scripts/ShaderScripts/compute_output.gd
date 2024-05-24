extends TextureRect

var imageSize : Vector2i

func textureInit():
	var img = Image.create(imageSize.x, imageSize.y, false, Image.FORMAT_RGBAF)
	var imgTex = ImageTexture.create_from_image(img)
	texture = imgTex

func setData(data:PackedByteArray):
	var newImg := Image.create_from_data(imageSize.x, imageSize.y, false, Image.FORMAT_RGBAF, data)
	texture.update(newImg)
