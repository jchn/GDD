class Pointer
  @pick: nil
  @mouseBody: nil
  @mouseJoint: nil
  @world
  @worldX: 0
  @worldY: 0

  new: (@world) =>
    -- TODO dit implementeren voor touch
    @layers = {}
    MOAIInputMgr.device.pointer\setCallback ( @\callback )
    MOAIInputMgr.device.mouseLeft\setCallback ( @\onClick )

  listenTo: (layer) =>
    layer.x = 0
    layer.y = 0
    @layers[layer.priority] = layer

  stopListeningTo: (layer) =>
    @layers[layer.name] = nil

  onClick: (down) =>
    if down
      for layer in *@layers
        if not @pick
          @pick = layer\getPartition()\propForPoint layer.x, layer.y
          @mouseBody = @world\addBody MOAIBox2DBody.DYNAMIC
          @handlePick(layer)
    else
      if @pick
        @mouseBody\destroy()
        @mouseBody = nil
        @pick = nil

  handlePick: (layer) =>
    if @pick
      if @pick.draggable
        @mouseJoint = @world\addMouseJoint @mouseBody, @pick.body, layer.x, layer.y, 10000.0 * @pick.body\getMass()
      if @pick.clickable
        @pick.parent.onClick()

  callback: (x, y) =>
    for layer in *@layers
      layer.x, layer.y = layer\wndToWorld x, y
      if @pick and @pick.draggable
        @mouseJoint\setTarget layer.x, layer.y

export Pntr = Pointer(R.WORLD)
