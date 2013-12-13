#==============================================================================
# Copyright (C) 2012 Stephen F Norledge & Alces Software Ltd.
#
# This file is part of elfinder-rails-connector.
#
# Some rights reserved, see LICENSE.txt.
#==============================================================================
require 'singleton'

require 'active_support/core_ext/string/inflections'

module ElfinderRailsConnector
  class Configuration
    include Singleton

    module ClassMethods
      attr_writer :config_file, :environment

      def config_file
        @config_file ||= Rails.root.join('config','volumes.rb')
      end

      def load_config
        if production?
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

      def production?
        if @environment.nil?
          Rails.env.production?
        else
          @environment == :production
        end
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
