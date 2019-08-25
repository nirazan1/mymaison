class ContractGenerator

  def initialize(reservation)
    @reservation = reservation
  end

  def contract_url
    generate_contract_and_return_url
  end

  def download_and_email_contract(email_address)
    file_bin = client.signature_request_files :signature_request_id => @reservation.signature_request_id, :file_type => 'pdf'
    file_path = "#{Rails.root}/tmp/reservation_#{@reservation.id}.pdf"

    File.open(file_path, 'wb') do |file|
      file.write(file_bin)
    end
    Notifier.send_contract(email_address, file_path).deliver!
  end

  private
  def client
    @client ||= HelloSign::Client.new
  end

  def generate_contract_and_return_url
    # response = client.send_signature_request_with_template(request_params)
    # @signing_url = response.raw_data['signing_url']
    response = client.create_embedded_signature_request_with_template(
      request_params.merge(:client_id => '248a18bc8fe2f1d2e3f91a7319e89251') #todo use yml
    )
    signature_id = response.raw_data['signatures'].first['signature_id']
    signing_url = client.get_embedded_sign_url :signature_id => signature_id
    signature_request_id = response.raw_data['signature_request_id']
    @reservation.update(signing_url: signing_url.data['sign_url'], signature_request_id: signature_request_id)
    signing_url
  end

  def request_params
    guest = @reservation.guests.leader&.first || @reservation.guests.first
    { test_mode: 1,
      template_id: 'afe3b4eac762845ee126345db36fa80d6dbb6d18', #todo use yml
      title: 'Rental Contract.',
      subject: 'Rental Contract',
      message: 'Please sign this Renting Contract.',
      signers: [
          {
              email_address: "#{guest.email_address}",
              name: "#{guest.full_name}",
              role: 'guest'
          }
      ],
      custom_fields: [
          {
              name: 'guest_name',
              value: "#{guest.full_name}"
          },
          {
              name: 'user_name',
              value: "#{@reservation.user.name}"
          },
          {
              name: 'property',
              value: "#{@reservation.property.name}, #{@reservation.property.location}"
          }
      ] }
  end
end
