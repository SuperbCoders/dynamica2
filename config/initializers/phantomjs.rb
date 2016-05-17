Phantomjs.configure do |config|
  if Rails.env.development?
    config.phantomjs_path = Rails.root.join('app','services', 'draw', 'node_modules', 'phantomjs', 'bin', 'phantomjs').to_s
  end

end
