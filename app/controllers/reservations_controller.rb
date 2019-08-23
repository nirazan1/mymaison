class ReservationsController < ApplicationController
  def index
    @reservations = current_user.reservations
  end

  def new
    @properties = current_user.properties
    @reservation = Reservation.new
  end

  def create
    @current_user = current_user
    @reservation = Reservation.new(reservation_params)
    if @reservation.save
      @reservation.guests.create(guest_params[:guest])
      redirect_to @reservation
    else
      render 'new'
    end
  end

  def show
    @reservation = Reservation.find(params[:id])
  end

  private
  def reservation_params
    params.require(:reservation).permit(:checkin_date, :checkout_date,
     :property_id)
  end

  def guest_params
    params.require(:reservation).permit(guest: [:name, :surname, :gender, :date_of_birth,
     :country_of_birth, :nationality, :passport_number, :group_leader])
  end

  def current_user
    @current_user ||= User.first
  end
end
