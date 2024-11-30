require 'constants'
require 'utils'
require 'animator'
require 'game'
require 'menu'
require 'ui'

is_playing = false
font = nil

function love.load()
    love.graphics.setBackgroundColor(BG_COLOR)

    window_width = love.graphics.getWidth()
    window_height = love.graphics.getHeight()

    --music = love.audio.newSource("assets/music.mp3", "stream")

    --music:setVolume(0.7)
    --music:setLooping(true)
    --music:play()

    menu.on_load()
    game.on_load()
    ui.on_load()
    animator.on_load()
end

function love.keypressed(key, unicode)
    if key == 'escape' then
        save_state()
        r = love.event.quit()
    end

    if is_playing then
        game.on_keypressed(key)
    else
        menu.on_keypressed(key)
    end
end

function love.keyreleased(key, unicode)
    if is_playing then
        game.on_keyreleased(key)
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    if not is_playing then
        menu.on_mousemoved(x, y)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if not is_playing then
        menu.on_mousepressed(x, y)
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if not is_playing then
        menu.on_mousereleased(x, y)
    end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    if not is_playing then
        menu.on_touchmoved(x, y)
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    if is_playing then
        game.on_touchpressed(x, y)
    else
        menu.on_touchpressed(x, y)
    end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    if is_playing then
        game.on_touchreleased(x, y)
    else
        menu.on_touchreleased(x, y)
    end
end

function love.update(dt)
    if is_playing then
        game.on_update(dt)
        animator.on_update(dt)
    else
        menu.on_update(dt)
    end
end

function love.draw()
    if is_playing then
        animator.on_draw()
        game.on_draw()
        ui.on_draw()
    else
        menu.on_draw()
    end
end
