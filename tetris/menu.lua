--- Menu
menu = {}

menu.on_load = function ()
    menu.title_font = love.graphics.newFont(FONT_PATH, 144)
    menu.title_outline_font = love.graphics.newFont(FONT_PATH, 148)
    menu.normal_font = love.graphics.newFont(FONT_PATH, 36)
    menu.title_color = {0.68, 0.85, 0.88}

    menu.highscore = get_highscore()
    menu.buttons = {
        {i = 0, text = "Continue", enabled = has_saved_state, action = menu.on_button_continue},
        {i = 1, text = "New Game", enabled = function () return true end, action = menu.on_button_new_game},
        {i = 2, text = "Quit", enabled = function () return true end, action = menu.on_button_quit}
    }

    menu.cursor = {i = 0, x = 0, y = 0, pressed = false, override = false}

    menu.delta = 0
    menu.time_step = MENU_TIME_STEP

    local bg_cols = math.ceil(window_width / BLOCK_SIZE)
    local bg_rows = math.ceil(window_height / BLOCK_SIZE) + 4
    menu.background = {}
    for i = 1, bg_cols do
        menu.background[i] = {}
        for j = 1, bg_rows do
            menu.background[i][j] = 0
        end
    end
end

menu.on_update = function (dt)
    menu.delta = menu.delta + dt

    menu.update_title_color(dt)
    
    if menu.delta > menu.time_step then
        menu.delta = 0

        menu.update_background()
    end
end

menu.on_draw = function ()
    local y = window_height / 2
    
    -- draw background
    menu.draw_background()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, window_width, window_height)

    -- draw menu
    menu.draw_text("Tetris", y - 202, menu.title_outline_font, {1.0, 1.0, 1.0})
    menu.draw_text("Tetris", y - 200, menu.title_outline_font, {1.0, 1.0, 1.0})
    menu.draw_text("Tetris", y - 200, menu.title_font, menu.title_color)
    --menu.draw_text("Highscore: " .. menu.highscore, y - 80, menu.normal_font)
    
    for i, button in ipairs(menu.buttons) do
        menu.draw_button(button, y + i * BUTTON_HEIGHT + i * BUTTON_SPACING)
    end
end

menu.on_keypressed = function (key)
    if key == 'up' then
        menu.cursor.override = true
        menu.cursor.i = (menu.cursor.i - 1) % #menu.buttons
    elseif key == 'down' then
        menu.cursor.override = true
        menu.cursor.i = (menu.cursor.i + 1) % #menu.buttons
    elseif key == 'space' or key == 'return' then
        local button = menu.buttons[menu.cursor.i + 1]
        if button and button.enabled() then
            button.action()
        end
    end
end

menu.on_mousemoved = function (x, y)
    menu.cursor.x = x
    menu.cursor.y = y
    menu.cursor.override = false
end

menu.on_mousepressed = function (x, y)
    menu.cursor.pressed = true
end

menu.on_mousereleased = function (x, y)
    menu.cursor.pressed = false
    local button = menu.get_button_at(x, y)
    if button and button.enabled() then
        button.action()
    end
end

menu.on_touchmoved = function (x, y)
    menu.cursor.x = x
    menu.cursor.y = y
    menu.cursor.override = false
end

menu.on_touchpressed = function (x, y)
    menu.cursor.pressed = true
end

menu.on_touchreleased = function (x, y)
    menu.cursor.pressed = false
    local button = menu.get_button_at(x, y)
    if button and button.enabled() then
        button.action()
    end
end


--- Callbacks

menu.on_button_continue = function ()
    load_state()
    is_playing = true
end

menu.on_button_new_game = function ()
    game.on_load()
    is_playing = true
end

menu.on_button_quit = function ()
    love.event.quit()
end


--- Helper functions

