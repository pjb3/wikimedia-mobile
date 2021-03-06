require "parsers/xhtml"
require "parsers/image"

# # This is a non-database model file that focuses on handling parsing and providing information for
# the views having to do with articles.
#
# Each article should be unique based on title/server, but violation shouldn't have side effects
# 

class Article < Wikipedia::Resource
  
  # grabs a random article
  def self.random(server_or_lang = "en")
    article = Article.new(server_or_lang)
    article.fetch!("/wiki/Special:Random")
    article
  end
  
  # Caching whete
  def has_search_results?
    if (@html = Cache[key])
      Merb.logger.debug("CACHE HIT #{key}")
      return false
    else
      fetch! if raw_html.nil?
      raw_html.include?('var wgCanonicalSpecialPageName = "Search";')
    end
  end
  
  def search_results
    @search_results ||= Parsers::XHTML.search_results(self)
  end

  def suggestions
    @suggestions ||= Parsers::XHTML.suggestions(self)
  end
  
  # TODO: Get better file handling, right now I'm just calling back to regular HTML parser
  def file(device)
    @device = device
    fetch!
    html
  end

  def html
    return @html if @html 
    
    time_to "lookup in cache" do
      if (@html = Cache[key])
        Merb.logger.debug("CACHE HIT #{key}")
        return @html.force_encoding("UTF-8")
      else
        Merb.logger.debug("CACHE MISS #{key}")
      end
    end

    # Grab the html from the server object
    fetch! if raw_html.nil?

    time_to "parse #{device}" do
      # Figure out if we need to do extra formatting...
      case device.view_format
      when "html"
        Parsers::XHTML.parse(self, :javascript => device.supports_javascript)
      when "wml"
        Parsers::WML.parse(self)
      end
    end
    
    @html = @html.force_encoding("UTF-8")
    
    time_to "store in cache" do
      Cache.store(key, @html, :expires_in => 60 * 60 * 24)
    end

    return @html.force_encoding("UTF-8")
  end

  def fetch!(*paths)
    if !paths.any?
      paths = (@paths ||= ["/wiki/#{escaped_title}", "/wiki/Special:Search?search=#{uri_escaped_title}"])
    end
    super(*paths)
  end

  def to_hash(device)
    @device = device
    {:title => self.title, :html => self.html}
  end
  
  def key
    @key ||= "#{@server.host}|#{@title}|#{device.view_format}|#{device.supports_javascript}".gsub(" ", "-")
  end

end
