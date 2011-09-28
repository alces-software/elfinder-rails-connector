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

#ARRIBA_PATH=Rails.root.join('..','arriba','lib')
#load File.join(ARRIBA_PATH,'arriba.rb')

class ElfinderController < ::ActionController::Base
  module ClassMethods
    def render_file_response(controller,r)
      controller.headers['Content-Disposition'] = "#{r.disposition}; filename=\"#{r.filename}\"" 
      if controller.request.env['HTTP_USER_AGENT'] =~ /msie/i
        controller.headers['Pragma'] = 'public'
        controller.headers["Content-type"] = r.mimetype
        controller.headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
        controller.headers['Expires'] = "0" 
      end
      controller.render :text => r.io.read, :content_type => r.mimetype
    end
  end

  module Base
    def api
      data = Arriba::execute(volumes,params)
      case data
      when Hash
        render :json => data
      when Arriba::FileResponse
        self.class.render_file_response(self,data)
      else
        render :json => {:error => "Unsupported data type: #{data.class.name}"}
      end
    end
    
    private
    def volumes
      ElfinderRails::Configuration::eval_config(self)
      ElfinderRails::Configuration.instance.volumes
    end
  end

  extend ClassMethods
  include Base
end

