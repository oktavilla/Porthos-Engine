require_relative '../../test_helper'
class PagesTest < ActiveSupport::IntegrationCase
  setup do
    login!
    @page_template = Factory.create(:hero_page_template)
  end

  test 'listing pages' do
    Page.create_from_template(@page_template, :title => 'Page no1', :tag_names => 'tag1 tag2')
    visit admin_items_path
    assert page.find("table.pages").has_content?('Page no1'), 'Should display page in the pages list'
  end

  test 'searching for pages' do
    Capybara.using_driver(:webkit) do
      test_page = Page.create_from_template(@page_template, :title => 'Page no1', :tag_names => 'tag1 tag2')
      stub_searchify_put
      stub_request(:get, /api.searchify.com\/v1\/indexes\//).
        to_return(:status => 200, :body => "{
            \"matches\": 1,
            \"query\": \"title:(test) OR uri:(test) OR tag_names:(test) OR data:(test) OR __any:(test) __type:(Page)\",
            \"facets\": {},
            \"search_time\": \"0.005\",
            \"results\": [{\"docid\": \"Page #{test_page.id.to_s}\", \"__type\": \"Page\", \"__id\": \"#{test_page.id.to_s}\", \"query_relevance_score\": -6861131.0}] }")
      User.delete_all
      login!
      visit admin_items_path
      fill_in 'query', :with => 'no1'
      page.execute_script("$('#items_search').submit()") # faking hitting enter in search form
      within 'table.pages' do
        assert page.has_content?('Page no1'), 'should see campaign in search results list'
        assert page.has_content?(@page_template.label), 'should see page template label in search results list'
      end
    end
  end

  test 'listning pages by tag' do
    page1 = Page.create_from_template(@page_template, :title => 'Page no1', :tag_names => 'tag1 tag2')
    page2 = Page.create_from_template(@page_template, :title => 'Page no2', :tag_names => 'tag2')
    page3 = Page.create_from_template(@page_template, :title => 'Page no3', :tag_names => 'tag1 tag3')

    visit admin_items_path(:tags => ['tag1'])

    assert page.find("table.pages").has_content?(page1.title), 'Should display page1 in the pages list'
    assert page.find("table.pages").has_content?(page3.title), 'Should display page2 the pages list'
    refute page.find("table.pages").has_content?(page2.title), 'Should not display page2 in the pages list'
  end

  test 'creating a page' do
    visit admin_items_path

    within('#sub_nav') do
      click_link @page_template.label
    end

    within('.tools') do
      click_link I18n.t(:'admin.items.index.create_new', :template => @page_template.label.downcase)
    end

    assert_equal new_admin_item_path, current_path

    fill_in 'item_title', :with => 'Batman'
    fill_in 'item_uri', :with => 'batman'
    click_button I18n.t(:save)

    assert page_was_saved?
    assert_equal 'Batman', page.find('h1').text
  end

  test 'updating page details' do
    Capybara.using_driver(:webkit) do
      User.delete_all
      login!
      batman = create_page
      visit admin_item_path(batman)
      within '#item_attributes' do
        click_link I18n.t(:edit)
      end
      within 'form.edit_item' do
        fill_in 'item_title', :with => 'Robin'
        click_button I18n.t(:save)
      end

      assert page_was_saved?
      assert page.find('.header .page_title h1').has_content?('Robin')
    end
  end

  test 'marking a page as restricted' do
    batman = create_page
    node = Node.create(:controller => 'pages', :action => 'show', :resource => batman, :url => 'the-dark-knight')
    visit admin_item_path(batman)
    publish

    visit page_path(batman)

    assert page.has_content?(batman.title)

    visit admin_item_path(batman)

    within '.header' do
      click_link I18n.t('edit')
    end

    within '.header form.edit_item' do
      check 'item_restricted'
      click_button I18n.t(:save)
    end
    assert page_was_saved?

    logout!
    visit page_path(batman)

    assert_equal admin_login_path, current_path
  end

  test 'publishing a page' do
    batman = create_page
    batman.data.each { |d| d.required = false } && batman.save

    assert batman.valid?

    visit admin_item_path(batman.id)
    publish

    assert published?, "Should get published"
  end

  test 'unpublishing a page' do
    batman = create_page
    batman.data.each { |d| d.required = false } && batman.save
    visit admin_item_path(batman.id)
    publish
    assert published?, "Should get published"
    unpublish
    refute published?, "Should get unpublished"
  end

  test 'editing page datum attributes' do
    batman = create_page
    visit admin_item_path(batman.id)

    within "form#datum_#{batman.data['tagline'].id}_edit" do
      fill_in 'Tagline', :with => 'Evil Fears The Knight'
      click_button I18n.t(:save)
    end

    assert page_was_saved?
    assert page.has_content?('Evil Fears The Knight'), "Should find the tagline within content"
  end

  test 'categorizing a page' do
    Capybara.using_driver(:webkit) do
      # Need to reset env/session for webkit
      User.delete_all
      login!
      @page_template.update_attribute(:allow_categories, true)
      new_page = Page.create_from_template(@page_template, :title => 'Category page')
      visit admin_item_path(new_page)

      within '#page_category' do
        click_link I18n.t(:'admin.items.details.choose_category')
        click_link I18n.t(:'admin.items.details.add_new_category')
        fill_in "item_category_name", :with => 'Beverages'
        click_button I18n.t(:save)
      end

      assert page.find('#page_category').has_content?('Beverages'), 'Category should be added'
      refute page.find('#page_tags p').has_content?('Beverages'), 'category should not be listed as a tag'
    end
  end

  test 'changing category for a page' do
    Capybara.using_driver(:webkit) do
      User.delete_all
      login!
      @page_template.update_attribute(:allow_categories, true)
      sausage_page = Factory.create(:page, :page_template => @page_template, :"#{@page_template.handle}_tag_names" => 'Sausages')
      new_page = Factory.create(:page, :page_template => @page_template, :"#{@page_template.handle}_tag_names" => 'Beverages')
      visit admin_item_path(new_page)
      click_link I18n.t(:'admin.items.details.edit_category')
      select 'Sausages', :from => "item_#{@page_template.handle}_tag_names"
      click_button I18n.t(:choose)
      assert page.find('#page_category p').has_content?('Sausages'), "Category should be added"
    end
  end

  test 'adding a note to a page' do
    Capybara.using_driver(:webkit) do
      User.delete_all
      login!
      new_page = Page.create_from_template(@page_template, :title => 'Category page')
      visit admin_item_path(new_page)

      click_link I18n.t(:'admin.items.details.add_note')
      fill_in "item_note", :with => 'Pretty awesome'
      click_button I18n.t(:save)

      assert page.find('#page_note').has_content?('Pretty awesome'), 'note should be added'
    end
  end

  test 'deleting a page' do
    a_page = create_page
    visit admin_item_path(a_page)

    within 'div.header' do
      click_link I18n.t(:destroy)
    end

    assert_equal admin_items_path, current_path
    assert has_flash_message?(I18n.t(:'app.admin_general.deleted'))
  end

protected

  def create_page(attrs = {})
    Page.create_from_template(@page_template, { title: 'Batman' }.merge(attrs))
  end

  def page_was_saved?
    has_flash_message? I18n.t(:'app.admin_items.saved')
  end

  def publish
    within "#page_current_publish_on_date" do
      click_link I18n.t(:'admin.items.details.publish_now')
    end
  end

  def unpublish
    within "#page_current_publish_on_date" do
      click_link I18n.t(:'admin.items.details.unpublish')
    end
  end

  def published?
    !page.has_content? I18n.t(:'admin.items.details.not_published')
  end
end
