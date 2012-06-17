require "middleman-core"
require "middleman-more"
require "middleman-pipeline/template"

Middleman::Extensions.register(:pipeline) do
  require "middleman-pipeline/extension"
  Middleman::Pipeline
end