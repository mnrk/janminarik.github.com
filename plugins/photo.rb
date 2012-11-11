#
# Author: Jan Minárik

module Jekyll

  class PhotoTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      @pic_link = markup
      @pic_tn_link = @pic_link.gsub(/(\/[^\/]+)$/, "/tn\\1")
      super
    end

    def render(context)
      "<a href='#{@pic_link}'><img src='#{@pic_tn_link}' alt='' /></a>"
    end
  end
end

Liquid::Template.register_tag('photo', Jekyll::PhotoTag)
