require 'lib.TSerial'

--- Utils
function get_highscore()
    local highscore = 0

    if love.filesystem.getInfo("highscore", love.file) then
        highscore = love.filesystem.read("highscore")
    else
        love.filesystem.write("highscore", highscore)
    end
    return highscore
end

function set_highscore(score)
    local highscore = get_highscore()
    if score > highscore then
        love.filesystem.write("highscore", score)
    end
end

function has_saved_state()
    return love.filesystem.getInfo("save", love.file)
end

function save_state()
    local state = {
        board = game.board,
        piece = game.piece,
        current_piece = game.current_piece,
        next_piece = game.next_piece,
        has_active_piece = game.has_active_piece,
        score = game.score,
        game_over = game.game_over
    }
    love.filesystem.write("save", TSerial.pack(state))
end

function load_state()
    if has_saved_state() then
        local state = TSerial.unpack(love.filesystem.read("save"))
        game.board = state.board
        game.piece = state.piece
        game.current_piece = state.current_piece
        game.next_piece = state.next_piece
        game.has_active_piece = state.has_active_piece
        game.score = state.score
        game.game_over = state.game_over
    end
end

function clear_saved_state()
    if has_saved_state() then
        love.filesystem.remove("save")
    end
end

function index_to_coords(index, cols)
    local x = (index - 1) % cols + 1
    local y = math.floor((index - 1) / cols) + 1
    return x, y
end

function coords_to_index(x, y, cols)
    return (y - 1) * cols + x
end

function transpose_table(m)
    local rotated = {}
    for c, m_1_c in ipairs(m[1]) do
       local col = {m_1_c}
       for r = 2, #m do
          col[r] = m[r][c]
       end
       table.insert(rotated, col)
    end
    return rotated
end

function rotate_270(m)
    local rotated = {}
    for c, m_1_c in ipairs(m[1]) do
       local col = {m_1_c}
       for r = 2, #m do
          col[r] = m[r][c]
       end
       table.insert(rotated, 1, col)
    end
    return rotated
end

function rotate_180(m)
    return rotate_270(rotate_270(m))
end
 
 function rotate_90(m)
    return rotate_270(rotate_270(rotate_270(m)))
end

function rgb_to_hsv(r, g, b)
	local M, m = math.max(r, g, b), math.min(r, g, b)
	local C = M - m
	local K = 1.0/(6.0 * C)
	local h = 0.0
	if C ~= 0.0 then
		if M == r then     h = ((g - b) * K) % 1.0
		elseif M == g then h = (b - r) * K + 1.0/3.0
		else               h = (r - g) * K + 2.0/3.0
		end
	end
	return h, M == 0.0 and 0.0 or C / M, M
end

function hsv_to_rgb(h, s, v)
	local C = v * s
	local m = v - C
	local r, g, b = m, m, m
	if h == h then
		local h_ = (h % 1.0) * 6
		local X = C * (1 - math.abs(h_ % 2 - 1))
		C, X = C + m, X + m
		if     h_ < 1 then r, g, b = C, X, m
		elseif h_ < 2 then r, g, b = X, C, m
		elseif h_ < 3 then r, g, b = m, C, X
		elseif h_ < 4 then r, g, b = m, X, C
		elseif h_ < 5 then r, g, b = X, m, C
		else               r, g, b = C, m, X
		end
	end
	return r, g, b
end