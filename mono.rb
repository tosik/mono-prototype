require 'gosu'

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
    @window.draw_quad(
      0, 0, gray,
      width * dot_size, 0, gray,
      0, height * dot_size, gray,
      width * dot_size, height * dot_size, gray,
    )
  end

  def draw
    clear
    height.times do |y|
      width.times do |x|
        xx = x * dot_size
        yy = y * dot_size
        s = dot_size - 3
        @window.draw_quad(
          xx    , yy    , color(x, y),
          xx + s, yy    , color(x, y),
          xx    , yy + s, color(x, y),
          xx + s, yy + s, color(x, y)
        )
      end
    end
  end
end

class GameWindow < Gosu::Window
  def initialize
    super 480, 480, false
    self.caption = "Mono prototype"
  end

  def lcd
    @lcd ||= LCD.new(32, 32, self)
  end

  def update
    lcd.set(Random.rand(31), Random.rand(31), Random.rand(2) == 1)
  end

  def draw
    lcd.draw
  end
end

window = GameWindow.new
window.show
