function love.load(arg)
  -- comment
  -- another comment
  sprites = {}
  sprites.player = love.graphics.newImage('sprites/player.png')
  sprites.background = love.graphics.newImage('sprites/background.png')
  sprites.bullet = love.graphics.newImage('sprites/bullet.png')
  sprites.zombie = love.graphics.newImage('sprites/zombie.png')

  player = {}
  player.x = love.graphics.getWidth() / 2
  player.y = love.graphics.getHeight() / 2
  player.speed = 500
  player.lives = 3

  maxtime = 2
  timer = maxtime

  stop = false

  zombies = {}

  bullets = {}

  debugAngle = 0

  message = ''
end

function love.update(dt)
  if love.keyboard.isDown('s') then
    player.x = player.x + player.speed * dt
  elseif love.keyboard.isDown('a') then
    player.x = player.x - player.speed * dt
  elseif love.keyboard.isDown('w') then
    player.y = player.y - player.speed * dt
  elseif love.keyboard.isDown('r') then
    player.y = player.y + player.speed * dt
  end

  updateZombies(dt)
  updateBullets(dt)
  delBullets(dt)
  collideBullets(dt)

  if timer <= 0 then
    spawnZombies()
    maxtime = 0.70 * maxtime
    timer = maxtime
  end
  timer = timer - dt

end

function collideBullets(dt)
  for _, z in ipairs(zombies) do
    for _, b in ipairs(bullets) do
      if distanceBetween(z.x, z.y, b.x, b.y) < 20 then
        z.dead = true
        b.dead = true
      end
    end
  end
end

function delBullets(dt)
  for i=#bullets, 1, -1 do
    local b = bullets[i]
    if b.x < 0 or b.y < 0 or b.y > 1000 or b.x > 1000 then
      table.remove(bullets, i)
    end
  end
end

function love.draw()
  love.graphics.draw(sprites.background, 0, 0)
  drawPlayer()
  drawZombies()
  drawBullets()
  love.graphics.print(player.lives)
  cleanUp()
end

function cleanUp()
  for index, zombie in ipairs(zombies) do
    if zombie.dead then
      table.remove(zombies, index)
    end
  end
end

-- utility
function updateZombies(dt)
  local count = 1
  local numberOfZombies = #zombies
  while count <= numberOfZombies and stop == false do
    z = zombies[count]
    local angle = getZombieAngle(z)
    z.x = z.x + math.cos(angle) * z.speed * dt
    z.y = z.y + math.sin(angle) * z.speed * dt
    count = count + 1

    if distanceBetween(z.x, z.y, player.x, player.y) < 30 then
      player.lives = player.lives - 1
      player.speed = player.speed + 50
      if player.lives == 0 then
        stop = true
      end
      z.dead = true
      -- local count = 1
      -- while count <= #zombies do
      --    zombies[count] = nil
      --    count = count + 1
      -- end
--      zombies = {}
    end
  end
end

function updateBullets(dt)
  local count = 1
  local numberOfBullets = #bullets
  while count <= numberOfBullets do
    local b = bullets[count]
    local angle = b.direction
    b.x = b.x + math.cos(angle) * b.speed * dt
    b.y = b.y + math.sin(angle) * b.speed * dt
    count = count + 1
  end
end

function love.keypressed(key)
   if key == "space" then
      spawnZombies()
   end
end

function love.mousepressed(x, y, button)
   if button == 1 then
      spawnBullets()
   end
end

function getPlayerAngle()
  return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi
end

function getZombieAngle(zombie)
  return math.atan2(player.y - zombie.y, player.x - zombie.x)
end

function spawnZombies()
   local zombie = {}
   --zombie.x = math.random(0, love.graphics.getWidth())

   zombie.x, zombie.y = getZombieSpawnPosition()
   zombie.speed = 75
   zombie.dead = false
   table.insert(zombies, zombie)
end

function spawnBullets()
   message = 'spawningBullet'
   local bullet = {}
   bullet.x = player.x
   bullet.y = player.y
   bullet.direction = getPlayerAngle()
   debugAngle = bullet.direction
   bullet.speed = 1000
   bullet.dead = false
   table.insert(bullets, bullet)
end

function drawZombies()
  local count = 1
  local numberOfZombies = #zombies

  while count <= numberOfZombies do
    local zombie = zombies[count]
    if zombie.dead == false then
      love.graphics.draw(sprites.zombie, zombie.x, zombie.y, getZombieAngle(zombie), nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2)
    end

    count = count + 1
  end
end

function drawBullets()
  local i = 1
  while i <= #bullets do
    love.graphics.draw(sprites.bullet, bullets[i].x, bullets[i].y, nil, 0.5, nil, sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
    i = i + 1
  end
end

function drawPlayer()
  love.graphics.setColor(255, 0, 0)
  love.graphics.draw(sprites.player, player.x, player.y, getPlayerAngle(), nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)
  love.graphics.setColor(0, 0, 0)
end

function distanceBetween(x1, y1, x2, y2)
  return math.sqrt((y2-y1)^2 + (x2-x1)^2)
end

function getZombieSpawnPosition()
  local side = math.random(1, 4)
  local x, y
  if side == 1 then
    x = 0
    y = math.random(0, love.graphics.getHeight())
  end

  if side == 2 then
    y = 0
    x = math.random(0, love.graphics.getWidth())
  end

  if side == 3 then
    y = love.graphics.getHeight()
    x = math.random(0, love.graphics.getWidth())
  end

  if side == 4 then
    x = love.graphics.getWidth()
    y = math.random(0, love.graphics.getHeight())
  end
  return x, y
end
