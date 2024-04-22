# frozen_string_literal: true

module SimplyEncrypt
  MODE = 'AES-256-CBC'
  KEY = Digest::SHA1.hexdigest(Rails.application.credentials.secret_key_base)[..31]

  def encrypt(data)
    return [nil, nil] if data.blank?

    cipher = OpenSSL::Cipher.new(MODE)
    cipher.encrypt
    cipher.key = KEY
    vi = cipher.random_iv

    encrypted = cipher.update(data.to_s) + cipher.final
    [encode(encrypted), encode(vi)]
  end

  def decrypt(data, iv) # rubocop:disable Naming/MethodParameterName
    return if data.blank? || iv.blank?

    decipher = OpenSSL::Cipher.new(MODE)
    decipher.decrypt
    decipher.key = KEY
    decipher.iv = decode(iv)
    decipher.update(decode(data)) + decipher.final
  end

  private

  def encode(string)
    CGI.escape(Base64.encode64(string))
  end

  def decode(string)
    Base64.decode64(CGI.unescape(string))
  end
end
