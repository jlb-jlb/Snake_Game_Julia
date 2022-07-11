# initialize scree

WIDTH = 600
HEIGHT = 720
BACKGROUND = colorant"antiquewhite"

header = 120


# define snake actor

snake_pos_x = WIDTH / 2
snake_pos_y = (HEIGHT - header) / 2 + header

snake_size = 20 # default = 20 | can try 10, 30, 50 # defines grid and head


snake_color = colorant"green"

snake_head = Rect(
    snake_pos_x, snake_pos_y, snake_size, snake_size
)


# grow snake

snake_body = []

function grow()
    push!(snake_body,
        Rect(
            snake_head.x, snake_head.y, snake_size, snake_size
        )
    )
end

grow()


function spawn()
    # all possible locations
    xrange = collect(0:snake_size:(WIDTH - snake_size))
    yrange = collect(header:snake_size:(HEIGHT - snake_size))
    x = rand(xrange)
    y = rand(yrange)
    # array of snake_body locations
    occupied = []
    for i in 1:length(snake_body)
        push!(occupied, snake_body[i].x, snake_body[i].y)
    end
    # select spawn locations
    if (x, y) in occupied
        spawn()
    else 
        return x,y
    end
end


apple_pos_x, apple_pos_y = spawn()

apple_size = snake_size

apple_color = colorant"red"

apple = Rect(
    apple_pos_x, apple_pos_y, apple_size, apple_size
)


# define header box actor

headerbox = Rect(0, 0, WIDTH, header)

# initialize other game variables

score = 0
gameover = false

# draw actors

function draw(g::Game)
    # snake
    draw(snake_head, snake_color, fill = true)
    for i in 1:length(snake_body)
        draw(snake_body[i], snake_color, fill = true)
    end
    # apple
    draw(apple, apple_color, fill = true)
    # headerbox
    draw(headerbox, colorant"navyblue", fill= true)
    # display score
    if gameover == false
        display = "Score = $score"
    else
        display = "GAME OVER! FINAL SCORE = $score"
        # play again instructions
        replay = TextActor("Click to play again", "roboto-italic"; 
            font_size = 36, color = Int[0,0,0,255]
        )
        replay.pos = (135, 390)
        draw(replay)
    end
    txt = TextActor(display, "roboto-italic";
        font_size = 36, color = Int[255, 255, 0, 255]    
    )
    txt.pos = (30, 30)
    draw(txt)
end

# move snake

speed = snake_size
vx = speed
vy = 0

function move()
    snake_head.x += vx
    snake_head.y += vy
end

# gamezero refreshrate is 60 times per sec 

delay = 0.2 # delay input
delay_limit = 0.05

function border()
    global gameover
    if snake_head.x == WIDTH ||
        snake_head.x < 0 ||
        snake_head.y == HEIGHT ||
        snake_head.y < header
            gameover = true
    end
end


# define collision functions

function collide_head_body()
    global gameover
    for i in 1:length(snake_body)
        if collide(snake_head, snake_body[i])
            gameover = true
        end
    end
end

function collide_head_apple()
    global delay
    if collide(snake_head, apple)
        # spawn new apple
        apple.x, apple.y = spawn()
        # grow snake
        grow()
        #reduce delay
        if delay > delay_limit
            delay -= 0.01
        end
    end
end


# define update function

function update(g::Game)
    # CHECK EVERY CONDITION!
    if gameover == false
        global snake_body, score
        move()
        border()
        collide_head_body()
        collide_head_apple()
        grow() # grow array bzw. keep it from shrinking
        popat!(snake_body, 1) # illusion of movement
        score = length(snake_body) -1
        sleep(delay)
    end
end


# define keyboard interaction

function direction(x,y)
    global vx, vy
    vx = x
    vy = y
end

right() = direction(speed, 0)
left() = direction(-speed, 0)
down() = direction(0,speed)
up() = direction(0, -speed)


function on_key_down(g::Game)
    if g.keyboard.right
        if vx !== -speed
            right()
        end
    elseif g.keyboard.left
        if vx !== speed
            left()
        end
    elseif g.keyboard.down
        if vy !== -speed
            down()
        end
    elseif g.keyboard.up
        if vy !== speed
            up()
        end
    end
end





