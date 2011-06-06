ChiScanner
===

Based on an offhand remark by @jdfrens about a video of the Chicago skyline
looking like an audio waveform. This sketch scans a screenshot of the video
and uses the average pixel value for each vertical slice to control the amp-
litude of a SuperCollider noise generator.

The sketch should run fine without SuperCollider but the noise generator is
included at the bottom of chi-scanner.rb. Copy and paste this synthdef into 
SuperCollider:

```SynthDef(\noiz, { |amp = 100|
  var noise = BrownNoise.ar(amp/100.00);
  Out.ar(0, noise ! 2);
}).store;
```

