#==============================================================================
# Copyright (C) 2012 Stephen F Norledge & Alces Software Ltd.
#
# This file is part of elfinder-rails.
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
        instance.volumes.clear
        block.call(instance)
      end
    end

    extend ClassMethods

    def volumes
      @volumes ||= []
    end

    def volume(volume)
      volumes << volume
    end
  end
end
