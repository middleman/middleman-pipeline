require "rake-pipeline"
require "rake-pipeline/middleware"
require "rake-pipeline-web-filters"

# Rake::Pipeline extension
module Middleman::Pipeline

  # Setup extension
  class << self

    # Once registered
    def registered(app, options={})
      app.after_configuration do
        ::Middleman::Sitemap::Resource.send :include, ResourceInstanceMethods
        
        asset_file = options[:Assetfile] || File.expand_path("Assetfile", root)
        input_path = options[:input] || "assets"
        
        instance = self
        
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
                
                filter ::Middleman::Pipeline::SitemapFilter, instance
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
            PipelineManager.new(self, pipeline, input_path),
            false
          )
          
          # use ::Rake::Pipeline::Middleware, pipeline
        end
      end
    end
    
    alias :included :registered
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
  
  class PipelineManager
    def initialize(app, pipeline, input_path)
      @app = app
      @pipeline = pipeline
      @input_path = input_path
    end
    
    # Update the main sitemap resource list
    # @return [void]
    def manipulate_resource_list(resources)
      @pipeline.invoke_clean
      
      # resources.each do |r|
      #   if r.path =~ %r{^#{@input_path}}
      #     r.pipeline_ignored = true
      #   end
      # end
      
      resources + @pipeline.output_files.map do |file|
        path = if file.path =~ %r{^#{@input_path}}
          file.path
        else
          File.join(@input_path, file.path)
        end
        
        ::Middleman::Sitemap::Resource.new(
          @app.sitemap,
          path,
          File.expand_path(path, @app.source_dir)
        )
      end
    end
  end
  
  class SitemapFilter < ::Rake::Pipeline::Filter
    def initialize(app, &block)
      @app = app
      
      super(&block)
      
      @output_name_generator = proc do |input|
        @app.sitemap.extensionless_path(input)
      end
    end
    
    def generate_output(inputs, output)
      inputs.each do |input|
        # resource = @app.sitemap.find_resource_by_path(input.path)
        
        out = if true || resource.nil?
          # input.read
          ""
        else
          resource.render
        end
        
        output.write out
      end
    end
  end

end