module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb

  def base_model!(name)
    resolved_model = model!(name)
    resolved_model.becomes(resolved_model.class.base_class)
  end

  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

    # the following are examples using path_to_pickle

    when /^#{capture_model}(?:'s)? page$/                           # eg. the forum's page
      path_to_pickle $1

    when /^#{capture_model}(?:'s)? #{capture_model}(?:'s)? page$/   # eg. the forum's post's page
      path_to_pickle $1, $2

    when /^#{capture_model}(?:'s)? #{capture_model}'s (.+?) page$/  # eg. the forum's post's comments page
      path_to_pickle $1, $2, :extra => $3                           #  or the forum's post's edit page

    when /^#{capture_model}(?:'s)? (.+?) page$/                     # eg. the forum's posts page
      path_to_pickle $1, :extra => $2                               #  or the forum's edit page

    # Namespaced routes

    when /the (.+?) #{capture_model}(?:'s)? (.+?) #{capture_model} page/ # the admin forum's new post page
      polymorphic_path [$3, $1.to_sym, model!($2), $4.to_sym]

    when /the (.+?) #{capture_model}(?:'s)? #{capture_model}'s (.+?) page/ # the admin forum's post's edit page
      nested_object = model!($3)
      polymorphic_path [$4.to_sym, $1.to_sym, model!($2), base_model!($3)]

    when /the (.*) page for #{capture_model}/
      polymorphic_path(model!($2), :action => $1.to_sym)

    when /the (.+?) #{capture_model}(?:'s)? page/
      polymorphic_path [$1.to_sym, model!($2)]

    when /the (.+?) #{capture_model} new page/
      polymorphic_path ['new', $1.to_sym, $2.to_sym]

    when /the (.+?) (.+?) listing page/
      polymorphic_path [$1.to_sym, $2.to_sym]

    when /the (.+?) #{capture_model}(?:'s)? (.+?) page/
      polymorphic_path [$3.to_sym, $1.to_sym, model!($2)]

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
