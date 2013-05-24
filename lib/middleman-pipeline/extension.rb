require "rake-pipeline"
require "rake-pipeline/middleware"
require "rake-pipeline-web-filters"

module Middleman
  module Pipeline

    class Pipeline < Extension
      option :Assetfile, 'Assetfile', 'Filename to read Rack-Pipeline config from'
      option :input, 'assets', 'Source input folder'

      def initialize(app, options_hash={}, &block)
        super

        ::Middleman::Sitemap::Resource.send :include, ResourceInstanceMethods
      end

      def after_configuration
        asset_file = File.expand_path(options[:Assetfile], app.root)
      
        ::Middleman::Pipeline::Filter.instance = app
        ::Middleman::Pipeline::Filter.input_path = options[:input]

        begin
          pipeline_source = File.read(asset_file)
        rescue
          puts "== Error: Could not read Assetfile (#{asset_file})"
          pipeline_source = ""
        end
        
        if pipeline_source =~ /^input/
          puts "== Warning: Do not include 'input' directive in Assetfile"
        end
        
        if pipeline_source =~ /^output/
          puts "== Warning: Do not include 'output' directive in Assetfile"
        end

        full_input_path  = File.expand_path(options[:input], app.source_dir)
        full_output_path = File.expand_path(".pipeline-tmp", app.root)

        final_asset_source = <<END
          build(:tmpdir => ".pipeline-tmp") do
            input "#{full_input_path}"
            output "#{full_output_path}"
                          
            # Run Middleman on files first
            filter ::Middleman::Pipeline::Filter

            #{pipeline_source}
          end
END

        @pipeline = ::Rake::Pipeline.class_eval final_asset_source, asset_file, 1
      end

      # Update the main sitemap resource list
      # @return [void]
      def manipulate_resource_list(resources)
        @pipeline.invoke_clean
        
        resources.each do |r|
          if r.path =~ %r{^#{options[:input]}}
            r.pipeline_ignored = true
          end
        end
        
        resources + @pipeline.output_files.map do |file|
          PipelineResource.new(@app, self, file)
        end
      end
    end

    class PipelineResource < ::Middleman::Sitemap::Resource
      def initialize(app, ext, file)
        @app = app
        @ext = ext
        @file = file

        super(
          @app.sitemap,
          File.join(@ext.options[:input], @file.path),
          @file.fullpath
        )
      end

      def render
        @file.read
      end

      def ignored?
        false
      end

      def binary?
        false
      end

      def raw_data
        {}
      end

      def metadata
        @local_metadata
      end
    end
    
    module ResourceInstanceMethods
      def pipeline_ignored?
        @_pipeline_ignored || false
      end
      
      def pipeline_ignored=(v)
        @_pipeline_ignored = v
      end
      
      def ignored?
        if pipeline_ignored?
          true
        else
          super
        end
      end
    end
    
    class Filter < ::Rake::Pipeline::Filter
      class << self
        attr_accessor :instance
        attr_accessor :input_path
      end
      
      def initialize
        @app = self.class.instance
        @input_path = self.class.input_path
        
        block = proc do |input|
          resource = resource_for_path(input)
          
          if resource.template?
            @app.sitemap.extensionless_path(input)
          else
            input
          end
        end
        
        super(&block)
      end
      
      def resource_for_path(path)
        full_path = File.join(@input_path, path)
        fuller_path = File.join(@app.source, @input_path, path)
        
        ::Middleman::Sitemap::Resource.new(
          @app.sitemap,
          @app.sitemap.file_to_path(fuller_path),
          File.expand_path(fuller_path, @app.root)
        )
      end
          
      def generate_output(inputs, output)
        inputs.each do |input|
          resource = resource_for_path(input.path)

          out = if resource.template?
            resource.render
          else
            input.read
          end

          output.write out
        end
      end
    end
  end
end