#==============================================================================
# Copyright (C) 2007-2012 Stephen F Norledge & Alces Software Ltd.
#
# This file is part of elfinder-rails-connector.
#
# Some rights reserved, see LICENSE.txt.
#==============================================================================
class ElfinderController < ::ActionController::Base
  module Base
    def api
      ctx = ElfinderRailsConnector::Context.new(request.env, params, session[:session_id])
      data = Arriba.execute(ElfinderRailsConnector.volumes(ctx),params)
      case data
      when Hash
        render :json => data
      when Arriba::FileResponse
        ElfinderRailsConnector.file_headers(data,request.env).each do |k,v|
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
