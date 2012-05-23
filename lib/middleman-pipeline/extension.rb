require "rake-pipeline"
require "rake-pipeline/middleware"

# Rake::Pipeline extension
module Middleman::Pipeline

  # Setup extension
  class << self

    # Once registered
    def registered(app, options={})
      app.after_configuration do
        asset_file = options[:Assetfile] || File.expand_path("Assetfile", root)
        input_path = options[:input] || "assets"
        
        if asset_file.is_a?(String)
          begin
            pipeline_source = File.read(asset_file)
            
            if pipeline_source =~ /^input/
              puts "== Warning: Do not include 'input' directive in Assetfile"
            end
            
            if pipeline_source =~ /^output/
              puts "== Warning: Do not include 'output' directive in Assetfile"
            end

            full_input_path  = File.expand_path(input_path, source_dir)
            full_output_path = File.expand_path(".pipeline-tmp", root)

            final_asset_source = <<END
              build do
                input "#{full_input_path}"
                output "#{full_output_path}"
                #{pipeline_source}
              end
END
          rescue
            puts "== Error: Could not read Assetfile (#{asset_file})"
          end
          
          if final_asset_source
            pipeline = ::Rake::Pipeline.class_eval final_asset_source, asset_file, 1
          end
        else
          pipeline = asset_file
        end
        
        if pipeline
          sitemap.register_resource_list_manipulator(
            :pipeline,
            PipelineManager.new(self, pipeline),
            false
          )
          
          use ::Rake::Pipeline::Middleware, pipeline
        end
      end
    end
    
    alias :included :registered
  end
  
  class PipelineManager
    def initialize(app, pipeline)
      @app = app
      @pipeline = pipeline
    end
    
    # Update the main sitemap resource list
    # @return [void]
    def manipulate_resource_list(resources)
      @pipeline.invoke_clean

      resources + @pipeline.output_files.map do |file|
        ::Middleman::Sitemap::Resource.new(
          @app.sitemap,
          file.path,
          File.expand_path(file.path, @app.root)
        )
      end
    end
  end

end