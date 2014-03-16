require 'gosu'
require 'matrix'

class LCD
  def initialize(size_x, size_y, window)
    @window = window
    @bmp = Array.new(size_y).map { Array.new(size_x, false) }
  end

  def set(x, y, color)
    @bmp[y][x] = color
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
  def initialize
    super 320, 320, false
    self.caption = "Mono prototype"
  end

  def lcd
    @lcd ||= LCD.new(32, 32, self)
  end

  def game
    #@game ||= Game.new(lcd)
    #@game ||= Game.new(lcd)
    #@game ||= Game.new(lcd)
    @game ||= DangerousOcean.new(lcd)
  end

  def update
    game.update
  end

  def draw
    lcd.draw
  end
end


class Game
  def initialize(lcd)
    @lcd = lcd
  end

  def update
  end
end


class Sprite
  attr_accessor :x, :y
  attr_accessor :bmp

  def initialize(size_x, size_y)
    @bmp = Array.new(size_y) { Array.new(size_x) }
  end
end

class Ship < Sprite
  def initialize
    super(6, 12)

    @x = 0
    @y = 0

    @bmp = [
      [0,1,1,0],
      [1,1,1,1],
      [1,1,1,1],
      [1,1,1,1],
      [1,1,1,1],
      [1,1,1,1],
      [1,1,1,1],
      [0,1,1,0],
    ]
  end
end

class DangerousOcean < Game
  def update
    @lcd.clear
    draw_ship

    ship.x += 0.1
  end

  def ship
    @ship ||= Ship.new
  end

  def draw_ship
    @lcd.draw_sprite(ship)
  end
end






































window = GameWindow.new
window.show

























