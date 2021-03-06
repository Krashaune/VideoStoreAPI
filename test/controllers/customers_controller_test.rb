require "test_helper"

describe CustomersController do
  describe 'index' do
    it 'is a real route' do
      get customers_path

      must_respond_with :success
    end

    it 'returns json' do
      get customers_path

      response.header['Content-Type'].must_include 'json'
    end

    it 'returns all customers' do
      get customers_path

      body = JSON.parse(response.body)
      body.length.must_equal Customer.count
    end

    it 'returns customers with all required fields' do
      keys = %w(address city id name phone postal_code registered_at)

      get customers_path

      body = JSON.parse(response.body)
      body.each do |customer|
        customer.keys.sort.must_equal keys
      end
    end
  end
end
