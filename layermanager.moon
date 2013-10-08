class LayerManager
  new: (@viewport, @camera) =>
    @layers = {}

  addLayer: (layer) =>
    @layers[layer.name] = layer

  getLayers: () =>
    tempLayerTable = {}
    for layerName, layer in pairs @layers do
      tempLayerTable[layer.priority] = layer

    tempLayerTable =  _.reverse tempLayerTable

    tempLayerTable
    
  renderLayers: () =>

    tempLayerTable = {}
    for layerName, layer in pairs @layers do
      if layer.render == true
        tempLayerTable[layer.priority] = layer

    layersByPriority = {}
    for layerPriority, layer in pairs tempLayerTable do
      layersByPriority[#layersByPriority + 1] = layer

    -- @layers = layersByPriority

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

  destroyAllLayers: () =>
    for ID, layer in pairs @layers do
      layer\clear!
      layer\unrender!
      @destroyLayer layer
      MOAIRenderMgr.setRenderTable({})

export LayerMgr = LayerManager R.VIEWPORT, R.CAMERA