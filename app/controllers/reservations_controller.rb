class ReservationsController < ApplicationController
  before_action :find_reservation, only: [:submit, :signed, :email_contract, :download_contract]

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
      @reservation.guests.create!(guest_params[:guest])
      redirect_to @reservation
    else
      render 'new'
    end
  end

  def show
    @reservation = Reservation.find(params[:id])
    @default_checkin_date = @reservation.guests.first.checkin_date
    @default_checkout_date = @reservation.guests.first.checkout_date
  end

  def submit
    police_portal_syncer = PolicePortalSyncer.new(@reservation)
    police_portal_syncer.sync_guests
    contract_generator = ContractGenerator.new(@reservation)
    @signing_url = contract_generator.contract_url
  end

  def signed
    @reservation.update!(contract_signed: true)
    guest = @reservation.guests.leader&.first || @reservation.guests.first
    @email_address = guest.email_address
  end

  def email_contract
    contract_generator = ContractGenerator.new(@reservation)
    contract_generator.download_and_email_contract(params[:email_address])
    redirect_to :back
  end

  def download_contract
    contract_generator = ContractGenerator.new(@reservation)
    file_path = contract_generator.download_contract
    send_file file_path,:type=>"application/pdf", :x_sendfile=>true
  end

  private
  def find_reservation
    @reservation = Reservation.find(params[:reservation_id])
  end

  def reservation_params
    params.require(:reservation).permit(:property_id)
  end

  def guest_params
    params.require(:reservation).permit(guest: [:name, :surname, :gender,
     :date_of_birth, :country_of_birth, :nationality, :passport_number,
     :group_leader, :checkin_date, :checkout_date, :email_address])
  end

  def current_user
    @current_user ||= User.first
  end
end
