require "ember_cli/ember_constraint"
require "ember_cli/trailing_slash_constraint"

module ActionDispatch
  module Routing
    class Mapper
      def mount_ember_app(app_name, to:, **options)
        routing_options = options.deep_merge(
          defaults: { ember_app: app_name },
        )

        routing_options.reverse_merge!(
          controller: "ember_cli/ember",
          action: "index",
          format: :html,
        )

        scope constraints: ::EmberCli::EmberConstraint.new, path: to, as: "#{app_name}_ember" do
          
          root to: "#{routing_options[:controller]}##{routing_options[:action]}"
          
          # redirect_if_missing_trailing_slash = {
          #   constraints: EmberCli::TrailingSlashConstraint.new,
          #   to: redirect(-> (_, request) {
          #     File.join(request.original_fullpath, "")
          #   }),
          # }

          # already introduced root. check if we can redirect from the constraint?
          # get(to, redirect_if_missing_trailing_slash)
          yield(routing_options) if block_given?
          get("(*rest)", routing_options) #wildcard
        end

        mount_ember_assets(app_name, to: to)
      end

      def mount_ember_assets(app_name, to: "/")
        app = ::EmberCli[app_name]

        if app.mountable?
          mount app.to_rack => to
        end
      end
    end
  end
end
