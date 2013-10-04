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
    if MOAIInputMgr.device.pointer
      MOAIInputMgr.device.pointer\setCallback ( @\callback )
      MOAIInputMgr.device.mouseLeft\setCallback ( @\onClick )
    else
      MOAIInputMgr.device.touch\setCallback( @\touchcallback )

  setWorld: (@world) =>

  listenTo: (layer) =>
    layer.x = 0
    layer.y = 0
    @layers[layer.priority] = layer

  stopListeningTo: (layer) =>
    @layers[layer.name] = nil

  onClick: (down) =>
    if down
      for priority, layer in pairs @layers
        if not @pick and layer.interactive
          partition = layer\getPartition!
          if partition
            @pick = partition\propForPoint layer.x, layer.y
            if @pick
              @handlePick(layer)
    else
      @clear()

  clear: () =>
    if @pick
      if @pick.draggable
        @pick.parent.isDragged = false
        @pick.parent\endDrag()
      if @mouseBody
        @mouseBody\destroy()
        @mouseBody = nil
      if @mouseJoint
        @mouseJoint\destroy()
        @mouseBody = nil
      @pick.isDragged = false
      @pick = nil

  forcedPick: (prop, layer) =>
    @pick = prop
    @handlePick(layer)

  handlePick: (layer) =>
    if @pick and @pick.draggable
      @pick.isDragged = true
      @pick.parent\beginDrag()
      @pick.parent.isDragged = true
      @mouseBody = @world\addBody MOAIBox2DBody.DYNAMIC
      @mouseJoint = @world\addMouseJoint @mouseBody, @pick.body, layer.x, layer.y, 10000.0 * @pick.body\getMass()
      @mouseBody\setTransform layer.x, layer.y
    if @pick and @pick.clickable
      @pick.parent\triggerClick layer.x, layer.y

  callback: (x, y) =>
    for priority, layer in pairs @layers
        @prevX, @prevY = layer.x, layer.y
        layer.x, layer.y = layer\wndToWorld x, y
        if @pick and @pick.draggable and @mouseJoint
          @mouseJoint\setTarget layer.x, layer.y

  touchcallback: (eventType, idx, x, y, tapCount) =>
    if eventType == MOAITouchSensor.TOUCH_DOWN
      for priority, layer in pairs @layers
        layer.x, layer.y = layer\wndToWorld x, y
        if layer.interactive and not @pick
          partition = layer\getPartition!
          if partition
            @pick = partition\propForPoint layer.x, layer.y
            if @pick
              @handlePick(layer)
    else if eventType == MOAITouchSensor.TOUCH_MOVE
      for priority, layer in pairs @layers
        -- @prevX, @prevY = layer.x, layer.y
        layer.x, layer.y = layer\wndToWorld x, y
        if @pick and @pick.draggable
          @mouseJoint\setTarget layer.x, layer.y
    else
      @clear()

export Pntr = Pointer(R.WORLD)

export clearPointer = (world) =>
  Pntr = Pointer(world)