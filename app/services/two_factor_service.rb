class TwoFactorService
  ISSUER = 'Renace'
  BACKUP_CODE_COUNT = 8

  def initialize(user)
    @user = user
  end

  # Genera y guarda el secreto TOTP. Devuelve la URI para el QR.
  def setup
    secret = ROTP::Base32.random
    @user.update!(otp_secret: secret, otp_enabled: false)
    totp_uri(secret)
  end

  # Verifica el código e habilita 2FA si es correcto
  def enable!(code)
    return false unless @user.otp_secret.present?

    totp = ROTP::TOTP.new(@user.otp_secret, issuer: ISSUER)
    return false unless totp.verify(code.to_s.strip, drift_behind: 30, drift_ahead: 30)

    codes = generate_backup_codes
    @user.update!(otp_enabled: true, otp_backup_codes: codes.map { |c| BCrypt::Password.create(c) })
    codes
  end

  def disable!(code)
    return false unless verify(code)
    @user.update!(otp_enabled: false, otp_secret: nil, otp_backup_codes: [])
    true
  end

  def verify(code)
    code = code.to_s.strip
    return verify_backup_code(code) if code.length > 6

    return false unless @user.otp_secret.present?
    totp = ROTP::TOTP.new(@user.otp_secret, issuer: ISSUER)
    totp.verify(code, drift_behind: 30, drift_ahead: 30).present?
  end

  def qr_code_svg(uri)
    qrcode = RQRCode::QRCode.new(uri)
    qrcode.as_svg(module_size: 4, use_path: true)
  end

  private

  def totp_uri(secret)
    ROTP::TOTP.new(secret, issuer: ISSUER).provisioning_uri(@user.email)
  end

  def generate_backup_codes
    Array.new(BACKUP_CODE_COUNT) { SecureRandom.hex(5).upcase.scan(/.{5}/).join('-') }
  end

  def verify_backup_code(code)
    return false unless @user.otp_backup_codes.present?

    @user.otp_backup_codes.each_with_index do |hashed, idx|
      next unless BCrypt::Password.new(hashed).is_password?(code)

      remaining = @user.otp_backup_codes.dup
      remaining.delete_at(idx)
      @user.update_column(:otp_backup_codes, remaining)
      return true
    end
    false
  end
end
