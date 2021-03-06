require "test_helper"

describe RentalsController do

  describe 'checkout' do
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
    it 'is real route' do
      post checkout_path, params: @rental_data

      must_respond_with :success
    end

    it 'returns json' do
      post checkout_path, params: @rental_data

      response.header['Content-Type'].must_include 'json'
    end

    it 'can checkout a movie and updates available_inventory' do
      before_count = Rental.count
      before_available_inventory_count = @movie.available_inventory

      # Act
      post checkout_path, params: @rental_data

      assert_response :success
      Rental.count.must_equal before_count + 1

      body = JSON.parse(response.body)
      body.must_include "id"
      new_rental = Rental.find(body["id"])

      @rental_data[:movie_id]

      new_rental.checkout.must_equal @date

      new_rental.due_date.must_equal @date + 7
      @movie.reload
      @movie.available_inventory.must_equal before_available_inventory_count - 1
    end

    it 'throws an error if available_inventory of movie is 0 and someone tries to checkout' do
      before_count = Rental.count
      @movie.available_inventory = 0
      @movie.save

      assert_no_difference "Rental.count" do
        post checkout_path, params: @rental_data
        assert_response :bad_request
      end

      body = JSON.parse(response.body)
      body.must_include "errors"
      body['errors'].must_include 'available_inventory'

      @movie.available_inventory.must_equal 0
    end
  end

  describe 'checkin' do
    before do
      date = Date.today
      @movie = Movie.first
      @customer = Customer.first

      @rental = {
        checkout: date,
        due_date: date + 7,
        customer_id: @customer.id,
        movie_id: @movie.id
      }
      @rental_db_entry = Rental.create!(@rental)
    end

    it 'is real route' do
      post checkin_path, params: @rental

      must_respond_with :success
    end

    it 'renders json' do
      post checkin_path, params: @rental

      response.header['Content-Type'].must_include 'json'
    end

    it 'can checkin a movie and changes the available_inventory when checked in' do
      before_available_inventory_count = @movie.available_inventory

      post checkin_path, params: @rental
      assert_response :success

      @rental_db_entry.reload
      @rental_db_entry.must_be :checked_in

      @movie.reload
      @movie.available_inventory.must_equal before_available_inventory_count + 1
    end

    it 'throws an error if a movie is not checked out and you attempt a checkin' do
      before_available_inventory_count = @movie.available_inventory
      @movie.reload

      @rental_db_entry.checked_in = true
      @rental_db_entry.save!

      assert_no_difference "#{@movie.available_inventory}" do
        post checkin_path, params: @rental
        assert_response :bad_request
      end

      body = JSON.parse(response.body)
      body.must_include "errors"
      body['errors'].must_include 'checked_in'

    end
  end
end
