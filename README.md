
##############
# Overview
##############

This code has been written to split apart large CSS files (>4096 selectors) that are created by sass/compass compilation.


##############
# Usage
##############

1) Install the ruby gem, or import using the following line:
require "css_splitter"

2) At the end of your config.rb, add this:
on_stylesheet_saved do |path|
  CssSplitter.split(path) if path[/\.css$/]
end
