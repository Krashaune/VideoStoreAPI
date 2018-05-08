require "test_helper"

describe Movie do
  before do
    @movie_data = {
      title: 'test title',
      inventory: 2
    }
  end

  describe 'validations' do
    it 'is valid with title and an inventory greater then 1' do
      movie = Movie.new(@movie_data)
      movie.must_be :valid?
    end

    it 'is invalid with no title' do
      movie = Movie.new(@movie_data)
      movie.title = ""

      movie.wont_be :valid?
      movie.errors.messages.must_include :title
    end

    #REVIEW: Consider test case for a movie with 0 inventory
    it 'is invalid with an inventory < 0' do
      movie = Movie.new(@movie_data)
      movie.inventory = -1

      movie.wont_be :valid?
      movie.errors.messages.must_include :inventory
    end

    it 'is invalid with a non-numerical inventory' do
      movie = Movie.new(@movie_data)
      movie.inventory = "Aaaa"

      movie.wont_be :valid?
      movie.errors.messages.must_include :inventory

    end
  end
  
  describe 'relations' do

  end
end
