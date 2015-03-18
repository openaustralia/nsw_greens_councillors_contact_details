require 'scraperwiki'
require 'mechanize'

def extract_table_contents(t)
  t.search("tr").map do |tr|
    tr.search("td").map {|td| td.inner_text.strip}
  end
end

agent = Mechanize.new

page = agent.get("http://nsw.greens.org.au/councillors-by-council")

t = extract_table_contents(page.at("table"))

t[1..-1].each do |row|
  # Order of data: "Council or Shire", "Councillor Name", "Phone", "Email", "Ward"
  p row
  raise "Unexpected number of items" unless row.count == 5
  raise "Unexpected number of phone numbers" unless row[2].split("\n").count <= 2

  record = {
    "council" => row[0],
    "name" => row[1],
    "phone1" => row[2].split("\n")[0],
    "phone2" => row[2].split("\n")[1],
    "email" => row[3],
    "ward" => row[4]
  }
  ScraperWiki.save_sqlite(["council", "name"], record)
end
