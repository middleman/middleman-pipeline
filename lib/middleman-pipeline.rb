require "middleman-core"
require "middleman-more"
require "middleman-pipeline/version"

Middleman::Extensions.register(:pipeline, Middleman::Pipeline::VERSION) do
  require "middleman-pipeline/extension"
  Middleman::Pipeline
end