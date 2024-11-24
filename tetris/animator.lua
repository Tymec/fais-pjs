--- Animator
animator = {}

animator.on_load = function()
    animator.animations = {
        ['shake'] = {
            duration = 0.2,
            magnitude = 5,
            t = 0,
            action = function()
                local dx = love.math.random(-animator.animations['shake'].magnitude, animator.animations['shake'].magnitude)
                local dy = love.math.random(-animator.animations['shake'].magnitude, animator.animations['shake'].magnitude)
                love.graphics.translate(dx, dy)
            end,
        },
    }
    
    animator.queue = {}
end

animator.on_update = function(dt)
    for i, name in ipairs(animator.queue) do
        local anim = animator.animations[name]
        anim.t = anim.t + dt
        if anim.t >= anim.duration then
            table.remove(animator.queue, i)
            anim.t = 0
        else
            anim.action()
        end
    end
end

animator.on_draw = function()
    for i, name in ipairs(animator.queue) do
        local anim = animator.animations[name]
        anim.action()
    end
end

animator.shake_screen = function()
    table.insert(animator.queue, 'shake')
end