require 'spec_helper'

describe Chapter do
  let(:git) { Git.new("radar", "rails3book_test") }
  let(:book) { Factory(:book) }

  before do
    # Nuke the repo, start afresh.
    FileUtils.rm_r(git.path)
    git.update!
  end

  it "processes a chapter" do
    book.chapters.process!(git, "ch01/ch01.xml")
    chapter = book.chapters.first
    chapter.title.should eql("Ruby on Rails, the framework")
    chapter.elements.first.tag.should == "p"
    chapter.sections.map(&:title).should == ["1.1 What is Ruby on Rails?", 
                                             "1.2 Developing your first application",
                                             "1.3 Summary"]
  end
  
  it "updates a chapter"
end