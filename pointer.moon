export class Pointer
  @pick: nil
  @mouseBody: nil
  @mouseJoint: nil
  @world
  @worldX: 0
  @worldY: 0

  new: (@world, @layer) =>
    -- TODO dit implementeren voor touch
    MOAIInputMgr.device.pointer\setCallback ( @\callback )
    MOAIInputMgr.device.mouseLeft\setCallback ( @\onClick )

  onClick: (down) =>
    if down
      @pick = @layer\getPartition()\propForPoint @worldX, @worldY
      @mouseBody = @world\addBody MOAIBox2DBody.DYNAMIC
      if @pick and @pick.draggable

        @mouseJoint = @world\addMouseJoint @mouseBody, @pick.body, @worldX, @worldY, 10000.0 * @pick.body\getMass()
    else
      if @pick
        @mouseBody\destroy()
        @mouseBody = nil
        @pick = nil

  callback: (x, y) =>
    @worldX, @worldY = @layer\wndToWorld x, y

    if @pick and @pick.draggable
      @mouseJoint\setTarget @worldX, @worldY
