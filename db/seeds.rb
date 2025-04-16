puts "🌱 Seed de usuarios..."

admin = User.find_or_initialize_by(email: "admin@renace.com.ar")
admin.assign_attributes(
  password: "admin1234",
  password_confirmation: "admin1234",
  admin: true,
  confirmed_at: Time.current
)
admin.save!

puts "✅ Admin creado o actualizado: #{admin.email} (contraseña: admin1234)"

5.times do |i|
  email = "usuario#{i+1}@renace.com.ar"
  user = User.find_or_initialize_by(email: email)
  user.assign_attributes(
    password: "password123",
    password_confirmation: "password123",
    confirmed_at: Time.current
    # ❌ NADA de user.name = ...
  )
  user.save!
  puts "👤 Usuario creado o actualizado: #{email} (password123)"
end