export Characterstate = {
  IDLE: 0
  EXECUTING: 1
  FINISHING: 2
}

export class Character
  new: (@prop, @layer, @world, @direction, @rectangle, @stats = { health: 100 }, @behaviors = {}) =>
    @state = Characterstate.IDLE

    @body = @world\addBody( MOAIBox2DBody.KINEMATIC )
    @body\setTransform 0, 0
    @fixture = @body\addRect( @rectangle\get() )
    @prop\setParent @body
    @prop.body = @body

  alterHealth: (deltaHealth) =>
    @stats.health += deltaHealth
    if @stats.health <= 0
      @die()

  die: =>
    print "Character dead"

  addBehavior: (behaviorID) =>
    print "addBehavior "..behaviorID\lower()
    table.insert @behaviors, behaviorID\lower()

  update: =>
    print 'updating'

  add: =>
    @layer\insertProp @prop
    @

  remove: =>
    @layer\removeProp @prop
