#==============================================================================
# Copyright (C) 2012-2013 Stephen F Norledge & Alces Software Ltd.
#
# This file is part of elfinder-rails-connector.
#
# Some rights reserved, see LICENSE.txt.
#==============================================================================
module ElfinderRails
  class Engine < Rails::Engine
    engine_name :elfinder_rails

    initializer "elfinder-rails.assets.precompile" do |app|
      ['images/**/*.{png,gif}', 'sounds/**/*.{wav}'].each do |glob|
        app.config.assets.precompile += Dir[Engine.root.join('vendor','assets',glob)]
      end
    end
  end
end
