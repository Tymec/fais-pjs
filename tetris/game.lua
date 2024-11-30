--- Game
game = {}

game.Pieces = {
    O = {
        {1, 1},
        {1, 1}
    },

    I = {
        {0, 1, 0},
        {0, 1, 0},
        {0, 1, 0},
        {0, 1, 0},
    },

    S = {
        {0, 1, 1},
        {1, 1, 0}
    },

    Z = {
        {1, 1, 0},
        {0, 1, 1}
    },

    L = {
        {1, 0},
        {1, 0},
        {1, 1}
    },

    J = {
        {0, 1},
        {0, 1},
        {1, 1}
    },

    T = {
        {0, 1, 0},
        {1, 1, 1}
    }
}

game.PieceColors = {
    O = {1, 1, 0},
    I = {0, 1, 1},
    S = {0, 1, 0},
    Z = {1, 0, 0},
    L = {1, 0.5, 0},
    J = {0, 0, 1},
    T = {0.5, 0, 1}
}

game.on_load = function ()
    game.score = 0
    game.game_over = false
    game.delta = 0
    game.time_step = GAME_TIME_STEP
    game.lock_delta = 0
    game.has_active_piece = false
    game.has_swapped = false
    game.piece = {}
    game.piece_rotation = 0
    game.touch_x = 0
    game.touch_y = 0

    game.cols = math.floor(window_width / BLOCK_SIZE) - BOARD_PADDING.x
    game.rows = math.floor(window_height / BLOCK_SIZE) - BOARD_PADDING.y

    game.board = {}
    for i = 1, game.cols do
        game.board[i] = {}
        for j = 1, game.rows do
            game.board[i][j] = 0
        end
    end

    game.current_piece = game.get_random_piece()
    game.next_piece = game.get_random_piece()
    game.spawn_piece(game.current_piece)
end

game.on_keypressed = function (key)
    if game.game_over then
        if key == 'return' then
            game.on_load()
            game.game_over = false
        elseif key == 'backspace' then
            clear_saved_state()
            is_playing = false
        end
        return
    end

    if key == 'left' or key == 'a' then
        game.move(-1, 0)
    elseif key == 'right' or key == 'd' then
        game.move(1, 0)
    elseif key == 'up' or key == 'w' then
        game.rotate()
    elseif key == 'down' or key == 's' then
        if game.lock_delta == 0 then
            game.time_step = GAME_FAST_STEP
        end
    elseif key == 'space' then
        while game.move(0, 1) do
        end
        game.lock_delta = GAME_LOCK_DELAY + 1
        game.delta = game.time_step
    elseif key == 'lshift' then
        game.swap()
    elseif key == 'backspace' then
        save_state()
        is_playing = false
    elseif key == 'r' then
        game.on_load()
    end
end

game.on_keyreleased = function (key)
    if game.game_over then
        return
    end

    if key == 'down' or key == 's' then
        game.time_step = GAME_TIME_STEP
    end
end

game.on_touchpressed = function (x, y)
    if game.game_over then
        game.on_load()
        game.game_over = false
        return
    end

    game.touch_x = x
    game.touch_y = y
end

game.on_touchreleased = function (x, y)
    if game.game_over then
        return
    end

    local dx = x - game.touch_x
    local dy = y - game.touch_y

    if math.abs(dx) > TOUCH_TOLERANCE then
        if dx > 0 then
            game.move(1, 0)
        else
            game.move(-1, 0)
        end
    elseif math.abs(dy) > TOUCH_TOLERANCE then
        if dy > 0 then
            while game.move(0, 1) do
            end
            game.lock_delta = GAME_LOCK_DELAY + 1
            game.delta = game.time_step
        else
            game.rotate()
        end
    else
        game.rotate()
    end

    -- reset touch coordinates
    game.touch_x = 0
    game.touch_y = 0
end

game.on_update = function (dt)
    if game.game_over then
        return
    end

    game.delta = game.delta + dt

    if game.delta > game.time_step then
        game.delta = 0

        game.apply_gravity()

        if not game.has_active_piece then
            if not game.spawn_piece(game.next_piece) then
                game.game_over = true
            else
                game.next_piece = game.get_random_piece()
                game.has_swapped = false
            end
        end
    end
