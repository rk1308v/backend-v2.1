# Preview all emails at http://localhost:3000/rails/mailers/example_mailer
class UserMailerPreview < ActionMailer::Preview
  def reset_password_mail_preview
    UserMailer.reset_password_email(User.first, "12345")
  end


  def confirm_email_mail_preview
    UserMailer.registration_confirmation(User.first)
  end
end
