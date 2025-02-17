@application.factory 'Translate', ['$rootScope', ($rootScope) ->
  class Translate
    t: (string) ->
      dict = {}
      dict['ru'] =
        products_revenue: 'Продажа товаров'
        revenue: 'Выручка'
        orders: 'Заказы'
        products_sell: 'Товаров продано'
        unic_users: 'Посетителей'
        customers: 'Клиентов'
        overview: 'Обзор'
        general: 'Базовые'
        customers: 'Покупатели'
        inventory: 'Товары'
        shipping_cost_as_a_percentage_of_total_revenue: 'Доля доставки от общей стоимости'
        average_order_value: 'Средния стоимость заказа'
        average_order_size: 'Средняя размер заказа'
        customers_number: 'Число покупателей'
        new_customers_number: 'Число новых покупателей'
        repeat_customers_number: 'Чилсо повторных покупателей'
        ratio_of_new_customers_to_repeat_customers: 'Отшение новых покупателей к повторным'
        average_revenue_per_customer: 'Средняя сумма на покупателя'
        sales_per_visitor: 'Покупок на посетителей'
        average_customer_lifetime_value: 'Среднее время проведенное клиентом'
        unique_users_number: 'Количество уникальных посетителей'
        visits: 'Число визитов'
        products_in_stock_number: 'Продуктов в продаже'
        items_in_stock_number: 'Позиций на складе'
        percentage_of_inventory_sold: 'Процент проданных товаров'
        percentage_of_stock_sold: 'Процент запаса на складе'
        products_number: 'Количество товаров'
        total_gross_revenues: 'Общая выручка'

      dict['en'] =
        products_revenue: 'products_revenue'
        revenue: 'Revenue'
        orders: 'Orders'
        products_sell: 'Products sell'
        unic_users: 'Unic users'
        customers: 'Customers'
        overview: 'Overview'
        general: 'General'
        customers: 'Customers'
        inventory: 'Inventory'
        total_revenu: 'Gross Revenue'
        shipping_cost_as_a_percentage_of_total_revenue: 'Shipping Cost As A Percentage Of Total Revenue'
        average_order_value: 'Average Order Value'
        average_order_size: 'Average Order Size'
        customers_number: 'Customers Number'
        new_customers_number: 'New Customers Number'
        repeat_customers_number: 'Repeat Customers Number'
        ratio_of_new_customers_to_repeat_customers: 'Ratio Of New Customers To Repeat Customers'
        average_revenue_per_customer: 'Average Revenue Per Customer'
        sales_per_visitor: 'Sales Per Visitor'
        average_customer_lifetime_value: 'Average Customer Lifetime Value'
        unique_users_number: 'Unique Users Number'
        visits: 'Visits'
        products_in_stock_number: 'Products_in_stock_number'
        items_in_stock_number: 'Items In Stock Number'
        percentage_of_inventory_sold: 'Percentage Of Inventory Sold'
        percentage_of_stock_sold: 'Rercentage Of Stock Sold'
        products_number: 'Products Number'
        total_gross_revenues: 'Gross Revenue'

      if dict[$rootScope.locale][string] then dict[$rootScope.locale][string] else 'no_translate_'+string

  new Translate
]
