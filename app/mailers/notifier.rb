class Notifier < ActionMailer::Base
  default from: "mymaison@mailinator.com",
          return_path: 'mymaison@mailinator.com'

  def send_contract(email_address, file_path)
    attachments['contract.pdf'] = File.read(file_path)
    mail(to: email_address,
         subject: "Contact")
  end
end
