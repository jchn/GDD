class LayerManager
  new: (@viewport, @camera) =>
    @layers = {}

  addLayer: (layer) =>
    @layers[layer.name] = layer

  removeLayer: (layer) =>
    @layers[layer.name] = nil

  getLayer: (name) =>
    @layers[name]

  createLayer: (name, priority, interactive, attachedToCamera = true) =>
    layer = MOAILayer.new()
    layer.name = name
    layer.priority = priority
    layer.interactive = interactive
    if attachedToCamera
      layer\setCamera @camera

    layer\setSortMode priority

    layer.render = ->
      MOAIRenderMgr.pushRenderPass layer
      layer

    layer.unrender = ->
      LayerManager.popRenderPass layer
      layer

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

export LayerMgr = LayerManager R.VIEWPORT, camera