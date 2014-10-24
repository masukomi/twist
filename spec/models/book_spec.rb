require 'rails_helper'

describe Book do
  context "upon creation" do
    let(:args) { ["radar", "rails3book_test"] }
    let(:git) { Git.new(*args) }

    before do
      # Ensure a pristine state
      Resque.remove_queue("normal")
      FileUtils.rm_r(git.path) if File.exist?(git.path)
      git.update!
    end

    it "enqueues a book for processing" do
      expect(Resque).to receive(:enqueue)
      book = Book.create(:title => "Rails 3 in Action", :path => "http://github.com/radar/rails3book_test")
      assert book.processing?
    end

    it "processes a test book" do
      # Should enqueue a job...
      book = Book.create(:title => "Rails 3 in Action (TESTs)", :path => "http://github.com/radar/rails3book_test")
      assert book.processing?
      # ... which when run ...
      Book.perform(book.id)
      book.reload
      assert !book.processing?
      # ... creates a chapter!
      expect(book.chapters.count).to eq(1)
    end
    
    it "processes the Rails 3 in Action real book" do
      # Should enqueue a job...
      book = Book.create(:title => "Rails 3 in Action", :path => "http://github.com/radar/rails3book")
      assert book.processing?
      # ... which when run ...
      Book.perform(book.id)
      book.reload
      assert !book.processing?
      # ... creates a chapter!
      expect(book.chapters.count).to eq(18)
      expect(book.chapters.map(&:position)).to eq([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18])
    end
  end
end
