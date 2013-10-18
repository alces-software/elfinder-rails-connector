#==============================================================================
# Copyright (C) 2007-2012 Stephen F Norledge & Alces Software Ltd.
#
# This file is part of elfinder-rails-connector.
#
# Some rights reserved, see LICENSE.txt.
#==============================================================================
require 'rails'

module ElfinderRailsConnector
  require 'elfinder-rails-connector/engine' if defined?(Rails)
  autoload :Server, 'elfinder-rails-connector/server'
  autoload :Configuration, 'elfinder-rails-connector/configuration'

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
      ElfinderRailsConnector::Configuration.eval_config(ctx)
      ElfinderRailsConnector::Configuration.instance.volumes
    end
  end
end
