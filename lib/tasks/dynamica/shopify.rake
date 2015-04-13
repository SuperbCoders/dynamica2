namespace :dynamica do
  namespace :shopify do
    task import: :environment do
      ThirdParty::Shopify::Integration.select(:id).find_each batch_size: 10 do |shopify_integration|
        ThirdParty::Shopify::Importer.import(shopify_integration.id)
      end
    end
  end
end
