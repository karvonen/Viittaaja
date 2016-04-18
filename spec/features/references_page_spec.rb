require 'rails_helper'

describe 'References page' do

  it 'lists all current references' do
    Reference.create reference_type:'book', year:1990, author:"Teppo", title:"Matti", publisher:"Suomiboyz"
    Reference.create reference_type:'article', year:1980, author:"Barack Öbämå", title:"USA", journal:"dsaasd", volume:1
    Reference.create reference_type:'inproceeding', year:1930, author:"asd", title:"jou", booktitle:"herp"

    visit references_path

    @book_reference = find_by_id('books').find('tbody').find('tr:nth-child(1)')
    @article_reference = find_by_id('articles').find('tbody').find('tr:nth-child(1)')
    @inproceeding_reference = find_by_id('inproceedings').find('tbody').find('tr:nth-child(1)')

    expect(@book_reference.text).to eq "1990 Suomiboyz Teppo Matti EditDestroy"
    expect(@article_reference.text).to eq "1980 dsaasd Barack Öbämå USA 1 EditDestroy"
    expect(@inproceeding_reference.text).to eq "1930 herp asd jou EditDestroy"
  end

  it 'when a new book is added, shows it on the page' do
    User.create username:"asd"
    Reference.create year:1990, author:"Teppo", title:"Matti", publisher:"Suomiboyz"
    Reference.create year:1990, author:"Barack Öbämå", title:"USA", publisher:"asd"

    visit references_path

    expect(page).to have_xpath(".//tr", count: 3)
    expect(page).not_to have_content("2000 Kebab on hyvää")

    click_link "Add reference"

    fill_in 'reference_year', with: '2000'
    fill_in 'reference_publisher', with: 'Kebab'
    fill_in 'reference_author', with: 'on'
    fill_in 'reference_title', with: 'hyvää'
    click_button "Create Reference"
    expect(page).to have_xpath(".//tr", count: 4)

    expect(page).to have_content("2000 Kebab on hyvää")
  end

  it 'when bibtex-button is pressed, opens up a page showing references in bibtex format' do
    Reference.create year:1990, author:"Barack Öbämå", title:"USA", publisher:"asd", reference_type:"book"

    visit references_path

    click_link "Bibtex"
    @bibtex_textbox = find('textarea')

    expect(page).to have_content "References in BibTex-format"
    expect(@bibtex_textbox.text).to have_content "@Book{1,
                                  year = {1990},
                                  publisher = {asd},
                                  author = {Barack \\\"{O}b\\\"{a}m\\aa},
                                  title = {USA},
                                  }"
  end

  it 'new article is added' do
    visit references_path

    expect(page).to have_xpath(".//tr", count: 3)

    click_link "Add reference"

    select "Article", :from => "reference_reference_type"

    fill_in 'reference_year', with: '1995'
    fill_in 'reference_author', with: 'teppo'
    fill_in 'reference_title', with: 'titteli'
    fill_in 'reference_journal', with: 'science'
    fill_in 'reference_volume', with: '14'

    click_button "Create Reference"
    expect(page).to have_xpath(".//tr", count: 4)

    expect(page).to have_content("science")

    @article_reference = find_by_id('articles').find('tbody').find('tr:nth-child(1)')

    expect(@article_reference.text).to eq "1995 science teppo titteli 14 EditDestroy"
  end

  it 'article is not added with insufficient fields' do
    visit references_path

    expect(page).to have_xpath(".//tr", count: 3)

    click_link "Add reference"

    select "Article", :from => "reference_reference_type"

    fill_in 'reference_year', with: '1995'
    fill_in 'reference_author', with: 'teppo'
    fill_in 'reference_title', with: 'titteli'
    fill_in 'reference_journal', with: 'science'

    click_button "Create Reference"

    expect(page).to have_content("can't be blank")

    visit references_path
    
    expect(page).to have_xpath(".//tr", count: 3)
    expect(page).not_to have_content("science")
  end
end

