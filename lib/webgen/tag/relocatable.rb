# -*- encoding: utf-8 -*-

require 'uri'

module Webgen
  class Tag

    # Makes a path relative. This is very useful for templates. For example, you normally include a
    # stylesheet in a template. If you specify the filename of the stylesheet directly, the reference
    # to the stylesheet in the output file of a page file that is not in the same directory as the
    # template would be invalid.
    #
    # By using the +relocatable+ tag you ensure that the path stays valid.
    module Relocatable

      # Return the relativized path for the path provided in the tag definition.
      def self.call(tag, body, context)
        path = context[:config]['tag.relocatable.path']
        result = ''
        begin
          result = (Webgen::Path.url(path, false).absolute? ? path : resolve_path(path, context))
        rescue URI::InvalidURIError => e
          raise Webgen::RenderError.new("Error while parsing path '#{path}': #{e.message}",
                                        self.name, context.dest_node, context.ref_node)
        end
        result
      end

      # Resolve the path +path+ using the reference node and return the correct relative path from the
      # destination node.
      def self.resolve_path(path, context)
        dest_node = context.ref_node.resolve(path, context.dest_node.lang)
        if dest_node
          context.website.ext.item_tracker.add(context.dest_node, :node_meta_info, dest_node.alcn)
          context.dest_node.route_to(dest_node)
        else
          context.website.logger.error { "Could not resolve path '#{path}' in <#{context.ref_node}>" }
          ''
        end
      end

    end

  end
end
