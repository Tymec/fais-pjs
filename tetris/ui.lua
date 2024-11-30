--- UI
ui = {}

ui.on_load = function ()
    ui.large_font = love.graphics.newFont(FONT_PATH, UI_LARGE_FONT_SIZE)
    ui.normal_font = love.graphics.newFont(FONT_PATH, UI_NORMAL_FONT_SIZE)

    ui.x = game.cols * BLOCK_SIZE + BLOCK_SIZE * 2
    ui.y = BLOCK_SIZE
end

ui.on_draw = function ()
    ui.draw_score()
    ui.draw_next_piece()

    if game.game_over then
        ui.draw_game_over()
    end
end


--- Helper functions

ui.draw_game_over = function ()
    -- darken the board
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle('fill', BLOCK_SIZE, BLOCK_SIZE, game.cols * BLOCK_SIZE, game.rows * BLOCK_SIZE)

    -- draw game over text
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(ui.large_font)
    love.graphics.printf('Game Over', BLOCK_SIZE, window_height / 2, game.cols * BLOCK_SIZE, 'center')

    -- draw restart text
    love.graphics.setFont(ui.normal_font)
    love.graphics.printf("Press Enter to restart", BLOCK_SIZE, window_height / 2 + 75, game.cols * BLOCK_SIZE, 'center')
end

ui.draw_highscore = function ()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(ui.normal_font)
    love.graphics.printf('Highscore: ' .. get_highscore(), ui.x, ui.y, 5 * BLOCK_SIZE, 'center')
end

ui.draw_score = function ()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(ui.normal_font)
    love.graphics.printf('Score: ' .. game.score, ui.x, ui.y + 5 * BLOCK_SIZE + 20, 5 * BLOCK_SIZE, 'center')
end

ui.draw_next_piece = function ()
    -- draw pocket background
    love.graphics.setColor(BOARD_BG_COLOR)
    love.graphics.rectangle('fill', ui.x, ui.y, 5 * BLOCK_SIZE, 5 * BLOCK_SIZE)

    -- draw pocket border
    love.graphics.setColor(BOARD_BORDER_COLOR)
    love.graphics.rectangle('line', ui.x, ui.y, 5 * BLOCK_SIZE, 5 * BLOCK_SIZE)

    -- draw next piece
    local tpe = game.next_piece
    local color = game.PieceColors[tpe]
    local x = game.cols + 2
    local y = 1

    for i = 1, #game.Pieces[tpe] do
        for j = 1, #game.Pieces[tpe][i] do
            if game.Pieces[tpe][i][j] == 1 then
                game.draw_block(x + j, y + i, color)
            end
        end
    end
end
