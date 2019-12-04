module OqWebPlugin
  class Railtie < Rails::Railtie

    config.before_configuration do |app|
      app.config.paths.add(
          File.expand_path('../app', __FILE__),
          eager_load: true
      )
    end

    initializer 'oq_web_plugin' do
      OqWeb::QUESTIONNAIRE_SINGLETON_TYPE = 'DummyQuestionnaire'
    end

  end
end
