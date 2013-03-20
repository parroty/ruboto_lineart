require 'rspec'
require 'lineart'

TEST_RANDOM_VALUES = 5

describe 'Lineart' do
  describe 'polygons' do
    describe 'initializaion' do
      it 'generates predefined number of polygon by default' do
        Lineart.new.polygons.length.should == Lineart::POLYGON_NUM
      end

      it 'sets screen width and height' do
        Lineart.init_screen_size(1280, 768)

        Lineart.screen_width.should  == 1280
        Lineart.screen_height.should == 768
      end
    end

    describe 'drawing' do
      before do
        Generator.stub!(:rand).and_return(TEST_RANDOM_VALUES)
      end

      it 'prepares for drawing' do
        la = Lineart.new
        la.move
        la.polygons.length.should == Lineart::POLYGON_NUM
      end

      it 'moves points' do
        la = Lineart.new
        before_points = la.polygons.first.points # this test covers only first polygon
        la.move

        after_points = la.polygons.first.points
        before_points.length.times do |i|
          after_points[i].x.should == before_points[i].x + TEST_RANDOM_VALUES + Point::SPEED_BASE
          after_points[i].y.should == before_points[i].y + TEST_RANDOM_VALUES + Point::SPEED_BASE
        end
      end
    end

    describe 'polygon' do
      it 'has a color' do
        Lineart.new.polygons.each do |polygon|
          polygon.color.should_not be_nil
        end
      end

      it 'comprises of predefined points' do
        Lineart.new.polygons.each do |polygon|
          polygon.points.length.should == Lineart::POINTS_NUM
        end
      end
    end
  end
end

describe 'Point' do
  before do
    Lineart.reset
  end

  it 'has location (x, y) and speed (dx, dy)' do
    p = Point.new(100, 200, 3, 4)
    [p.x, p.y, p.dx, p.dy].should == [100, 200, 3, 4]
  end

  describe '#next_position' do
    it 'returns normal next position' do
      p = Point.new(100, 200, 3, 4)
      n = p.next_position

      [n.x, n.y, n.dx, n.dy].should == [103, 204, 3, 4] # return next
      [p.x, p.y, p.dx, p.dy].should == [100, 200, 3, 4] # keep original
    end

    it 'returns bounced max-x position' do
      p = Point.new(Lineart::SCREEN_WIDTH - 7, 0, 10, 5)
      n = p.next_position

      [n.x, n.y, n.dx, n.dy].should == [Lineart::SCREEN_WIDTH - 3, 5, -10, 5]
    end

    it 'returns bounced min-x position' do
      p = Point.new(3, 0, -10, 5)
      n = p.next_position

      [n.x, n.y, n.dx, n.dy].should == [7, 5, 10, 5]
    end
  end

  describe 'validations' do
    it 'should raise error if x value is invalid' do
      lambda {
        point = Point.new
        point.x = -1
      }.should raise_error

      lambda {
        point = Point.new
        point.x = Lineart::SCREEN_WIDTH + 1
      }.should raise_error
    end

    it 'should raise error if height is invalid' do
      lambda {
        point = Point.new
        point.y = -1
      }.should raise_error

      lambda {
        point = Point.new
        point.y = Lineart::SCREEN_HEIGHT + 1
      }.should raise_error
    end
  end
end

describe 'Generator' do
  before do
    Generator.stub!(:rand).and_return(TEST_RANDOM_VALUES)
  end

  describe 'polygon and point' do
    before do
      @points =
        Generator.generate_points(Lineart::SCREEN_WIDTH, Lineart::SCREEN_HEIGHT, Lineart::POINTS_NUM)
      @polygons =
        Generator.generate_polygons(@points, Lineart::POLYGON_NUM)
    end

    it 'generates point locations' do
      @points.length.should == Lineart::POINTS_NUM
      @points.each do |point|
        point.x.should  == TEST_RANDOM_VALUES
        point.y.should  == TEST_RANDOM_VALUES
        point.dx.should == TEST_RANDOM_VALUES + Point::SPEED_BASE
        point.dy.should == TEST_RANDOM_VALUES + Point::SPEED_BASE
      end
    end

    it 'generates polygon from points' do
      @polygons.length.should == Lineart::POLYGON_NUM
    end
  end

  describe 'color' do
    it 'generates random color' do
      c = Generator.generate_color
      c.rgb.should == [TEST_RANDOM_VALUES] * 3
    end

    it 'generates next color' do
      c1 = Generator.generate_color
      c2 = Generator.generate_next_color(c1)

      [c2.r, c2.g, c2.b].should == [c1.r, c1.g, c1.b].map {|v| v + TEST_RANDOM_VALUES + Color::SPEED_BASE}
    end

    it 'has a change speed' do
      c = Generator.generate_color
      c.speeds.should == [TEST_RANDOM_VALUES + Color::SPEED_BASE] * 3
    end
  end
end

describe 'Color' do
  it 'has RGB value' do
    c = Color.new(0, 100, 200)

    [c.r, c.g, c.b].should == [0, 100, 200]
  end

  it 'can set speeds' do
    c = Color.new(0, 100, 200)
    c.set_speeds(1, 2, 3)

    [c.sr, c.sg, c.sb].should == [1, 2, 3]
  end

  it 'transits based on its speed' do
    c = Color.new(0, 100, 200)
    c.set_speeds(1, 2, 3)
    c.move!

    c.rgb.should == [1, 102, 203]
  end

  it 'convers to string' do
    c = Color.new(0, 100, 200)

    c.to_s.should == 'rgb(0,100,200)'
  end
end

describe 'Mover' do
  it 'updates without bounce' do
    pos, speed = Mover.update(0, 3, 100)
    [pos, speed].should == [3, 3]
  end

  it 'bounce at upper side' do
    pos, speed = Mover.update(99, 5, 100)
    [pos, speed].should == [96, -5]
  end

  it 'bounce at lower side' do
    pos, speed = Mover.update(1, -5, 100)
    [pos, speed].should == [4, 5]
  end
end