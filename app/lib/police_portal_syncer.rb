class PolicePortalSyncer
  require 'rubygems'
  require 'nokogiri'
  require 'open-uri'
  require 'mechanize'

  attr_reader :reservation, :user, :pfx_file

  BASE_URL = 'https://alloggiatiweb.poliziadistato.it/'.freeze

  GENDER = {
    'Male': 1,
    'Female': 2
  }.with_indifferent_access

  def initialize(reservation)
    @reservation = reservation
    @user = @reservation.user
    @pfx_file = "#{Rails.root}/tmp/pfx_files/#{user.id.to_s+'_'+user.name}.pfx"
  end

  def sync_guests
    download_certificate if !File.exist?(pfx_file)
    pkcs = OpenSSL::PKCS12.new(File.read(pfx_file), user.police_portal_password)
    download_certificate if pfx_file_certificate.not_after < Time.current
    login_and_fill
  end

  private

  def download_certificate
    mechanize_client = Mechanize.new
    mechanize_client.user_agent_alias = 'Windows Mozilla'
    mechanize_client.add_auth(BASE_URL + 'CertReqNet/Default.aspx', user.police_portal_username, user.police_portal_password)
    mechanize_client.get(BASE_URL + 'CertReqNet/Default.aspx') do |page|
      form = page.forms.first
      button = form.buttons.last
      cert_file = pfx_file
      mechanize_client.submit(form, button).save(cert_file)
    end
  end

  def extract_pfx_file
    @extract_pfx_file ||= OpenSSL::PKCS12.new(File.read(pfx_file), user.police_portal_password)
  end

  def pfx_file_key
    @key ||= OpenSSL::PKey::RSA.new(extract_pfx_file.key.to_pem)
  end

  def pfx_file_certificate
    @cert ||= OpenSSL::X509::Certificate.new(extract_pfx_file.certificate.to_pem)
  end

  def login_and_fill
    mechanize_client = Mechanize.new
    mechanize_client.key = pfx_file_key
    mechanize_client.cert = pfx_file_certificate
    page = mechanize_client.get(BASE_URL + "AlloggiatiWeb")
    form = page.form
    form['txtUtente'] = user.police_portal_username
    form['txtPwd'] = user.police_portal_password
    mechanize_client.submit(form, form.buttons.first)
    if reservation.guests.leader.pending_sync.any?
      fill_group_data(mechanize_client)
    else
      fill_single_guest_data(mechanize_client)
    end
  end

  def fill_group_data(mechanize_client)
    reservation.guests.leader.pending_sync.each do |guest|
      puts "syncing group leader #{guest.name}"
      page = mechanize_client.get(BASE_URL + "AlloggiatiWeb/InsOnLine.aspx")
      form = page.form
      puts "filling reservation data for group leader #{guest.name}"
      form['ctl00$Corpo$txtTipoAlloid'] =  Guest::GUEST_TYPE['Group Leader']
      fill_form_data(form, guest)
      puts "submitting reservation data for group leader #{guest.name}"
      mechanize_client.submit(form, form.buttons.first)
      # form = mechanize_client.page.form
      # mechanize_client.submit(form, form.buttons.last)
      guest.update(synced_to_police_portal: true)
    end
    fill_other_guest_data(mechanize_client)
  end

  def fill_other_guest_data(mechanize_client)
    reservation.guests.pending_sync.each do |guest|
      puts "syncing guest #{guest.name}"
      form = mechanize_client.page.form
      puts "filling reservation data for guest #{guest.name}"
      form['ctl00$Corpo$txtPerm'] = (guest.checkout_date - guest.checkin_date).to_i
      form['ctl00$Corpo$txtSexAlloid'] = GENDER[guest.gender]
      form['ctl00$Corpo$txtCog'] = guest.surname
      form['ctl00$Corpo$txtNom'] = guest.name
      form['ctl00$Corpo$HI_DataNascita'] = guest.date_of_birth.strftime("%d/%m/%Y") #DOB dd/mm/yyyy
      form['ctl00$Corpo$txtCittid'] = "100000100" #Italy, Citizenship
      form['ctl00$Corpo$txtLuo'] = 'MILANO (MI)' #Milan, Place of Issue
      form['ctl00$Corpo$txtLuoid'] = '403015146' #Milan, Place of Issue
      puts "submitting reservation data for guest #{guest.name}"
      mechanize_client.submit(form, form.buttons.first)
      guest.update(synced_to_police_portal: true)
    end

    puts "submitting all guest data"
    form = mechanize_client.page.form
    mechanize_client.submit(form, form.buttons.last)

    #Final Page
    puts "submitting all reservations data"
    form = mechanize_client.page.form
    mechanize_client.submit(form, form.buttons.last)
  end

  def fill_single_guest_data(mechanize_client)
    reservation.guests.pending_sync.each do |guest|
      puts "syncing single guest #{guest.name}"
      page = mechanize_client.get(BASE_URL + "AlloggiatiWeb/InsOnLine.aspx")
      form = page.form
      puts "filling reservation data for single guest #{guest.name}"
      form['ctl00$Corpo$txtTipoAlloid'] =  Guest::GUEST_TYPE['Single Guest']
      fill_form_data(form, guest)
      puts "submitting reservation data for group leader #{guest.name}"
      mechanize_client.submit(form, form.buttons.first)
      # form = mechanize_client.page.form
      # mechanize_client.submit(form, form.buttons.last)
      guest.update(synced_to_police_portal: true)
    end
    fill_other_guest_data(mechanize_client)
  end

  def fill_form_data(form, guest)
    form['ctl00$Corpo$txtDatArrivoid'] = guest.checkin_date.strftime("%d/%m/%Y")
    form['ctl00$Corpo$txtPerm'] = (guest.checkout_date - guest.checkin_date).to_i
    form['ctl00$Corpo$txt_Sexid'] = GENDER[guest.gender]
    form['ctl00$Corpo$txtCog'] = guest.surname
    form['ctl00$Corpo$txtNom'] = guest.name
    form['ctl00$Corpo$HI_DataNascita'] = guest.date_of_birth.strftime("%d/%m/%Y") #DOB dd/mm/yyyy
    form['ctl00$Corpo$txtCittid'] = "100000100" #Italy, Citizenship
    form['ctl00$Corpo$txtLuo'] = "MILANO (MI)" #Milan, Birth place
    form['ctl00$Corpo$txtLuoid'] = "403015146" #Milan, Birth place
    form['ctl00$Corpo$txtTid'] = 'PASSAPORTO ORDINARIO'
    form['ctl00$Corpo$txtTidid'] = 'PASOR' #Document, Passport Ordinary
    form['ctl00$Corpo$txtNud'] = guest.passport_number #Passport Number
    form['ctl00$Corpo$txtDLuo'] = 'MILANO (MI)' #Milan, Place of Issue
    form['ctl00$Corpo$txtDLuoid'] = '403015146' #Milan, Place of Issue
  end
end
