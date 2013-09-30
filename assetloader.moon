export class AssetLoader
  new: (@config) =>
    @IMAGES = {}
    @TEXTURES = {}
    @FONTS = {}
    @STYLES = {}

  load: (@onLoadComplete) =>
    -- Load images

    if @config.images != nil
      images = @config.images
      for k, v in pairs(images)
        @IMAGES[k] = MOAIImage.new()
        @IMAGES[k]\load(v)

    -- Load textures
    if @config.textures != nil
      textures = @config.textures
      for k, v in pairs(textures)
        @TEXTURES[k] = MOAITexture.new()
        @TEXTURES[k]\load(v)

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

    @onLoadComplete!

  destroy: () =>
    -- TODO waarschijnlijk moet dit nog wat beter
    @TEXTURES = nil
    @IMAGES = nil
    @FONTS = nil