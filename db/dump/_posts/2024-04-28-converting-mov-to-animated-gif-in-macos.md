---
layout: post
title: Converting MOV to Animated GIF in MacOS
date: 2024-04-28 18:38 +0800
description: How to convert a .mov file to an animated .gif file.
image: /assets/img/posts/poster-sudirmania.jpg
category: Work
tags: [rails, turbo, tutorial, gugel]
published: false
sitemap: false
---

How to convert a .mov file to an animated .gif file.

https://medium.com/@patdugan/converting-a-mov-to-a-gif-6bb055e54230

I recently had need to convert a .mov file into a .gif, specifically so I could create an animated image header for an email I was building at Nextdoor. After trying a few options all of which left me with low quality GIFs and high file sizes, I stumbled across this tutorial by Chris Messina.

Unfortunately, the tutorial was a bit out of date and no longer worked with the most recent versions of the software he recommended so I updated portions of his original explanation below.

To start with, you’ll need to install Homebrew, Gifsicle, and FFmpeg, which are all command line tools for Mac OSX.

Within the Terminal application on Mac:

## 1. Install Homebrew 

Skip to the next step if you already have Homebrew set up.

In the general tech context, "homebrew" refers to the practice of creating or modifying hardware or software systems, often outside of commercial or official channels. It involves enthusiasts or developers crafting solutions tailored to their specific needs, often leveraging open-source tools and resources. This can encompass activities like building custom computers, creating DIY electronics projects, or developing software applications independently.

Homebrew for macOS specifically is a package manager that provides a convenient way to install open-source software and command-line tools on a Mac computer. It utilizes the Terminal app to install packages with simple commands, making it easier for users to maintain their software ecosystem.

Install Homebrew from your Terminal:

ruby -e “$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
Install ffmpeg (a video conversion tool):

brew install ffmpeg
Install gifsicle (a gif optimization tool):

brew install gifsicle
Navigate to the directory where your movie is (src.mov), and execute these commands in order to convert your movie into a series of PNGs:

mkdir ./pngs 
ffmpeg -i src.mov -r 10 ./pngs/out%04d.png 
Next, convert the individual PNGs you just created into GIFs:

mkdir ./gifs
sips -s format gif ./pngs/*.png --out ./gifs
Finally, combine those individual GIF files into a single animated GIF:

cd ./gifs
gifsicle --optimize=3 --resize=720x450 --delay=10 --loopcount *.gif > animation.gif
In the example above, I passed in several command line arguments which generated an animated GIF with:

gifsicle: warning: huge GIF, conserving memory (processing may take a while)
gifsicle: warning: too many colors, using local colormaps
  (You may want to try '--colors 256'.)


An infinite loop
Set it to a resolution of 1072px x 444px
Set a delay of 0.10ms between each frame
Refer to the Gifsicle documentation page for a huge list of further optimizations.

It’s a little silly, but here is the final result of the GIF I made. It’s for a promotional email for the Nextdoor Treat Map.