require "test_helper"

describe RentalsController do
  before do
    @movie = Movie.first
    customer = Customer.first
    @date = Date.today

    @rental_data = {
      checkout: nil,
      due_date: nil,
      customer_id: customer.id,
      movie_id: @movie.id
    }

  end

  describe 'checkout' do
    it 'is real route' do
      post checkout_path, params: @rental_data

      must_respond_with :success
    end

    it 'returns json' do
      post checkout_path, params: @rental_data

      response.header['Content-Type'].must_include 'json'
    end

    it 'can checkout a movie and updates inventory' do
      before_count = Rental.count
      before_inventory_count = @movie.inventory

      # Act
      post checkout_path, params: @rental_data

      assert_response :success
      Rental.count.must_equal before_count + 1

      body = JSON.parse(response.body)
      body.must_include "id"
      new_rental = Rental.find(body["id"])

      new_rental.customer_id.must_equal @rental_data[:customer_id]

      new_rental.movie_id.must_equal @rental_data[:movie_id]

      new_rental.checkout.must_equal @date

      new_rental.due_date.must_equal @date + 7
      @movie.reload
      @movie.inventory.must_equal before_inventory_count - 1
    end

    it 'throws an error if inventory of movie is 0 and someone tries to checkout' do
      before_count = Rental.count
      @movie.inventory = 0
      @movie.save

      # binding.pry

      assert_no_difference "Rental.count" do
        post checkout_path, params: @rental_data
        assert_response :bad_request
      end

      body = JSON.parse(response.body)
      body.must_include "errors"
      body['errors'].must_include 'inventory'

      @movie.inventory.must_equal 0
    end
  end

  # describe 'checkin' do
  #   it 'is real route' do
  #     skip
  #   end
  #
  #   it 'can checkin a movie' do
  #     skip
  #   end
  #
  #   it 'changes the inventory of movie when it is checked in' do
  #     skip
  #   end
  #
  #   it 'throws an error if a movie is not checked out and you attempt a checkin' do
  #     skip
  #   end
  # end
end