menu.update_background = function ()
    -- apply gravity
    for i = #menu.background, 1, -1 do
        for j = #menu.background[i], 1, -1 do
            if j == 1 then
                menu.background[i][j] = 0
            else
                menu.background[i][j] = menu.background[i][j - 1]
            end
        end
    end

    -- TODO: rotation
    -- spawn new pieces
    local amount = math.random(1, 5)
    for i = 1, amount do
        -- choose random piece
        local piece = game.Pieces[game.get_random_piece()]
        local color = {math.random(), math.random(), math.random()}

        -- choose random position
        local x = math.random(1, #menu.background)
        local y = 1
        
        -- check if piece fits
        local fits = true
        for i = 1, #piece do
            for j = 1, #piece[i] do
                if piece[i][j] == 1 then
                    -- check if piece is out of bounds
                    if x + j < 1 or x + j > #menu.background or y + i < 1 or y + i > #menu.background[1] then
                        fits = false
                        break
                    end

                    -- check if piece collides with other pieces
                    if menu.background[x + j][y + i] ~= 0 then
                        fits = false
                        break
                    end

                    -- check if piece has any neighbors left or right
                    if x + j > 1 and menu.background[x + j - 1][y + i] ~= 0 then
                        fits = false
                        break
                    elseif x + j < #menu.background and menu.background[x + j + 1][y + i] ~= 0 then
                        fits = false
                        break
                    end

                    -- check if piece has any neighbors above or below
                    if y + i > 1 and menu.background[x + j][y + i - 1] ~= 0 then
                        fits = false
                        break
                    elseif y + i < #menu.background[1] and menu.background[x + j][y + i + 1] ~= 0 then
                        fits = false
                        break
                    end

                    -- check if piece has any neighbors diagonally
                    if x + j > 1 and y + i > 1 and menu.background[x + j - 1][y + i - 1] ~= 0 then
                        fits = false
                        break
                    elseif x + j < #menu.background and y + i > 1 and menu.background[x + j + 1][y + i - 1] ~= 0 then
                        fits = false
                        break
                    elseif x + j > 1 and y + i < #menu.background[1] and menu.background[x + j - 1][y + i + 1] ~= 0 then
                        fits = false
                        break
                    elseif x + j < #menu.background and y + i < #menu.background[1] and menu.background[x + j + 1][y + i + 1] ~= 0 then
                        fits = false
                        break
                    end
                end
            end
        end

        -- place piece
        if fits then
            for i = 1, #piece do
                for j = 1, #piece[i] do
                    if piece[i][j] == 1 then
                        menu.background[x + j][y + i] = color
                    end
                end
            end
        end
    end
end

menu.update_title_color = function (dt)
    local r, g, b = unpack(menu.title_color)
    local h, s, v = rgb_to_hsv(r, g, b)
    
    -- rainbow colors
    h = h + dt / 10
    if h > 1 then
        h = 0
    end
    s = 1.0
    v = 0.5
    
    r, g, b = hsv_to_rgb(h, s, v)
    menu.title_color = {r, g, b}
end

menu.get_button_at = function (x, y)
    local button_x = window_width / 2 - BUTTON_WIDTH / 2
    for i, button in ipairs(menu.buttons) do
        local button_y = window_height / 2 + i * BUTTON_HEIGHT + i * BUTTON_SPACING
        if x > button_x and x < button_x + BUTTON_WIDTH and y > button_y and y < button_y + BUTTON_HEIGHT then
            return button
        end
    end

    return nil
end

menu.draw_background = function ()
    for i = 1, #menu.background do
        for j = 1, #menu.background[i] do
            if menu.background[i][j] ~= 0 then
                local x = (i - 1) * BLOCK_SIZE
                local y = (j - 5) * BLOCK_SIZE

                -- block
                love.graphics.setColor(menu.background[i][j])
                love.graphics.rectangle('fill', x, y, BLOCK_SIZE, BLOCK_SIZE)
            
                -- border
                love.graphics.setColor({0.9, 0.9, 0.9})
                love.graphics.rectangle('line', x, y, BLOCK_SIZE, BLOCK_SIZE)
            end
        end
    end
end

menu.draw_text = function (text, y, font, color)
    love.graphics.setColor(color)
    love.graphics.setFont(font)
    love.graphics.printf(text, 0, y, window_width, "center")
end

menu.draw_button = function (btn, y)
    local x = window_width / 2 - BUTTON_WIDTH / 2
    local mouse_over = menu.cursor.x > x and menu.cursor.x < x + BUTTON_WIDTH and menu.cursor.y > y and menu.cursor.y < y + BUTTON_HEIGHT
    if mouse_over and not menu.cursor.override then
        menu.cursor.i = btn.i
    end 

    if menu.cursor.override then
        mouse_over = menu.cursor.i == btn.i
    end

    -- colors
    local button_color = BUTTON_COLOR.normal
    if not btn.enabled() then
        button_color = BUTTON_COLOR.disabled
    elseif mouse_over and menu.cursor.pressed then
        button_color = BUTTON_COLOR.pressed
    elseif mouse_over then
        button_color = BUTTON_COLOR.hover
    end

    -- button background
    love.graphics.setColor(button_color)
    love.graphics.rectangle("fill", x, y, BUTTON_WIDTH, BUTTON_HEIGHT, 10, 10)

    -- button border
    love.graphics.setColor(BUTTON_BORDER_COLOR)
    love.graphics.rectangle("line", x, y, BUTTON_WIDTH, BUTTON_HEIGHT, 10, 10)

    -- button text
    love.graphics.setColor(BUTTON_TEXT_COLOR)
    love.graphics.setFont(menu.normal_font)
    love.graphics.printf(btn.text, x, y + 10, BUTTON_WIDTH, "center")
end
