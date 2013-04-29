require 'mechanize'

class TapasScrape
  URL = 'https://rubytapas.dpdcart.com/subscriber/content'
  attr_reader :a, :username, :pwd, :agent
  attr_accessor :content_page, :epi_links

  def initialize(username, pwd)
    @agent = Mechanize.new
    @content_page = nil
    @username, @pwd = username, pwd
    login
    collect_epi_links
    save_pages
  end

  def save_pages
    epi_links.each do |epi|
      episode = agent.get("https://rubytapas.dpdcart.com#{epi}")
      epi_name = episode.search('div.section-header.order').search('h2').text
      name = epi_name.gsub!(/\s+/, ?_) + '.html'
      final_page = episode.link_with(text: /.html/i)
      if final_page.nil?
        p "#{name} not downloadable!!!!.... NEXTING..."
        next
      end
      final = final_page.click.body
      File.open("htmls/#{name}", 'w') { |f| f.write final }
      p "episode: #{name} done....."
    end
  end

  def collect_epi_links
    self.epi_links = load_epi_links || fetch_epi_links
    p epi_links
    File.open('epi_links.yml', 'w') { |f| f.write YAML.dump(epi_links) }
  end
  
  def load_epi_links
    data = ''
    data = File.read('epi_links.yml') if File.exist?('epi_links.yml')
    return nil if data.empty?
    p 'loading...'
    YAML.load data
  end

  def fetch_epi_links
    p 'fetching...'
    content_page.links_with(text: /Read More/i).map { |l| l.href }.reverse 
  end

  def login
    page = agent.get tapas_login_url
    login_form = page.forms[0]
    login_form.username, login_form.password = username, pwd
    self.content_page = agent.submit login_form, login_form.buttons.first
  end

  def tapas_login_url
    URL
  end
end

p "=============================="
obj = TapasScrape.new *ARGV
#p obj.epi_links
