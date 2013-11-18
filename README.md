Map-Tour
========

This is a simple iOS example that demonstrates how to animate location on a map view, pretty much like how the Uber app shows a map with their drivers driving around.

The idea is that the GPS data is being provided to the app from a remote source (i.e. the Uber drivers are transmitting their GPS coordinates), and the app is supposed to manage and render this data queue.

The process is pretty simple, but I learnt a couple of things along the way.

1. I had to do the animation interpolation by hand in order to obtain the level of control I needed.

2. I had to animate the map view around the center marker rather than animating marker on a static map view. The other way works too, but it results in a very unstable (jerky) animation.

The code itself is pretty simplistic and it is meant to demonstrate the concept. It is meant to be hacked and extended in order for it to be of any practical use. The GPS data used in this code is taken from Google Directions API.

Lastly, I should say that this is just my 'attempt' at doing location animation. Chances are my approach is completely wrong. In that case I would love to get some feedback and possibly get some pointers on the right/recommended approach.
