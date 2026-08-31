Rails.application.config.filter_parameters += %i[
  passw email secret token _key crypt salt certificate otp ssn cpf cnpj password
]
