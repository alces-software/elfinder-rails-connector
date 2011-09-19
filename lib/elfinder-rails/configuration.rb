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
require 'singleton'

module ElfinderRails
  class Configuration
    include Singleton

    module ClassMethods
      def config_file
        Rails.root.join('config','volumes.rb')
      end

      def load_config
        if Rails.env.production?
          @config ||= IO.read(config_file)
        else
          @config = IO.read(config_file)
        end
      end

      def eval_config(context)
        context.instance_eval(load_config)
      end

      def configure(&block)
        block.call(instance)
      end
    end

    extend ClassMethods

    def volumes
      @volumes ||= []
    end

    def volume(type, *args)
      volumes << Arriba::Volume::const_get(type.to_s.camelize).new(*args)
    end
  end
end
