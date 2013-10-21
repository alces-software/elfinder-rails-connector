require 'alces/ext/configuration'

module Alces
  module Ext
    module Bundler
      module DslExtensions
        def gem(*args)
          h = args.last
          if h.is_a?(Hash) && h.key?(:local)
            DslExtensions.gem_local(self, h.delete(:local), *args)
          else
            super
          end
        end

        def require_under(platform)
          {}.tap do |h|
            h[:require] = false unless RUBY_PLATFORM =~ platform
          end
        end

        class << self
          def gem_local(ctx, local, *args)
            if Alces::Ext::Configuration.development?
              h = args.pop
              if local == true || ::Bundler::VERSION < '1.2.0'
                require 'pathname'
                dir = File.expand_path(("../" * 8), Pathname.new(__FILE__).realpath)
                if File.directory?("#{dir}/#{args.first}")
                  ctx.gem(*args, h.merge(path: "#{dir}/#{args.first}"))
                  return
                end
              else
                if Alces::Ext::Configuration.remote?
                  ctx.gem(*args,
                          h.merge(git: "#{Alces::Ext::Configuration.git_root}/#{args.first}",
                                  branch: local.to_s))
                else
                  ctx.gem(*args,
                          h.merge(git: args.first,
                                  branch: local.to_s))
                end
                return
              end
            end
            ctx.gem(*args)
          end
        end
      end
    end
  end
end
