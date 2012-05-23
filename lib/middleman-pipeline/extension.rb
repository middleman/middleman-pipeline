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
                
                filter ::Middleman::Pipeline::SitemapFilter, instance, input_path
                
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
            PipelineManager.new(self, pipeline, input_path),
            false
          )
          
          map("/#{input_path}")  { run ::Rake::Pipeline::Middleware.new(self, pipeline) }
          
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
      
      resources.each do |r|
        if r.path =~ %r{^#{@input_path}}
          r.pipeline_ignored = true
        end
      end
      
      resources + @pipeline.output_files.map do |file|
        path = File.join(@input_path, file.path)
        ::Middleman::Sitemap::Resource.new(
          @app.sitemap,
          path,
          File.expand_path(path, @app.source_dir)
        )
      end
    end
  end
  
  class SitemapFilter < ::Rake::Pipeline::Filter
    def initialize(app, input_path)
      @app = app
      @input_path = input_path
      
      @resource_for_path = {}
      
      block = proc do |input|
        resource = resource_for_path(input)
        
        if resource.template?
          extensionless = @app.sitemap.extensionless_path(input)
          @resource_for_path[extensionless] = resource
          extensionless
        else
          input
        end
      end
      
      super(&block)
    end
    
    def resource_for_path(path)
      @resource_for_path[path] ||= begin
        full_path = File.join(@input_path, path)
        
        ::Middleman::Sitemap::Resource.new(
          @app.sitemap,
          @app.sitemap.file_to_path(full_path),
          File.expand_path(full_path, @app.source_dir)
        )
      end
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