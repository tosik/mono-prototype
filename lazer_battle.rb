class Entity < Sprite
  attr_accessor :logical_x
  attr_accessor :logical_y

  def initialize(x, y)
    @logical_x = x
    @logical_y = y
  end

  def update
    @x = logical_x * 5
    @y = logical_y * 5
  end
end

class Pod < Entity
  def bmp
    [
      [0,1,1,1,0],
      [1,1,0,1,1],
      [1,0,0,0,1],
      [1,1,0,1,1],
      [0,1,1,1,0],
    ]
  end
end

class Arrow < Entity
end

class ArrowLeft < Arrow
  def bmp
    [
      [0,0,1,0,0],
      [0,1,1,1,1],
      [1,1,1,1,1],
      [0,1,1,1,1],
      [0,0,1,0,0],
    ]
  end
end

class ArrowRight < Arrow
  def bmp
    [
      [0,0,1,0,0],
      [1,1,1,1,0],
      [1,1,1,1,1],
      [1,1,1,1,0],
      [0,0,1,0,0],
    ]
  end
end

class ArrowUp < Arrow
  def bmp
    [
      [0,0,1,0,0],
      [0,1,1,1,0],
      [1,1,1,1,1],
      [0,1,1,1,0],
      [0,1,1,1,0],
    ]
  end
end

class ArrowDown < Arrow
  def bmp
    [
      [0,1,1,1,0],
      [0,1,1,1,0],
      [1,1,1,1,1],
      [0,1,1,1,0],
      [0,0,1,0,0],
    ]
  end
end

class LazerBattle < Game
  def start
    @pods = [Pod.new(1, 2), Pod.new(3, 4)]
    @arrows = [ArrowLeft.new(10, 15), ArrowRight.new(9, 18), ArrowUp.new(2, 8), ArrowDown.new(6, 3)]
  end

  def update
    p1 = @pods.first
    mob = get_mob
    p1.logical_x += mob[0]
    p1.logical_y += mob[1]

    @lcd.clear

    @pods.each do |pod|
      pod.update
      draw_entity(pod)
    end

    @arrows.each do |arrow|
      arrow.update
      draw_entity(arrow)
    end
  end

  def get_mob
    if @last_key_id == Gosu::KbLeft
      [-1, 0]
    elsif @last_key_id == Gosu::KbRight
      [1, 0]
    elsif @last_key_id == Gosu::KbUp
      [0, -1]
    elsif @last_key_id == Gosu::KbDown
      [0, 1]
    else
      [0, 0]
    end
  end

  def draw_entity(entity)
    @lcd.draw_sprite(entity)
  end
end

