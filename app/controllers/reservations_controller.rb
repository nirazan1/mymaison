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

  def submit
    @reservation = Reservation.find(params[:reservation_id])
    police_portal_syncer = PolicePortalSyncer.new(@reservation)
    police_portal_syncer.sync_guests
    contract_generator = ContractGenerator.new(@reservation)
    @signing_url = contract_generator.contract_url
  end

  def signed
    @reservation = Reservation.find(params[:reservation_id])
    @reservation.update(contract_signed: true)
    guest = @reservation.guests.leader&.first || @reservation.guests.first
    @email_address = guest.email_address
  end

  def email_contract
    @reservation = Reservation.find(params[:reservation_id])
    contract_generator = ContractGenerator.new(@reservation)
    contract_generator.download_and_email_contract(params[:email_address])
    redirect_to root_path
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
