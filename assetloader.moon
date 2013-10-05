export class AssetLoader
  new: (@config) =>
    @IMAGES = {}
    @TEXTURES = {}
    @FONTS = {}
    @STYLES = {}
    @OVERLAYS = {}

  load: (@onLoadComplete) =>
    -- Load images

    if @config.images != nil
      images = @config.images
      for k, v in pairs(images)
        @IMAGES[k] = MOAIImage.new()
        @IMAGES[k]\load(v, MOAIImage.PREMULTIPLY_ALPHA)

    -- Load textures
    if @config.textures != nil
      textures = @config.textures
      for k, v in pairs(textures)
        @TEXTURES[k] = MOAITexture.new()
        @TEXTURES[k]\load(v, MOAIImage.PREMULTIPLY_ALPHA)

    -- Load fonts
    if @config.fonts  != nil
      fonts = @config.fonts
      for k, v in pairs(fonts)
        @FONTS[k] = MOAIFont.new()
        @FONTS[k]\load(v.location)
        @FONTS[k]\preloadGlyphs(v.glyphs, v.size)

        @STYLES[k] = MOAITextStyle.new()
        @STYLES[k]\setFont @FONTS[k]
        @STYLES[k]\setSize v.size

    -- Load overlays
    print "check for config.overlays"
    print @config.overlays
    if @config.overlays != nil
      overlays = @config.overlays
      print "overlays #{overlays}"
      for k, v in pairs(overlays)
        @OVERLAYS[k] = {}
        @OVERLAYS[k]["TEXT"] = v["TEXT"]
        @OVERLAYS[k]["TEXTURE"] = @TEXTURES[v["TEXTURE"]]
        @OVERLAYS[k]["EVENT"] = v["EVENT"]

    @onLoadComplete!

  destroy: () =>
    -- TODO waarschijnlijk moet dit nog wat beter
    @TEXTURES = nil
    @IMAGES = nil
    @FONTS = nil