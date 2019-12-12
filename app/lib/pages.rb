module Pages

  LANGUAGES = %w[en pt]

  def self.format_date date
    date.strftime '%-d. %-m. %Y %k:%M:%S' if date
  end

end

