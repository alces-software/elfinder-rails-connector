#==============================================================================
# Copyright (C) 2007-2012 Stephen F Norledge & Alces Software Ltd.
#
# This file is part of elfinder-rails.
#
# Some rights reserved, see LICENSE.txt.
#==============================================================================
require 'rails'

module ElfinderRails
  require 'elfinder-rails/engine' if defined?(Rails)
  autoload :Server, 'elfinder-rails/server'
  autoload :Configuration, 'elfinder-rails/configuration'

  class Context < Struct.new(:env,:params); end

  class << self
    def file_headers(data, env)
      Hash.new.tap do |headers|
        headers['Content-Disposition'] = "#{data.disposition}; filename=\"#{data.filename}\"" 
        headers['Content-Type'] = data.mimetype
        if env['HTTP_USER_AGENT'] =~ /msie/i
          headers['Pragma'] = 'public'
          headers["Content-type"] = data.mimetype
          headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
          headers['Expires'] = "0" 
        end
      end
    end

    def volumes(ctx)
      ElfinderRails::Configuration.eval_config(ctx)
      ElfinderRails::Configuration.instance.volumes
    end
  end
end
