# config/initializers/active_model_serializer.rb
ActiveModel::Serializer.config.adapter = ActiveModel::Serializer::Adapter::JsonApi

ActiveModel::Serializer.config do |config|
  config.embed = :ids
end