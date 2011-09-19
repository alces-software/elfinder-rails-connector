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

ARRIBA_PATH=Rails.root.join('..','arriba','lib')
load File.join(ARRIBA_PATH,'arriba.rb')

class ElfinderController < ::ActionController::Base
  class << self
    def volumes
      @volumes ||= [
        Arriba::Volume::Directory.new('scratch1','Home','/tmp/scratch'),
        Arriba::Volume::Directory.new('scratch2','Scratch 2','/tmp/scratch2'),
        Arriba::Volume::Directory.new('home','markt Home','/Users/markt'),
        Arriba::Volume::Directory.new('docs','Documents','/Users/markt/Documents')
      ]
    end
  end

  delegate :volumes, :to => self

  def api
    data = Arriba::execute(volumes,params)
    case data
    when Hash
      render :json => data
    when String
      render :text => data
    else
      render :json => {:error => "Unsupported data type: #{data.class.name}"}
    end
  end
end

