require 'pry'
class RentalsController < ApplicationController

  def checkout
    movie_id = params[:movie_id]
    customer_id = params[:customer_id]

    date = Date.today
    rental_params = {
      checkout: nil,
      due_date: nil,
      customer_id: customer_id,
      movie_id: movie_id
    }

    movie = Movie.find_by(id: movie_id)
    customer = Customer.find_by(id: customer_id)

    if movie[:available_inventory] == 0
      render json: {
        errors: {
          available_inventory: ["Movie is currently all checked out. Sorry."]
        }
      } , status: :bad_request
      return
    end

    new_rental = Rental.new(rental_params)
    new_rental[:checkout] = date
    new_rental[:due_date] = date + 7
    movie[:available_inventory] -= 1
    if new_rental.save
      movie.save
      render json: { id: new_rental.id}, status: :ok
    else
      render json: { errors: new_rental.errors.messages }, status: :bad_request
    end
  end

  def checkin
    rental = Rental.find_by(customer_id: params[:customer_id], movie_id: params[:movie_id])
    puts "DPR: found rental #{rental}"


    if rental.checked_in
      render json: {
        errors: {
          checked_in: ["Movie has not been checked out."]
        }
      }, status: :bad_request
      return
    end

    # TODO: error handling
    rental.update!(checked_in: true)


    rental.movie.available_inventory += 1
    if rental.movie.save
      render json: { id: rental.movie.id }, status: :ok
    else

      render json: { errors: rental.movie.errors.messages }, status: :bad_request
    end
  end

  private
  def rental_params
    return params.permit(:checkout, :due_date, :customer_id, :movie_id)
  end
end
