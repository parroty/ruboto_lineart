class Color
  SPEED_BASE    = 2
  SPEED_VARIANT = 4

  attr_accessor :r, :g, :b
  attr_accessor :sr, :sg, :sb

  def initialize(r = 0, g = 0, b = 0)
    self.r = r
    self.g = g
    self.b = b
  end

  def rgb
    [self.r, self.g, self.b]
  end

  def speeds
    [self.sr, self.sg, self.sb]
  end

  def set_speeds(sr, sg, sb)
    self.sr = sr
    self.sg = sg
    self.sb = sb
  end

  def move!
    self.r, self.sr = Mover.update(self.r, self.sr, 256)
    self.g, self.sg = Mover.update(self.g, self.sg, 256)
    self.b, self.sb = Mover.update(self.b, self.sb, 256)
    self
  end

  def to_s
    "rgb(#{self.r},#{self.g},#{self.b})"
  end
end

class Point
  SPEED_BASE    = 10
  SPEED_VARIANT = 10

  attr_reader :x, :y
  attr_accessor :dx, :dy

  def initialize(x = 0, y = 0, dx = 0, dy = 0)
    self.x = x
    self.y = y
    self.dx = dx
    self.dy = dy
  end

  def next_position
    nx, ndx = Mover.update(self.x, self.dx, Lineart.screen_width)
    ny, ndy = Mover.update(self.y, self.dy, Lineart.screen_height)
    Point.new(nx, ny, ndx, ndy)
  end

  def x=(val)
    if val >= 0 and val <= Lineart.screen_width
      @x = val
    else
      raise RuntimeError, "invalid x value : #{val}. It should be between 0 and #{Lineart.screen_width}"
    end
  end

  def y=(val)
    if val >= 0 and val <= Lineart.screen_height
      @y = val
    else
      raise RuntimeError, "invalid y value : #{val}. It should be between 0 and #{Lineart.screen_height}"
    end
  end
end

class Polygon
  attr_accessor :color, :points

  def initialize(points = nil, color = nil)
    self.color = color || Generator.generate_color
    self.points = points || [Point.new] * Lineart::POINTS_NUM
  end

  def move
    self.points = self.points.map do |points|
      points.next_position
    end

    self.color.move!
  end
end

class Mover
  def self.update(pos, speed, border)
    pos += speed

    # when bounce at upper side
    if pos > border
      pos = (border * 2) - pos
      speed *= -1
    end

    # when bounce at lower side
    if pos < 0
      pos *= -1
      speed *= -1
    end

    [pos, speed]
  end
end

class Generator
  def self.generate_polygons(points, num)
    polygons = []
    color = generate_color
    num.times do |i|
      polygons << Polygon.new(points, color)

      points = points.map {|p| p.next_position }
      color  = generate_next_color(color)
    end
    polygons
  end

  def self.generate_points(xrange, yrange, num)
    points = []
    num.times do |i|
      points << Point.new(
        rand(xrange),
        rand(yrange),
        rand(Point::SPEED_VARIANT) + Point::SPEED_BASE,
        rand(Point::SPEED_VARIANT) + Point::SPEED_BASE
      )
    end
    points
  end

  def self.generate_color
    c = Color.new(rand(256), rand(256), rand(256))
    c.set_speeds(rand(Color::SPEED_VARIANT) + Color::SPEED_BASE,
                 rand(Color::SPEED_VARIANT) + Color::SPEED_BASE,
                 rand(Color::SPEED_VARIANT) + Color::SPEED_BASE)
    c
  end

  def self.generate_next_color(color)
    new_color = color.clone
    new_color.move!
  end
end

class Lineart
  SCREEN_WIDTH  = 320
  SCREEN_HEIGHT = 240
  POLYGON_NUM   = 10
  POINTS_NUM    = 4

  attr_accessor :polygons

  class << self
    attr_reader :screen_width, :screen_height
  end

  def initialize
    points = Generator.generate_points(SCREEN_WIDTH, SCREEN_HEIGHT, POINTS_NUM)
    polygons = Generator.generate_polygons(points, POLYGON_NUM)
    self.polygons = polygons
  end

  def move
    polygons.each do |polygon|
      polygon.move
    end
  end

  def self.reset
    @screen_width  = SCREEN_WIDTH
    @screen_height = SCREEN_HEIGHT
    @initialized = false
  end
  self.reset

  def self.init_screen_size(width, height)
    unless @initialized
      @screen_width  = width
      @screen_height = height
      @initialized = true
    else
      raise "it doesn't support changing screen size yet"
    end
  end
end