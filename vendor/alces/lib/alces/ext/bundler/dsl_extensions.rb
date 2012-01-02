require 'alces/ext/configuration'

module Alces
  module Ext
    module Bundler
      module DslExtensions
        def gem(*args)
          h = args.shift
          if h.is_a?(Hash) && h.has_key?(:local)
            DslExtensions.gem_local(self, h[:local], *args)
          else
            super(h,*args)
          end
        end

        class << self
          def gem_local(ctx, name, *args)
            if Alces::Ext::Configuration.development?
              require 'pathname'
              dir = File.expand_path(("../" * 8), Pathname.new(__FILE__).realpath)
              if File.directory?("#{dir}/#{name}")
                ctx.gem(name, :path => "#{dir}/#{name}")
                return
              end
            end
            ctx.gem name, *args
          end
        end
      end
    end
  end
end