end

game.on_draw = function ()
    -- draw board background
    love.graphics.setColor(BOARD_BG_COLOR)
    love.graphics.rectangle('fill', BLOCK_SIZE, BLOCK_SIZE, game.cols * BLOCK_SIZE, game.rows * BLOCK_SIZE)
    
    -- draw board border
    love.graphics.setColor(BOARD_BORDER_COLOR)
    love.graphics.rectangle('line', BLOCK_SIZE, BLOCK_SIZE, game.cols * BLOCK_SIZE, game.rows * BLOCK_SIZE)

    -- draw board blocks
    for i = 1, game.cols do
        for j = 1, game.rows do
            local cell = game.board[i][j]
            if game.board[i][j] ~= 0 then
                game.draw_block(i, j, cell.color)
            end
        end
    end
end


--- Helper functions

game.end_game = function ()
    game.game_over = true
    set_highscore(game.score)
end

game.get_random_piece = function ()
    local types = {'O', 'I', 'S', 'Z', 'L', 'J', 'T'}
    return types[math.random(1, #types)]
end

game.spawn_piece = function (tpe)
    -- TODO: spawn the piece outside the board
    -- place the piece at the top of the board and in the middle
    local x = math.floor(game.cols / 2)
    local y = 0

    -- TODO: partially spawn the piece
    -- if unable to spawn the piece, game over
    for i = 1, #game.Pieces[tpe] do
        for j = 1, #game.Pieces[tpe][i] do
            if game.Pieces[tpe][i][j] == 1 then
                local cell = game.board[x + j][y + i]
                if cell ~= 0 and not cell.active then
                    return false
                end
            end
        end
    end
    
    local indices = {}
    for i = 1, #game.Pieces[tpe] do
        for j = 1, #game.Pieces[tpe][i] do
            if game.Pieces[tpe][i][j] == 1 then
                game.board[x + j][y + i] = {active = true, color = game.PieceColors[tpe]}
                table.insert(indices, coords_to_index(x + j, y + i, game.cols))
            end
        end
    end
    
    game.piece = indices
    game.current_piece = tpe
    game.has_active_piece = true
    return true
end

game.apply_gravity = function ()
    -- check if there is an active piece
    if not game.has_active_piece then
        return
    end

    -- apply gravity to the active piece
    if not game.move(0, 1) then
        -- the piece can't move down anymore, give the player some time to move it
        game.lock_delta = game.lock_delta + 1
        game.time_step = GAME_TIME_STEP
    end

    if game.lock_delta > GAME_LOCK_DELAY then
        game.lock_delta = 0
        
        -- the piece can't move down, so it's time to lock it
        for i = 1, #game.piece do
            local x, y = index_to_coords(game.piece[i], game.cols)
            game.board[x][y] = {active = false, color = game.PieceColors[game.current_piece]}
        end

        game.remove_lines()

        game.has_active_piece = false
    end
end

game.calculate_score = function (lines_cleared)
    local total = 0 

    if lines_cleared == 1 then
        total = 40
    elseif lines_cleared == 2 then
        total = 100
    elseif lines_cleared == 3 then
        total = 300
    elseif lines_cleared == 4 then
        total = 1200
    else
        total = 1200 + game.calculate_score(lines_cleared - 4)
    end

    return total
end

game.remove_lines = function ()
    local lines_cleared = 0

    -- go through each row and check if it's full
    for j = 1, game.rows do
        local full = true
        for i = 1, game.cols do
            if game.board[i][j] == 0 then
                full = false
                break
            end
        end

        -- if the row is full, remove it
        if full then
            lines_cleared = lines_cleared + 1
            for i = 1, game.cols do
                -- TODO: add line clear animation
                -- TODO: add sound effect
                game.board[i][j] = 0
            end

            -- move all the rows above the current one down
            for k = j - 1, 1, -1 do
                for i = 1, game.cols do
                    game.board[i][k + 1] = game.board[i][k]
                end
            end
        end
    end

    -- update the score
    if lines_cleared > 0 then
        game.score = game.score + game.calculate_score(lines_cleared)
        animator.shake_screen()
    end
end

game.rotate = function ()
    -- check if there is an active piece
    if not game.has_active_piece then
        return
    end

    local piece = game.Pieces[game.current_piece]
    local rotation = (game.piece_rotation + 1) % 4

    -- create a copy of the piece
    local new_piece = {}
    for i = 1, #piece do
        new_piece[i] = {}
        for j = 1, #piece[i] do
            new_piece[i][j] = piece[i][j]
        end
    end
    
    -- rotate the piece
    if rotation == 1 then
        new_piece = rotate_90(new_piece)
    elseif rotation == 2 then
        new_piece = rotate_180(new_piece)
    elseif rotation == 3 then
        new_piece = rotate_270(new_piece)
    end

    -- get the new piece position
    local xp = math.huge
    local yp = math.huge
    for i = 1, #game.piece do
        local x, y = index_to_coords(game.piece[i], game.cols)
        xp = math.min(xp, x)
        yp = math.min(yp, y)
    end

    -- check if the piece can be placed in the new position
    for i = 1, #new_piece do
        for j = 1, #new_piece[i] do
            if new_piece[i][j] == 1 then
                local x = xp + j - 1
                local y = yp + i - 1

                -- out of bounds
                if x < 1 or x > game.cols or y < 1 or y > game.rows then
                    return false
                end

                -- check if the cell is occupied
                local cell = game.board[x][y]
                if cell ~= 0 and not cell.active then
                    return false
                end
            end
        end
    end

    -- remove the old piece from the board
    for i = 1, #game.piece do
        local x, y = index_to_coords(game.piece[i], game.cols)
        game.board[x][y] = 0
    end
    
    -- place the new piece on the board
    local indices = {}
    for i = 1, #new_piece do
        for j = 1, #new_piece[i] do
            if new_piece[i][j] == 1 then
                local x = xp + j - 1
                local y = yp + i - 1
                game.board[x][y] = {active = true, color = game.PieceColors[game.current_piece]}
                table.insert(indices, coords_to_index(x, y, game.cols))
            end
        end
    end

    game.piece = indices
    game.piece_rotation = rotation
    return true
end

game.swap = function ()
    -- check if there is an active piece
    if not game.has_active_piece then
        return
    end

    -- check if the player has already swapped a piece
    if game.has_swapped then
        return
    end

    -- remove the active piece from the board
    for i = 1, #game.piece do
        local x, y = index_to_coords(game.piece[i], game.cols)
        game.board[x][y] = 0
    end
    
    -- spawn the swapped piece
    local tpe = game.current_piece
    game.current_piece = game.next_piece
    game.next_piece = tpe
    game.spawn_piece(game.current_piece)

    game.has_swapped = true
end

game.move = function(dx, dy)
    -- check if there is an active piece
    if not game.has_active_piece then
        return false
    end

    -- check if the piece can move in the direction
    for i = 1, #game.piece do
        local x, y = index_to_coords(game.piece[i], game.cols)
        if x + dx < 1 or x + dx > game.cols then
            return false
        end

        if y + dy < 1 or y + dy > game.rows then
            return false
        end

        local cell = game.board[x + dx][y + dy]
        if cell ~= 0 and not cell.active then
            return false
        end
    end

    -- move the piece
    local new_piece = {}
    for i = 1, #game.piece do
        local x, y = index_to_coords(game.piece[i], game.cols)
        game.board[x][y] = 0
        table.insert(new_piece, coords_to_index(x + dx, y + dy, game.cols))
    end
    game.piece = new_piece

    -- update the board
    for i = 1, #game.piece do
        local x, y = index_to_coords(game.piece[i], game.cols)
        game.board[x][y] = {active = true, color = game.PieceColors[game.current_piece]}
    end

    return true
end

game.draw_block = function (x, y, color)
    love.graphics.setColor(color)
    love.graphics.rectangle('fill', x * BLOCK_SIZE, y * BLOCK_SIZE, BLOCK_SIZE, BLOCK_SIZE)

    love.graphics.setColor({0.9, 0.9, 0.9})
    love.graphics.rectangle('line', x * BLOCK_SIZE, y * BLOCK_SIZE, BLOCK_SIZE, BLOCK_SIZE)
end
