require 'gosu'
require 'matrix'

class LCD
  def initialize(size_x, size_y, window)
    @window = window
    @bmp = Array.new(size_y).map { Array.new(size_x, false) }
  end

  def set(x, y, color)
    @bmp[y][x] = color
  rescue
  end

  def get(x, y)
    @bmp[y][x]
  end

  def color(x, y)
    if get(x, y)
      black
    else
      gray
    end
  end

  def black
    Gosu::Color.new(0xff323229)
  end

  def gray
    Gosu::Color.new(0xff909082)
  end

  def width
    @bmp.first.size
  end

  def height
    @bmp.size
  end

  def dot_size
    10
  end

  def clear
    @bmp = Array.new(height).map { Array.new(width, false) }
  end

  def clear_color
    @window.draw_quad(
      0, 0, gray,
      width * dot_size, 0, gray,
      0, height * dot_size, gray,
      width * dot_size, height * dot_size, gray
    )
  end

  def blackout
    @bmp = Array.new(height).map { Array.new(width, true) }
  end

  def draw
    clear_color
    height.times do |y|
      width.times do |x|
        xx = x * dot_size
        yy = y * dot_size
        s = dot_size - 2
        @window.draw_quad(
          xx    , yy    , color(x, y),
          xx + s, yy    , color(x, y),
          xx    , yy + s, color(x, y),
          xx + s, yy + s, color(x, y)
        )
      end
    end
  end

  def draw_sprite(sprite)
    sprite.bmp.length.times do |y|
      sprite.bmp.first.length.times do |x|
        color = sprite.bmp[y][x]
        if color > 0
          set(sprite.x.to_i + x, sprite.y.to_i + y, color == 1)
        end
      end
    end
  end
end

class GameWindow < Gosu::Window
  attr_accessor :last_key_id

  def initialize
    super 320 * 4, 320 * 4, false
    self.caption = "Mono prototype"
  end

  def lcd
    @lcd ||= LCD.new(32 * 4, 32 * 4, self)
  end

  def game
    #@game ||= Game.new(lcd)
    #@game ||= Game.new(lcd)
    #@game ||= Game.new(lcd)
    #@game ||= DangerousOcean.new(lcd)
    @game ||= LazerBattle.new(lcd)
  end

  def update
    game.update
  end

  def draw
    lcd.draw
  end

  def button_down(id)
    @last_key_id = id
    @game.last_key_id = @last_key_id
  end

  def button_up(id)
    if @last_key_id == id
      @last_key_id = nil
      @game.last_key_id = last_key_id
    end
  end
end


class Game
  attr_accessor :last_key_id

  def initialize(lcd)
    @lcd = lcd
    start
  end

  def input(id)
    @last_key_id = id
  end

  def update
  end
end


class Rectangle
  attr_accessor :x, :y, :width, :height

  def initialize(x, y, width, height)
    @x = x
    @y = y
    @width = width
    @height = height
  end

  def intersect?(rect)
    [@x, rect.x].max <= [@x + @width, rect.x + rect.width].min &&
    [@y, rect.y].max <= [@y + @height, rect.y + rect.height].min
  end
end

class Sprite
  attr_accessor :x, :y

  def width
    bmp.size
  end

  def height
    bmp.first.size
  end

  def rect
    Rectangle.new(x, y, width, height)
  end

  def hit?(sprite)
    rect.intersect?(sprite.rect)
  end
end

class Ship < Sprite
  attr_accessor :accel
  attr_accessor :velocity

  def initialize
    @x = 0
    @y = 0

    @accel = 0
    @velocity = 0
  end

  def update
    @velocity += accel
    @x += @velocity
  end

  def bmp
    if velocity < -0.1
      bmp_left
    elsif velocity > 0.1
      bmp_right
    else
      bmp_front
    end
  end

  def bmp_front
    [
      [0,0,1,1,0,0],
      [0,1,1,1,1,0],
      [0,1,1,1,1,0],
      [0,1,1,1,1,0],
      [0,1,1,1,1,0],
      [0,1,1,1,1,0],
      [0,1,1,1,1,0],
      [0,0,1,1,0,0],
    ]
  end

  def bmp_right
    [
      [0,0,0,1,1,0],
      [0,0,1,1,1,1],
      [0,0,1,1,1,1],
      [0,1,1,1,1,0],
      [0,1,1,1,1,0],
      [1,1,1,1,0,0],
      [1,1,1,1,0,0],
      [0,1,1,0,0,0],
    ]
  end

  def bmp_left
    [
      [0,1,1,0,0,0],
      [1,1,1,1,0,0],
      [1,1,1,1,0,0],
      [0,1,1,1,1,0],
      [0,1,1,1,1,0],
      [0,0,1,1,1,1],
      [0,0,1,1,1,1],
      [0,0,0,1,1,0],
    ]
  end
end

class Obstacle < Sprite
  def initialize(x)
    @x = x
    @y = 0
  end

  def update
    @y += 0.8
  end

  def bmp
    [
      [0,1,0],
      [1,1,1],
      [0,1,0],
    ]
  end
end

class DangerousOcean < Game
  def start
    ship.x = 14
    ship.y = 22

    @obstacles = []
  end

  def update
    @lcd.clear
    draw_ship

    ship.accel = ship_accel
    ship.update

    if Random.rand(30) == 1
      @obstacles.push Obstacle.new(Random.rand(32))
    end

    @obstacles.clone.each do |obstacle|
      obstacle.update
      @lcd.draw_sprite obstacle
      if obstacle.y > 32
        @obstacles.delete(obstacle)
      end

      if obstacle.hit?(ship)
        #@lcd.blackout
      end
    end
  end

  def ship_accel
    if @last_key_id == Gosu::KbLeft
      -0.05
    elsif @last_key_id == Gosu::KbRight
      0.05
    else
      0
    end
  end

  def ship
    @ship ||= Ship.new
  end

  def draw_ship
    @lcd.draw_sprite(ship)
  end
end

require './lazer_battle.rb'

window = GameWindow.new
window.show

