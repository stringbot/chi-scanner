require 'ruby-processing'

class ChiScanner < Processing::App
  load_libraries :oscP5, :supercollider
  import 'supercollider'
  import 'oscP5'

  load_libraries :video
  import 'processing.video'

  trap 'INT' do
    # ensure stop gets called on SIGINT
    $app.stop
    Thread.main.raise Interrupt
  end

  # creates the noiz synth in SC
  def setup_noiz_synth
    @synth = Synth.new("noiz")
    @synth.create
  end

  # sends an amplitude to the noiz synth
  def set_noiz_amp(amp)
    @synth.set('amp', amp);
  end

  # calculates the average value for each
  # vertical slice of the image
  def calc_noiz_values(image)
    nvals = []
    @image.width.times do |n|
      slice = @image.get(n,220,1,440)
      nvals[n] = average_red_value(slice)
    end
    nvals
  end

  # get average red value for an image
  def average_red_value(image)
    sum = image.pixels.inject(0) { |avg, color|
      avg + red(color)
    }
    avg = sum / image.pixels.length
    color(avg, avg, avg)
  end

  # processing setup
  def setup
    size 640,440
    background 0
    frame_rate 60
    no_stroke

    # load the chicago skyline image
    @image = loadImage("chitown.png")
    @image.loadPixels
    @index = 0

    # initialize the SC synth
    setup_noiz_synth

    # pre calculate average pixel values
    @nvals = calc_noiz_values(@image)

    @movie = MovieMaker.new($app, 640, 440, "chiscan.mov", 60, MovieMaker.ANIMATION, MovieMaker.HIGH);
  end

  def stop
    @synth.free
  end

  # processing draw loop
  def draw
    vwidth = 5
    @index = @index + vwidth
    @index = 0 if @index > @image.width - vwidth
    @movie.finish if @index > @image.width - vwidth


    # todo: fix magic numbers
    @viewport = @image.get(@index,220,vwidth+1,440)
    @viewport.resize 640,440
    @viewport.load_pixels
    image @viewport, 0,0

    avg = red(@nvals[@index])
    set_noiz_amp avg - 50
    fill color(avg)
    rect 0, 0, 25, 25
    @movie.add_frame
  end

end

__END__

// This goes into SuperCollider
// amp is integer based because of a bug/unexpected behavior in the supercollider bridge
// causing floats to be sent to SC as integers

SynthDef(\noiz, { |amp = 100|
	var noise = BrownNoise.ar(amp/100.00);
	Out.ar(0, noise ! 2);
}).store;

