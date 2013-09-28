class LayerManager
  new: (@viewport, @camera) =>
    @layers = {}

  addLayer: (layer) =>
    @layers[layer.name] = layer
    
  renderLayers: () =>

    tempLayerTable = {}
    for layerName, layer in pairs @layers do
      if layer.render == true
        tempLayerTable[layer.priority] = layer

    layersByPriority = {}
    for layerPriority, layer in pairs tempLayerTable do
      layersByPriority[#layersByPriority + 1] = layer

    MOAIRenderMgr.setRenderTable(layersByPriority)

  removeLayer: (layer) =>
    @layers[layer.name] = nil

  getLayer: (name) =>
    @layers[name]

  createLayer: (name, priority, interactive, attachedToCamera = true) =>
    layer = MOAILayer.new()
    layer.name = name
    layer.priority = priority
    layer.interactive = interactive
    layer.render = false
    if attachedToCamera
      layer\setCamera @camera

    layer\setSortMode MOAILayer2D.SORT_NONE

    layer.render = ->
      layer.render = true
      @renderLayers()
      return layer

    layer.unrender = ->
      layer.render = false
      @renderLayers()
      return layer

    @addLayer layer
    layer\setViewport R.VIEWPORT
    -- MOAIRenderMgr.pushRenderPass layer

    if interactive
      -- Set callbacks for the layer
      Pntr\listenTo layer

    layer

  pushRenderPass: (layer) =>
    MOAIRenderMgr.pushRenderPass layer

  popRenderPass: (layer) =>
    MOAIRenderMgr.popRenderPass layer

  destroyLayer: (layer) =>
    Pntr\stopListeningTo layer

    @removeLayer layer

export LayerMgr = LayerManager R.VIEWPORT, R.CAMERA