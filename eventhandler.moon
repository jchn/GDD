-- Uitbreiden door meerdere methods aan 1 event te kunnen hangen
class EventHandler

  new: () =>
    @events = {}

  addEventListener: (name, callback) =>
    @events[name] = callback

  removeEventListener: (name) =>
    @events[name] = nil

  triggerEvent: (name, event = {}) =>
    print "triggering #{name}"
    if @events[name]
      @events[name](event)

  clear: () =>
    @events = {}

export e = EventHandler!