require_dependency 'html/pipeline/inline_markdown_filter'
require_dependency 'html/pipeline/kitsu_mention_filter'

LongPipeline = HTML::Pipeline.new [
  HTML::Pipeline::InlineMarkdownFilter,
  HTML::Pipeline::SanitizationFilter,
  HTML::Pipeline::KitsuMentionFilter,
  HTML::Pipeline::AutolinkFilter
], base_url: '/user/',
   link_attr: 'target="_blank" rel="nofollow" class="autolink"'
