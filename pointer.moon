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
    -- MOAIInputMgr.device.touch\setCallback( @\touchcallback )

  listenTo: (layer) =>
    layer.x = 0
    layer.y = 0
    print "layer priority #{layer.priority}"
    @layers[layer.priority] = layer

  stopListeningTo: (layer) =>
    @layers[layer.name] = nil

  onClick: (down) =>
    if down
      print "number of layers: #{#@layers}"
      for priority, layer in pairs @layers
        if not @pick
          partition = layer\getPartition!
          if partition
            @pick = partition\propForPoint layer.x, layer.y
            @mouseBody = @world\addBody MOAIBox2DBody.DYNAMIC
            @handlePick(layer)
    else
      @clear()

  clear: () =>
    if @pick
      @mouseBody\destroy()
      @mouseBody = nil
      @pick = nil
    else if @pick
      @pick = nil

  handlePick: (layer) =>
    if @pick
      if @pick.draggable
        print 'draggable start'
        @mouseJoint = @world\addMouseJoint @mouseBody, @pick.body, layer.x, layer.y, 10000.0 * @pick.body\getMass()
        print 'draggable end'
      if @pick.clickable
        @pick.parent.onClick()

  callback: (x, y) =>
    for priority, layer in pairs @layers
      layer.x, layer.y = layer\wndToWorld x, y
      if @pick and @pick.draggable
        @mouseJoint\setTarget layer.x, layer.y

  touchcallback: (eventType, idx, x, y, tapCount) =>
    if eventType == MOAITouchSensor.TOUCH_DOWN
      for priority, layer in pairs @layers
        if not @pick
          partition = layer\getPartition!
          if partition
            layer.x, layer.y = layer\wndToWorld x, y
            @pick = partition\propForPoint layer.x, layer.y
            @mouseBody = @world\addBody MOAIBox2DBody.DYNAMIC
            @handlePick(layer)
    else
      @clear()

export Pntr = Pointer(R.WORLD)
