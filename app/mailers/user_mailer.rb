class UserMailer < ApplicationMailer
    default from: "Smx Mobile Money<support@smxmoney.com>"
    layout 'mailer'

    rescue_from Net::SMTPFatalError do |exception|
        puts "Exception: #{exception}"
    end

    def registration_confirmation(user)
        @title = 'Smx - Registration Confirmation'
        @user = user
        mail(to: "#{@user.first_name.capitalize} #{@user.last_name.capitalize} <#{@user.email}>", subject: 'Welcome to Smx')
    end

    def reset_password_email(user, code)
        @title = 'Smx - Reset Password'
        @user = user
        @code = code
        mail(to: "#{@user.first_name.capitalize} #{@user.last_name.capitalize} <#{@user.email}>", subject: 'Password reset')
    end

    def change_password_email(user)
        @encrypted_time = EncryptDecryptService.new(Time.now.to_i).encrypt
        @title = 'Smx - Change Password'
        @user = user
        mail(to: "#{@user.first_name.capitalize} #{@user.last_name.capitalize} <#{@user.email}>", subject: 'Password change')
    end

    def email_update_confirmation(user, email)
        @title = 'Smx - Email Confirmation'
        @user = user
        @encrypted_email = EncryptDecryptService.new(email).encrypt
        mail(to: "#{@user.first_name.capitalize} #{@user.last_name.capitalize} <#{email}>", subject: 'Email Update Confirmation')
    end

    def trans_error_email(params, message)
        @title = 'Smx - Transaction Error'
        @params = params
        @message = message
        mail(to: "Support <support@smxmoney.com>", subject: 'User Transaction Error')
    end

    def trans_summary(user_transaction_id)
        @title = 'Smx - Transaction Summary'
        @transaction = UserTransaction.find(user_transaction_id)
        @user = @transaction.sender
        mail(to: "#{@transaction.sender.full_name} <#{@transaction.sender.email}>", subject: 'Transaction Receipt')
    end

    def device_change(user, remote_ip)
        @title = 'Smx - New device detected'
        @user = user
        @remote_ip = remote_ip
        mail(to: "#{@user.first_name.capitalize} #{@user.last_name.capitalize} <#{@user.email}>", subject: 'Device changed')
    end

end
