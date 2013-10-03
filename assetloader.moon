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

    -- Load overlays
    print "check for config.overlays"
    print @config.overlays
    if @config.overlays != nil
      overlays = @config.overlays
      print "overlays #{overlays}"
      for k, v in pairs(overlays)
        @OVERLAYS[k] = {}
        @OVERLAYS[k]["COLOR"] = MOAIColor.new!\setColor( v["COLOR"]["R"], v["COLOR"]["G"], v["COLOR"]["B"], v["COLOR"]["A"] )
        @OVERLAYS[k]["TEXT"] = v["TEXT"]
        @OVERLAYS[k]["ASSETS"] = {}
        for ke, va in pairs(v["ASSETS"])
          @OVERLAYS[k]["ASSETS"][ke] = {}
          @OVERLAYS[k]["ASSETS"][ke]["image"] = @IMAGES[ke]
          @OVERLAYS[k]["ASSETS"][ke]["x"] = va["x"]
          @OVERLAYS[k]["ASSETS"][ke]["y"] = va["y"]
          @OVERLAYS[k]["INDICATORS"] = {}
        for key, val in pairs(v["INDICATORS"])
          @OVERLAYS[k]["INDICATORS"][key] = {}
          @OVERLAYS[k]["INDICATORS"][key]["radius"] = val["radius"]
          @OVERLAYS[k]["INDICATORS"][key]["x"] = val["x"]
          @OVERLAYS[k]["INDICATORS"][key]["y"] = val["y"]

        print "___________BBBBBBBBBBBBBB_____________"
        print "radius #{@OVERLAYS.OVERLAY_1.INDICATORS.POWERUP.radius}"

    @onLoadComplete!

  destroy: () =>
    -- TODO waarschijnlijk moet dit nog wat beter
    @TEXTURES = nil
    @IMAGES = nil
    @FONTS = nil