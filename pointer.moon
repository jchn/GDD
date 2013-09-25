class Pointer
  @pick: nil
  @mouseBody: nil
  @ropeJoint: nil
  @world
  @worldX: 0
  @worldY: 0

  new: (@world) =>
    -- TODO dit implementeren voor touch
    @layers = {}
    if MOAIInputMgr.device.pointer
      MOAIInputMgr.device.pointer\setCallback ( @\callback )
      MOAIInputMgr.device.mouseLeft\setCallback ( @\onClick )
    else
      MOAIInputMgr.device.touch\setCallback( @\touchcallback )

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
        if not @pick and layer.interactive
          partition = layer\getPartition!
          if partition
            @pick = partition\propForPoint layer.x, layer.y
            if @pick and @pick.draggable
              @mouseBody = @world\addBody MOAIBox2DBody.KINEMATIC
              @mouseBody\setTransform layer.x, layer.y
              @ropeJoint = @world\addRopeJoint @mouseBody, @pick.body, 2
              @pick.isDragged = true
            elseif @pick and @pick.clickable
              @handlePick()
    else
      @clear()

  clear: () =>
    print "CLEAR #{@pick}"
    if @pick
      if @pick.draggable
        @mouseBody\destroy()
        @ropeJoint\destroy()
        @pick.isDragged = false
        @pick = nil
      else
        @pick = nil

  handlePick: () =>
    if @pick and @pick.clickable
      @pick.parent.onClick()

  callback: (x, y) =>
    for priority, layer in pairs @layers
      if layer.interactive
        @prevX, @prevY = layer.x, layer.y
        layer.x, layer.y = layer\wndToWorld x, y
        if @pick and @pick.draggable
          @mouseBody\setTransform layer.x, layer.y

  touchcallback: (eventType, idx, x, y, tapCount) =>
    if eventType == MOAITouchSensor.TOUCH_DOWN
      for priority, layer in pairs @layers
        if layer.interactive and not @pick
          partition = layer\getPartition!
          if partition
            @pick = partition\propForPoint layer.x, layer.y
            if @pick and @pick.draggable
              @mouseBody = @world\addBody MOAIBox2DBody.KINEMATIC
              @mouseBody\setTransform layer.x, layer.y
              @ropeJoint = @world\addRopeJoint @mouseBody, @pick.body, 40
            elseif @pick and @pick.clickable
              @handlePick()
    else if eventType == MOAITouchSensor.TOUCH_MOVE
      for priority, layer in pairs @layers
        if layer.interactive and not @pick
          @prevX, @prevY = layer.x, layer.y
          layer.x, layer.y = layer\wndToWorld x, y
          if @pick and @pick.draggable
            @mouseBody\setTransform layer.x, layer.y
    else
      @clear()

export Pntr = Pointer(R.WORLD)
