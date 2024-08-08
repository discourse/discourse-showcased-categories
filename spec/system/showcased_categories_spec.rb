# frozen_string_literal: true

RSpec.describe "Showcased Categories", system: true do
  let!(:theme) { upload_theme_component }

  fab!(:user)

  fab!(:category1) { Fabricate(:category)}
  fab!(:category2) { Fabricate(:category)}

  fab!(:tag1) { Fabricate(:tag, name: "rhino") }
  fab!(:tag2) { Fabricate(:tag, name: "gorilla") }

  fab!(:topic1) { Fabricate(:topic, category: category1, tags: [tag1])}
  fab!(:topic2) { Fabricate(:topic, category: category2, tags: [tag2])}

  before do 
    sign_in(user)
  end

  it "topic feeds appear when categories are configured without tags" do
    theme.update_setting(:feed_one_category, "#{category1.id}")
    theme.update_setting(:feed_two_category, "#{category2.id}")
    theme.save!

    visit("/")

    expect(page).to have_css(".custom-homepage-columns")
  end

  it "topic feeds appear when tags are configured without categories" do
    theme.update_setting(:feed_one_tag, "#{tag1}")
    theme.update_setting(:feed_two_tag, "#{tag2}")
    theme.save!

    visit("/")

    expect(page).to have_css(".custom-homepage-columns")
  end

  it "topic feeds appear when both categories and tags are configured" do
    theme.update_setting(:feed_one_category, "#{category1.id}")
    theme.update_setting(:feed_two_category, "#{category2.id}")
    theme.update_setting(:feed_one_tag, "#{tag1}")
    theme.update_setting(:feed_two_tag, "#{tag2}")
    theme.save!

    visit("/")

    expect(page).to have_css(".custom-homepage-columns")
  end

  it "topic feed does not appear when one category is configured" do
    theme.update_setting(:feed_one_category, "#{category1.id}")
    theme.update_setting(:feed_two_category, "")
    theme.save!

    visit("/")
    
    expect(page).to have_no_css(".custom-homepage-columns")
  end

  it "topic feed does not appear when one tag is configured" do
    theme.update_setting(:feed_one_tag, "#{tag1}")
    theme.save!

    visit("/")
    
    expect(page).to have_no_css(".custom-homepage-columns")
  end

  it "topic feed does not appear outside of the homepage" do
    theme.update_setting(:feed_one_tag, "#{tag1}")
    theme.update_setting(:feed_two_tag, "#{tag2}")
    theme.save!

    visit("/top")
    
    expect(page).to have_no_css(".custom-homepage-columns")
  end

  it "topic feeds appear as sidebar when setting is enabled" do
    theme.update_setting(:feed_one_category, "#{category1.id}")
    theme.update_setting(:feed_two_category, "#{category2.id}")
    theme.update_setting(:show_as_sidebar, "true")
    theme.save!

    visit("/")

    expect(page).to have_css(".contents .custom-homepage-columns")
  end

  it "the post button opens the composer" do
    theme.update_setting(:feed_one_category, "#{category1.id}")
    theme.update_setting(:feed_two_category, "#{category2.id}")
    theme.update_setting(:feed_one_tag, "#{tag1}")
    theme.update_setting(:feed_two_tag, "#{tag2}")
    theme.save!

    visit("/")

    find(".col-1 .btn-primary").click 

    expect(page).to have_css("#reply-control")
  end

  it "the more button href is for a category page" do
    theme.update_setting(:feed_one_category, "#{category1.id}")
    theme.update_setting(:feed_two_category, "#{category2.id}")
    theme.save!

    visit("/")

    expect(page).to have_tag("a", with: { class: "btn btn-more", href: "#{category1.url}/l/latest"})
    expect(page).to have_tag("a", with: { class: "btn btn-more", href: "#{category2.url}/l/latest"})
  end

  it "the more button href is for a tag page" do
    theme.update_setting(:feed_one_tag, "#{tag1}")
    theme.update_setting(:feed_two_tag, "#{tag2}")
    theme.save!

    visit("/")

    expect(page).to have_tag("a", with: { class: "btn btn-more", href: "/tag/#{tag1}/l/latest"})
    expect(page).to have_tag("a", with: { class: "btn btn-more", href: "/tag/#{tag2}/l/latest"})
  end

  it "the more button href is for a tag page with category set" do
    theme.update_setting(:feed_one_category, "#{category1.id}")
    theme.update_setting(:feed_one_tag, "#{tag1}")
    theme.update_setting(:feed_two_category, "#{category2.id}")
    theme.save!

    visit("/")

    expect(page).to have_tag("a", with: { class: "btn btn-more", href: "/tags/c/#{category1.slug}/#{category1.id}/#{tag1}/l/latest"})
  end

  it "the more button href is for search with multiple tags" do
    theme.update_setting(:feed_one_tag, "#{tag1}|#{tag2}")
    theme.update_setting(:feed_two_tag, "#{tag2}|#{tag1}")
    theme.save!

    visit("/")

    expect(page).to have_tag("a", with: { class: "btn btn-more", href: "/search?expanded=true&q=tags%3A#{tag1}%2C#{tag2}"})
  end

  it "the more button href is for search with category and tags" do
    theme.update_setting(:feed_one_category, "#{category1.id}")
    theme.update_setting(:feed_two_category, "#{category2.id}")
    theme.update_setting(:feed_one_tag, "#{tag1}|#{tag2}")
    theme.update_setting(:feed_two_tag, "#{tag2}|#{tag1}")
    theme.save!

    visit("/")

    expect(page).to have_tag("a", with: { class: "btn btn-more", href: "/search?expanded=true&q=%23#{category1.slug} tags%3A#{tag1}%2C#{tag2}"})
  end

  it "the more button href is for a category page ordered by top" do
    theme.update_setting(:feed_one_category, "#{category1.id}")
    theme.update_setting(:feed_two_category, "#{category2.id}")
    theme.update_setting(:filter, "top")    
    theme.save!

    visit("/")

    expect(page).to have_tag("a", with: { class: "btn btn-more", href: "#{category1.url}/l/top"})
  end
 
end
