# Merb::Router is the request routing mapper for the merb framework.
#
# You can route a specific URL to a controller / action pair:
#
#   match("/contact").
#     to(:controller => "info", :action => "contact")
#
# You can define placeholder parts of the url with the :symbol notation. These
# placeholders will be available in the params hash of your controllers. For example:
#
#   match("/books/:book_id/:action").
#     to(:controller => "books")
#   
# Or, use placeholders in the "to" results for more complicated routing, e.g.:
#
#   match("/admin/:module/:controller/:action/:id").
#     to(:controller => ":module/:controller")
#
# You can specify conditions on the placeholder by passing a hash as the second
# argument of "match"
#
#   match("/registration/:course_name", :course_name => /^[a-z]{3,5}-\d{5}$/).
#     to(:controller => "registration")
#
# You can also use regular expressions, deferred routes, and many other options.
# See merb/specs/merb/router.rb for a fairly complete usage sample.

Merb.logger.info("Compiling routes...")
Merb::Router.prepare do

  with(:controller => "articles") do
    match(/\/wiki\/File:(.*)/).to(:action => "file", :file => "[1]")
  
    match("/wiki/\:\:Home").to(:action => "home")
    match(/\/wiki\/::Random/).to(:action => "random")

    with(:action => "show") do
      # Primary HTML way to access information
      match(/\/wiki\/?(.*)/).to(:title => "[1]")
      match(/\/wiki\/?/).to(:action => "show")
      # Legacy support for iwik
      match(/\/lookup\/([a-z]*).wikipedia.org\/(.*)/).to(:title => "[2]", :lang => "[1]")

      # Support for links inside wikipedia that point to index.php
      match("/w/index.php").to(:controller => "articles", :action => "show")
    end
  end
  
  match(/\/w\/extensions\/(.*)/).to(:action => "not_found", :controller => "exceptions")
  
  # Disable this in production
  #match("/statistics/:action").to(:controller => "statistics")
  
  match("/").to(:controller => "articles", :action => "home")

end