#==============================================================================
# Copyright (C) 2007-2011 Stephen F Norledge & Alces Software Ltd.
#
# This file is part of elfinder-rails.
#
# elfinder-rails is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#                                                                               
# You should have received a copy of the GNU Affero General Public License
# along with this software.  If not, see <http://www.gnu.org/licenses/>.
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
      ElfinderRails::Configuration::eval_config(ctx)
      ElfinderRails::Configuration.instance.volumes
    end
  end
end
