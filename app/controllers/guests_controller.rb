class GuestsController < ApplicationController
  def create
    @reservation = Reservation.find(params[:reservation_id])
    @guest = @reservation.guests.create(guest_params)

    respond_to do |format|
      if @guest.save
        format.html { redirect_to @reservation, notice: 'Guest was successfully posted' }
        format.js
      end
    end
  end

  private

  def guest_params
    params.require(:guest).permit(:name, :surname, :gender, :date_of_birth,
     :country_of_birth, :nationality, :passport_number, :group_leader)
  end
end
