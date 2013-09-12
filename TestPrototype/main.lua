gameName = "WHACK a MOLE"
screenWidth = 800
screenHeight = 480

enemies = {}

MOAISim.openWindow(gameName, screenWidth, screenHeight)

viewport = MOAIViewport.new()
viewport:setSize(screenWidth, screenHeight)
viewport:setScale(screenWidth, screenHeight)

layer = MOAILayer2D.new()
layer:setViewport(viewport)
MOAIRenderMgr.pushRenderPass(layer)

alienTexture = MOAIImage.new()
alienTexture:load("alien.png")

alienDeck = MOAIGfxQuad2D.new()
alienDeck:setTexture(alienTexture)
alienDeck:setRect(-64,-64,64,64)

heroTexture = MOAIImage.new()
heroTexture:load("hero.png")

heroDeck = MOAIGfxQuad2D.new()
heroDeck:setTexture(heroTexture)
heroDeck:setRect(-64,-64,64,64)

ufoTexture = MOAIImage.new()
ufoTexture:load("ufo.png")

ufoDeck = MOAIGfxQuad2D.new()
ufoDeck:setTexture(ufoTexture)
ufoDeck:setRect(-64,-64,64,64)

--[[
      CLASS DECLARATIONS
]]--

Character = {}

function Character:new(_prop, _health)
  newObject = {
    prop = _prop,
    health = _health,
    alive = true
  }
  
  self.__index = self
  return setmetatable(newObject, self)
end

function Character:alterHealth(deltaHealth)
  health = health + deltaHealth
end

function Character:checkHealth()
  if (self.health <= 0) then
    self.die()
  end
end

function Character:die()
  print "I'm dead!"
  self.alive = false
end

Hero = Character:new()
Enemy = Character:new()
Ufo = Character:new()

function Hero:die()
  self.prop:moveScl(1,1,2)
end

function Enemy:die()
  self.prop:moveRot(180,2)
end

function Ufo:die()
  self.prop:moveLoc(-150,150,2)
end

--[[
  Spawn Functions
]]--function spawnEnemy(x, y, deck)
  local prop = MOAIProp2D.new()
  prop:setDeck(deck)
  prop:setLoc(x,y)
  layer:insertProp(prop)
  
  local tempEnemy = Enemy:new(prop, 10)
  
  table.insert(enemies, tempEnemy)
  
  return tempEnemy
end

spawnEnemy(250,-150, alienDeck)
enemies[1]:die()