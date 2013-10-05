class EventHandler

  new: () =>
    @events = {}

  addEventListener: (name, callback) =>
    @events[name] = callback

  removeEventListener: (name) =>
    @events[name] = nil

  triggerEvent: (name) =>
    if @events[name]
      @events[name]!

export e = EventHandler!