class InappropriateTextValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present? && ModerationService.inappropriate?(value)
      # Mensagem de erro amigável e clara para o usuário
      message = options[:message] || "não pode conter termos impróprios ou ofensivos"
      record.errors.add(attribute, message)
    end
  end
end
