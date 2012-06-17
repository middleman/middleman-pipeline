require "middleman-core/cli"

module Middleman
  module Pipeline

    # A template that generates a blog-specific config.rb
    # and a set of example templates for index, layout, tags, and calendar.
    class Assetfile < ::Thor
      include Thor::Actions
      check_unknown_options!
      
      namespace :assetfile
    
      def self.source_root
        File.join(File.dirname(__FILE__), 'template')
      end
  
      desc "assetfile", "Create an Assetfile for Rake::Pipeline"
      
      def assetfile
        template "Assetfile.tt", File.join(ENV["MM_ROOT"], "Assetfile")
      end
    end
  end
end