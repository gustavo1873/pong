push = require 'push'
Class = require 'class'
require 'Paddle'
require 'Ball'


WINDOW_WIDTH = 1920
WINDOW_HEIGHT = 1080

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 300

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Pongus')
    
    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont= love.graphics.newFont('font.ttf', 32)
   love.graphics.setFont(smallFont)
   
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    player1Score = 0
    player2Score = 0

    servingPlayer = 1

   -- The numbers between parentheses are the parameters x, y, width, height that were set in the Paddle class
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    gameState = 'start'
end

function love.update(dt)
    if gameState == 'serve' then
        --Ball's velocity changing according to which player scored a point
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == 'play' then

        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.05
            ball.x = player1.x + 5


            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds['paddle_hit']:play()
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.05
            ball.x = player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds['paddle_hit']:play()
        end

       --this block detects if the ball hits the top or bottom boundaries of the screen and if so, it reverses the trajectory
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end


        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()
            if player2Score == 5 then
                winningPlayer = 2
                gameState = 'done'
            else      
                gameState = 'serve'
                ball:reset()
            end
        end
   
        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()
            if player1Score == 5 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
            ball:reset()
            end
        end
    end
        --player 1 paddle movement
        if love.keyboard.isDown('w') then
            -- negative paddle speed because Y up is negative
            player1.dy = -PADDLE_SPEED
            -- positive paddle speed because Y down is positive
        elseif love.keyboard.isDown('s') then 
            player1.dy = PADDLE_SPEED
        else
            player1.dy = 0
        end 

    --player 2 paddle movement
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end


    if gameState == 'play' then
        ball:update(dt)
    end
    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then 
        love.event.quit()
    
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        
        elseif gameState == 'serve' then
            gameState = 'play'

        elseif gameState == 'done' then
            gameState = 'serve'
            ball:reset()
            player1Score = 0
            player2Score = 0

            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(0/255, 45/255, 52/255, 255/255)

    love.graphics.setFont(smallFont)

    displayScore()
    
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Pongus', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to start', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
        
    elseif gameState == 'play' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Play Pongus!', 0, 20, VIRTUAL_WIDTH, 'center' )
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end
    
    --love.graphics.setFont(scoreFont)
    
    --love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    --love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
    
    --left paddle
    player1:render()
    --right paddle
    player2:render()
    --rendering ball using the class's method
    ball:render()
    
    showFPS()
    
    push:apply('end')
end

function showFPS()
        love.graphics.setFont(smallFont)
        love.graphics.setColor(0, 255, 0, 255)
        love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayScore()
        love.graphics.setFont(scoreFont)
        love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 100, 
            VIRTUAL_HEIGHT / 3 - 80)
        love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 90,
            VIRTUAL_HEIGHT / 3 - 80)
end