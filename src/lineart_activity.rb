require 'ruboto/widget'
require 'lib/lineart'

java_import android.graphics.Paint

class LineartView < android.view.SurfaceView
  def initialize(context)
    super
    $initialized = false

    $holder = getHolder
    $holder.addCallback(Callback.new)
    $runnable = Runnable.new
  end

  class Runnable
    attr_writer :attached, :width, :height
    def run
      unless $initialized
        Lineart.init_screen_size(@width, @height)
        $lineart = Lineart.new

        $initialized = true
      end

      @attached = true
      while @attached
        canvas = $holder.lockCanvas

        if canvas
          canvas.drawColor(android.graphics.Color::BLACK)
          paint = Paint.new

          $lineart.polygons.each do |polygon|
            color  = polygon.color
            points = polygon.points

            points.length.times do |i|
              paint.setColor(android.graphics.Color.argb(255, color.r, color.g, color.b))
              paint.setStrokeWidth(2.0)
              paint.setAntiAlias(true)
              canvas.drawLine(
                points[i].x, points[i].y,
                points[(i + 1) % Lineart::POINTS_NUM].x, points[(i + 1) % Lineart::POINTS_NUM].y,
                paint)
            end

          end
          $holder.unlockCanvasAndPost(canvas)
          $lineart.move
        end
      end
    end
  end

  class Callback
    def surfaceCreated(holder)
      rect = holder.getSurfaceFrame
      $runnable.width  = rect.right - rect.left
      $runnable.height = rect.bottom - rect.top

      @thread = java.lang.Thread.new($runnable)
      @thread.start
    end

    def surfaceChanged(holder, format, width, height)
      $runnable.width  = width
      $runnable.height = height
    end

    def surfaceDestroyed(holder)
      $runnable.attached = false
      while @thread.isAlive
      end
    end
  end
end

class LineartActivity
  def on_create(bundle)
    super
    set_title 'Lineart Sample'
    setContentView(LineartView.new(self))
  end
end
