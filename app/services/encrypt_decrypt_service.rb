class EncryptDecryptService
    def initialize(text)
        @text = text
    end

    def encrypt
        return encryptor_decryptor.encrypt_and_sign(@text)
    end

    def decrypt
        return encryptor_decryptor.decrypt_and_verify(@text)
    end

    private

    def encryptor_decryptor
        key = ENV['ENCRYPTION_KEY']
        crypt = ActiveSupport::MessageEncryptor.new(key)
        return crypt
    end

end