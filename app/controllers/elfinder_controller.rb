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
class ElfinderController < ::ActionController::Base
  module Base
    def api
      ctx = ElfinderRails::Context.new(request.env, params, session[:session_id])
      data = Arriba.execute(ElfinderRails.volumes(ctx),params)
      case data
      when Hash
        render :json => data
      when Arriba::FileResponse
        ElfinderRails.file_headers(data,request.env).each do |k,v|
          headers[k] = v
        end
        render :text => data.io.read, :content_type => data.mimetype
      else
        render :json => {:error => "Unsupported data type: #{data.class.name}"}
      end
    rescue
      render :json => {:error => $!.message}
    end
  end

  include Base
end
