class Chapter < ActiveRecord::Base
  has_many :elements, :order => "id ASC", :as => :parent, :extend => Processor
  has_many :sections, :extend => SectionProcessor

  class << self
    def process!(git, file)
      # Read the XML, parse it with XSLT which will convert it into lovely HTML
      xml = Nokogiri::XML(File.read(git.path + file))
      xslt = Nokogiri::XSLT(File.read(Rails.root + 'lib/chapter.xslt'))
      parsed_doc = xslt.transform(xml)
      
      chapter = create!(:title => xml.xpath("chapter/title").text,
                        :position => 1)
      elements = parsed_doc.css("div.chapter > *")
      elements.each { |element| chapter.elements.process!(element) }
      # 
      # image_count = 1
      # parsed_doc.css("img").each do |img|
      #   title = img.parent.parent.parent.css(".figuretitle").first
      #   title.inner_html = "<strong>Figure #{short_number}.#{image_count}</strong> #{title.inner_html}"
      #   img["src"] = img["src"].gsub("/", "_")
      #   image_count += 1
      # end
      # 
      # listing_count = 1
      # parsed_doc.css(".exampletitle").each do |img|
      #   img.inner_html = "<strong>Listing #{short_number}.#{listing_count}</strong> #{img.inner_html}"
      #   listing_count += 1
      # end
      # 
      # chapter_nav = ""
      # parsed_doc.css(".chapter h1").each do |h1|
      #   chapter_title = "#{short_number}. #{h1.inner_html}"
      #   chapter_nav = { :label => chapter_title, :content => "rails3_in_action_book_#{short_number}.html" }
      #   h1.inner_html = chapter_title
      # end
      # 
      # section_count = 1
      # parsed_doc.css(".section h2").each do |section_title|
      #   section_number = "#{short_number}.#{section_count}"
      #   section_title_text = "#{section_number}. #{section_title.inner_html}"
      #   section_title.inner_html = section_title_text
      #   chapter_nav[:nav] ||= []
      #   section_nav = { :label => section_title_text, :content => "rails3_in_action_book_#{short_number}.html##{section_number}" }
      #   sub_section_count = 1
      #   section_title.parent.css(".section h3").each do |sub_section_title|
      #     section_nav[:nav] ||= []
      #     sub_section_title_number = "#{short_number}.#{section_count}.#{sub_section_count}"
      #     sub_section_title_text = "#{sub_section_title_number}. #{sub_section_title.inner_html}"
      #     sub_section_nav = { :label => sub_section_title_text,
      #                         :content => "rails3_in_action_book_#{short_number}.html##{section_number}" }
      #     section_nav[:nav] << sub_section_nav
      #     sub_section_title.inner_html = sub_section_title_text
      #     sub_section_count += 1
      #   end
      #   section_count += 1
      #   chapter_nav[:nav] << section_nav
      # end
      # 
      # total_nav << chapter_nav
      # 
      # parsed_doc.css("pre").each do |pre|
      #   pre.inner_html = pre.inner_html.gsub(/\n\s+$/, '')
      # end
      # 
      # html_header = <<-HEAD
      # <html xmlns="http://www.w3.org/1999/xhtml" xmlns:ops="http://www.idpf.org/2007/ops" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      #   <head>
      #     <title>Rails 3 in Action</title>
      #     <link href="style.css" rel="stylesheet" type="text/css"/>
      #     <link href="page-template.xpgt" rel="stylesheet" type="application/vnd.adobe-page-template+xml"/>
      #     <meta content="application/xhtml+xml; charset=utf-8" http-equiv="Content-Type"/>
      #   </head>
      # <body>
      # HEAD
      # 
      # parsed_doc = parsed_doc.to_s.gsub!(%Q{<?xml version="1.0"?>}, html_header)
      # 
      # html_footer = <<-FOOT
      #   </body>
      # </html>
      # FOOT
      # 
      # parsed_doc += html_footer
      # 
      # chapter_file_name = "output/rails3_in_action_book_#{short_number}.html"
      # File.open(chapter_file_name, 'w') do |f|
      #   f.puts parsed_doc
      # end
      # 
      # chapter_files << chapter_file_name
      # 
      # Dir["../../ch#{number}/*.png"].each do |f|
      #   FileUtils.cp(f, "output/ch#{number}/ch#{number}_#{File.basename(f)}")
      # end
      # 
      # image_files += Dir["output/ch#{number}/*.png"]
    end
  end
  
  # Helper method to access current chapter. Mainly used for sections, but can be called on a chapter.
  def chapter
    self
  end
  
  def to_param
    position.to_s
  end
end
