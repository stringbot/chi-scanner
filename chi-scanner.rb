require 'ruby-processing'

class Sketch < Processing::App
  load_libraries :oscP5, :supercollider
  import 'supercollider'
  import 'oscP5'

  import 'processing.video'

  # stop the synth on Ctrl-C
  trap 'INT' do
    $app.stop
    Thread.main.raise Interrupt
  end

  def setup_noiz_synth
    @synth = Synth.new("noiz")
    @synth.create
  end

  def set_noiz_amp(amp)
    @synth.set('amp', amp);
  end

  def precalc_noiz_values(image)
    nvals = []
    @image.width.times do |n|
      slice = @image.get(n,220,1,440)
      nvals[n] = average_value(slice)
    end
    nvals
  end

  def setup
    size 640,440
    background 0
    frame_rate 60
    no_stroke

    @image = loadImage("chitown.png")
    @image.loadPixels
    @index = 0

    setup_noiz_synth
    @nvals = precalc_noiz_values(@image)
  end

  def draw
    vwidth = 5
    @index = @index + vwidth
    @index = 0 if @index > @image.width - vwidth

    @viewport = @image.get(@index,220,vwidth+1,440)
    # @viewport.filter THRESHOLD, 0.5
    @viewport.resize 640,440
    @viewport.load_pixels
    image @viewport, 0,0

    avg = red(@nvals[@index])
    set_noiz_amp avg - 50
    fill color(avg)
    rect 0, 0, 25, 25
  end

  def average_value(image)
    sum = image.pixels.inject(0) { |avg, color|
      avg + red(color)
    }
    avg = sum / image.pixels.length
    color(avg, avg, avg)
  end

  def stop
    @synth.free
  end
end

__END__

// This goes into SuperCollider
// amp is integer based because of a bug? in the supercollider bridge
// that floors all floats :(

SynthDef(\noiz, { |amp = 100|
	var noise = BrownNoise.ar(amp/100.00);
	Out.ar(0, noise ! 2);
}).store;

