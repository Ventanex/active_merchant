require 'nokogiri'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class VelocityGateway < Gateway
      include Empty
      self.live_url = 'https://api.nabcommerce.com/REST/2.0.18'
      self.repayment_url = 'https://api.nabcommerce.com'

      self.supported_countries = ['US']
      self.default_currency = 'USD'
      self.supported_cardtypes = [:visa, :master_card, :american_express, :discover]

      self.homepage_url = 'https://nabvelocity.com/'
      self.display_name = 'NAB Velocity'

      STANDARD_ERROR_CODE_MAPPING = {
        '108' => STANDARD_ERROR_CODE[:invalid_number],
        'EB' => STANDARD_ERROR_CODE[:incorrect_number],
      }

      APPROVED, DECLINED, ERROR, FRAUD_REVIEW = '00', 1, 13, 3

      CARD_CODE_ERRORS = %w(N S)
      AVS_ERRORS = %w(A E I N R W Z)
      AVS_REASON_CODES = %w(27 45)

      BRANDS = {
        :visa => 'Visa',
        :master => "MasterCard",
        :american_express => "AmericanExpress",
        :discover => "Discover"
      }

      E4_BRANDS = BRANDS.merge({:mastercard => "MasterCard", :master_card => "MasterCard"})

      def initialize(options={})
        requires!(options, :identity_token, :work_flow_id, :application_profile_id, :merchant_profile_id)
        @identity_token = options[:identity_token]
        @work_flow_id = options[:work_flow_id]
        @application_profile_id = options[:application_profile_id]
        @merchant_profile_id = options[:merchant_profile_id]

        self.live_url = options[:url]
        self.repayment_url = options[:repayment_url]

        super
      end

      def purchase(money, payment, options={})
        commit(:authorize_and_capture) do |xml|
          add_payment_source(xml, payment, options)
          add_invoice(xml, money, options)
        end
      end

      def repayment(money, payment, options={})
        commit_repayment(:authorize_and_capture) do |xml|
          add_repayment_source(xml, payment, options)
          add_repayment_invoice(xml, money, options)
        end
      end

      def void(transaction_id, options={})
        @transaction_id = transaction_id

        undo(:undo) do |xml|
          add_transaction(xml, transaction_id)
        end
      end

      def return(money, transaction_id, options={})
        @transaction_id = transaction_id

        returnById(:return) do |xml|
          add_difference_data(xml, transaction_id, money)
        end
      end

      def acknowledge(transaction_id, options={})
        @transaction_id = transaction_id

        commit_acknowledge(:acknowledge) do |xml|
          add_transaction_id(xml, transaction_id)
        end
      end

      def not_acknowledged(options={})
        commit_not_acknowledged(:query_transactions_summary) do |xml|
          add_paging(xml, options)
          add_query_transactions(xml, options)
        end
      end

      def supports_scrubbing?
        true
      end

      def scrub(transcript)
        transcript
      end

      private

      def add_paging(xml, options)
        xml.PagingParameters do
          xml['ns2'].Page(0, 'xmlns:ns2' =>"http://schemas.ipcommerce.com/CWS/v2.0/DataServices")
          xml['ns3'].PageSize(50, 'xmlns:ns3' =>"http://schemas.ipcommerce.com/CWS/v2.0/DataServices")
        end
      end

      def add_query_transactions(xml, options)
        xml.QueryTransactionsParameters('xmlns:tms' => "http://schemas.ipcommerce.com/CWS/v2.0/DataServices/TMS") do
          xml.Amounts('i:nil' =>"true")
          xml.ApprovalCodes('i:nil' =>"true")
          xml.BatchIds('i:nil' =>"true")
          xml.CaptureStates('i:nil' =>"true")
          xml.CaptureDateRange('i:nil' =>"true")
          xml['tms'].CardTypes('i:nil' =>"true")
          xml['tms'].IsAcknowledged 'False'
          xml['tms'].MerchantProfileIds do
            @merchant_profile_id.each do |m|
              xml['ns1'].String(m, 'xmlns:ns1' => "http://schemas.microsoft.com/2003/10/Serialization/Arrays")
            end
          end
          xml.OrderNumbers
          xml.ServiceKeys('i:nil' =>"true")
          xml.TransactionClassTypePairs('i:nil' =>"true")
          xml.TransactionStates('i:nil' =>"true")
          xml['tms'].TransactionDateRange('xmlns:a' => "http://schemas.ipcommerce.com/CWS/v2.0/DataServices") do
            xml['a'].EndDateTime DateTime.now.end_of_day
            xml['a'].StartDateTime DateTime.now.beginning_of_day
          end
        end
        xml.IncludeRelated false
      end

      def card_type(credit_card_brand)
        E4_BRANDS[credit_card_brand.to_sym] if credit_card_brand
      end

      def add_payment_source(xml, source, options)
        return unless source

        options[:street1] ||= nil
        options[:street2] ||= nil
        options[:city] ||= nil
        options[:country_code] ||= nil
        options[:state_province] ||= nil
        options[:postal_code] ||= nil

        cardType = card_type(source.brand) || 'Visa'

        xml['ns1'].TenderData do
          xml['ns1'].CardData do
            xml['ns1'].CardType cardType
            xml['ns1'].PAN truncate(source.number, 16)
            xml['ns1'].Expire source.expiry_date.expiration.strftime('%m%y')
            xml['ns1'].Track1Data('i:nil' =>"true")
            xml['ns1'].Track2Data('i:nil' =>"true")
          end

          xml['ns1'].CardSecurityData do
            xml['ns1'].AVSData do
              xml['ns1'].CardHolderName('i:nil' =>"true")
              xml['ns1'].Street options[:street1]
              xml['ns1'].City options[:city]
              xml['ns1'].StateProvince options[:state_province]
              xml['ns1'].PostalCode options[:postal_code]
              xml['ns1'].Country options[:country_code]
              xml['ns1'].Phone('i:nil' =>"true")
            end
          end
        end
      end

      def add_repayment_source(xml, source, options)
        return unless source

        options[:street1] ||= nil
        options[:street2] ||= nil
        options[:city] ||= nil
        options[:country_code] ||= nil
        options[:state_province] ||= nil
        options[:postal_code] ||= nil

        card_source = card_type(source.brand) || 'Visa'

        xml['ns1'].TenderData do
          xml['ns1'].PaymentAccountDataToken('i:nil' =>"true")
          xml['ns1'].SecurePaymentAccountData('i:nil' =>"true")
          xml['ns1'].CardData do
            xml['ns1'].CardType card_source
            xml['ns1'].CardHolderName('i:nil' =>"true")
            xml['ns1'].PAN truncate(source.number, 16)
            xml['ns1'].Expire source.expiry_date.expiration.strftime('%m%y')
            xml['ns1'].Track1Data('i:nil' =>"true")
            xml['ns1'].Track2Data('i:nil' =>"true")
          end

          xml['ns1'].CardSecurityData do
            xml['ns1'].AVSData do
              xml['ns1'].Street options[:street1]
              xml['ns1'].City options[:city]
              xml['ns1'].StateProvince options[:state_province]
              xml['ns1'].PostalCode options[:postal_code]
              xml['ns1'].Country options[:country_code]
            end
          end
        end
      end

      def add_address(xml, options)
        options[:street1] ||= nil
        options[:street2] ||= nil
        options[:city] ||= nil
        options[:country_code] ||= nil
        options[:state_province] ||= nil
        options[:postal_code] ||= nil

        xml['ns2'].CustomerData('xmlns:ns2' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions") do
          xml['ns2'].BillingData do
            xml['ns2'].Name('i:nil' =>"true")
            xml['ns2'].Address do
              xml['ns2'].Street1 options[:street1]
              xml['ns2'].Street2 options[:street2]
              xml['ns2'].City options[:city]
              xml['ns2'].StateProvince options[:state_province]
              xml['ns2'].PostalCode options[:postal_code]
              xml['ns2'].CountryCode options[:country_code]
            end
          end
        end
      end

      def add_transaction_id(xml, transaction_id)
        xml.DifferenceData do
          xml.TransactionId transaction_id
        end
      end

      def add_transaction(xml, transaction_id)
        xml.TransactionId transaction_id
      end

      def add_difference_data(xml, transaction_id, money)
        xml.DifferenceData('xmlns:ns1' => "http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Bankcard", 'i:type' => "ns1:BankcardReturn") do
          xml['ns2'].TransactionId(transaction_id, 'xmlns:ns2'=>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions")
          xml['ns1'].Amount amount(money)
        end
      end

      def add_customer_data(xml, creditcard, options)
        options[:phone] ||= '9540123123'
        options[:email] ||= 'najeers@chetu.com'
        options[:street1] ||= '4 corporate sq'
        options[:street2] ||= '4 corporate sq'
        options[:city] ||= 'dever'
        options[:country_code] ||= 'USA'
        options[:state_province]
        options[:postal_code] ||= '30329'
        options[:card_holder_name] ||= 'Najeers Chetu'

        xml['ns2'].CustomerData('xmlns:ns2' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions") do
          xml['ns2'].BillingData do
            xml['ns2'].Name('i:nil' =>"true")
            xml['ns2'].Address do
              xml['ns2'].Street1 options[:street1]
              xml['ns2'].Street2 options[:street1]
              xml['ns2'].City options[:city]
              xml['ns2'].StateProvince options[:state_province]
              xml['ns2'].PostalCode options[:postal_code]
              xml['ns2'].CountryCode options[:country_code]
            end
            xml['ns2'].BusinessName 'MomCorp'
            xml['ns2'].Phone options[:phone]
            xml['ns2'].Fax('i:nil' =>"true")
            xml['ns2'].Email options[:email]
          end
          xml['ns2'].CustomerId 'cust123'
          xml['ns2'].CustomerTaxId('i:nil' =>"true")
          xml['ns2'].ShippingData('i:nil' =>"true")
        end
      end

      def add_reporting_data(xml, options)
        xml['ns3'].ReportingData('xmlns:ns3' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions") do
          xml['ns3'].Comment 'a test comment'
          xml['ns3'].Description 'a test description'
          xml['ns3'].Reference '001'
        end
      end

      def add_merchant(xml, options)
        xml['ns1'].MerchantData do
          xml['ns1'].CntryCode "USA"
          xml['ns1'].LangInd "ENG"
        end
      end

      def add_invoice(xml, money, options)
        options[:entry_mode] ||= 'Keyed' # ['Keyed', 'TrackDataFromMSR']
        options[:industry_type] ||= 'Ecommerce' # ['Ecommerce', 'MOTO', 'NotSet', 'Restaurant', 'Retail']
        options[:invoice_number] ||= '802'
        options[:order_number] ||= '629203'

        xml['ns1'].TransactionData do
          if money.blank?
            xml['ns8'].Amount('0.00', 'xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions")
          else
            xml['ns8'].Amount(amount(money), 'xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions")
          end
          xml.CurrencyCode currency(money)
          xml.TransactionDateTime DateTime.now

          xml['ns1'].EntryMode options[:entry_mode]
          xml['ns1'].IndustryType options[:industry_type]
          xml['ns1'].InvoiceNumber options[:invoice_number]
          xml['ns1'].OrderNumber options[:order_number]
          xml['ns1'].CustomerPresent options[:industry_type]
        end
      end

      def add_repayment_invoice(xml, money, options)
        options[:entry_mode] ||= 'Keyed' # ['Keyed', 'TrackDataFromMSR']
        options[:industry_type] ||= 'Ecommerce' # ['Ecommerce', 'MOTO', 'NotSet', 'Restaurant', 'Retail']
        options[:invoice_number] ||= '802'
        options[:order_number] ||= '629203'

        xml['ns1'].TransactionData do
          if money.blank?
            xml['ns8'].Amount('0.00', 'xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions")
          else
            xml['ns8'].Amount(amount(money), 'xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions")
          end
          xml.CurrencyCode currency(money)
          xml.TransactionDateTime DateTime.now

          xml['ns1'].EntryMode options[:entry_mode]
          xml['ns1'].IndustryType options[:industry_type]
          xml['ns1'].InvoiceNumber options[:invoice_number]
          xml['ns1'].OrderNumber options[:order_number]
          xml['ns1'].CustomerPresent options[:industry_type]
          xml['ns1'].CardProduct 'VisaDebtRepayment'
        end
      end

      def parse(action, body)
        doc = Nokogiri::XML(body)
        doc.remove_namespaces!

        response = {action: action}

        response[:status] = if(element = doc.at_xpath("//BankcardTransactionResponsePro/Status"))
          empty?(element.content) ? nil : element.content
        end

        response[:status_code] = if(element = doc.at_xpath("//BankcardTransactionResponsePro/StatusCode"))
          empty?(element.content) ? nil : element.content
        end

        response[:status_message] = if(element = doc.at_xpath("//BankcardTransactionResponsePro/StatusMessage"))
          empty?(element.content) ? nil : element.content
        end

        response[:avs_result_code] = if(element = doc.at_xpath("//AVSResult//ActualResult"))
          empty?(element.content) ? nil : element.content
        end

        response[:transaction_id] = if(element = doc.at_xpath("//TransactionId"))
          empty?(element.content) ? nil : element.content
        end

        response[:transaction_state] = if(element = doc.at_xpath("//TransactionState"))
          empty?(element.content) ? nil : element.content
        end

        response[:card_code] = if(element = doc.at_xpath("//CVResult"))
          empty?(element.content) ? nil : element.content
        end

        response[:cardholder_authentication_code] = if(element = doc.at_xpath("//PaymentAccountDataToken"))
          empty?(element.content) ? nil : element.content
        end

        response[:account_number] = if(element = doc.at_xpath("//MaskedPAN"))
          empty?(element.content) ? nil : element.content[-4..-1]
        end

        response[:is_acknowledged] = if(element = doc.at_xpath("//IsAcknowledged"))
          empty?(element.content) ? false : element.content
        end

        response[:card_product] = if(element = doc.at_xpath("//CardProduct"))
          empty?(element.content) ? nil : element.content
        end

        response
      end

      def parse_response(action, body)
        doc = Nokogiri::XML(body)
        doc.remove_namespaces!

        response = {action: action}

        response[:status] = if(element = doc.at_xpath("//Response/Status"))
          empty?(element.content) ? nil : element.content
        end

        response[:status_code] = if(element = doc.at_xpath("//Response/StatusCode"))
          empty?(element.content) ? nil : element.content
        end

        response[:status_message] = if(element = doc.at_xpath("//Response/StatusMessage"))
          empty?(element.content) ? nil : element.content
        end

        response
      end

      def parse_acknowledged(action, body)
        doc = Nokogiri::XML(body)
        doc.remove_namespaces!

        response = {action: action}

        response[:data] = if(element = doc.at_xpath("ArrayOfSummaryDetail"))
          empty?(element.content) ? nil : element.content
        end

        response
      end

      def commit(action, &payload)
        begin
          puts "url: #{live_url + "/Txn/#{@work_flow_id}"}"
          puts "data: #{post_data(action, &payload)}"

          raw_response = ssl_post(live_url + "/Txn/#{@work_flow_id}", post_data(action, &payload), headers)
          response = parse(action, raw_response)
          avs_result = AVSResult.new(code: response[:avs_result_code])
          cvv_result = CVVResult.new(response[:card_code])

          Response.new(
            success_from(response),
            message_from(response, avs_result, cvv_result),
            response,
            authorization: authorization_from(action, response),
            test: test?,
            avs_result: avs_result,
            cvv_result: cvv_result,
            fraud_review: fraud_review?(response),
            error_code: response[:status_code]
          )
        rescue ActiveMerchant::ResponseError => e
          return ActiveMerchant::Billing::Response.new(false, e.response.message, {:status_code => e.response.code, data: post_data(action, &payload)}, :test => test?)
        end
      end

      def commit_repayment(action, &payload)
        begin
          puts "url: #{repayment_url + "/CWS/1.1/REST/TPS.svc/#{@work_flow_id}"}"
          puts "data: #{post_data(action, &payload)}"

          raw_response = ssl_post(repayment_url + "/CWS/1.1/REST/TPS.svc/#{@work_flow_id}", post_data(action, &payload), headers)
          response = parse(action, raw_response)
          avs_result = AVSResult.new(code: response[:avs_result_code])
          cvv_result = CVVResult.new(response[:card_code])

          Response.new(
            success_from(response),
            message_from(response, avs_result, cvv_result),
            response,
            authorization: authorization_from(action, response),
            test: test?,
            avs_result: avs_result,
            cvv_result: cvv_result,
            fraud_review: fraud_review?(response),
            error_code: response[:status_code]
          )
        rescue ActiveMerchant::ResponseError => e
          return ActiveMerchant::Billing::Response.new(false, e.response.message, {:status_code => e.response.code, data: post_data(action, &payload)}, :test => test?)
        end
      end

      def commit_not_acknowledged(action, &payload)
        begin
          raw_response = ssl_post(live_url + "/REST/2.0.18/DataServices/TMS/transactionssummary", not_acknowledged_data(action, &payload), headers)

          raw_response
        rescue ActiveMerchant::ResponseError => e
          puts "e: #{e.inspect}"
          return ActiveMerchant::Billing::Response.new(false, e.response.message, {:status_code => e.response.code}, :test => test?)
        end
      end

      def commit_acknowledge(action, &payload)
        begin
          raw_response = ssl_put(live_url + "/Txn/#{@work_flow_id}/#{@transaction_id}", put_data(action, &payload), headers)
          response = parse_response(action, raw_response)

          response
        rescue ActiveMerchant::ResponseError => e
          return ActiveMerchant::Billing::Response.new(false, e.response.message, {:status_code => e.response.code}, :test => test?)
        end
      end

      def undo(action, &payload)
        begin
          puts "url: #{live_url + "/Txn/#{@work_flow_id}/#{@transaction_id}"}"
          puts "data: #{undo_data(action, &payload)}"
          raw_response = ssl_put(live_url + "/Txn/#{@work_flow_id}/#{@transaction_id}", undo_data(action, &payload), headers)
          response = parse(action, raw_response)

          response
        rescue ActiveMerchant::ResponseError => e
          return ActiveMerchant::Billing::Response.new(false, e.response.message, {:status_code => e.response.code, data: undo_data(action, &payload)}, :test => test?)
        end
      end

      def returnById(action, &payload)
        begin
          puts "url: #{live_url + "/Txn/#{@work_flow_id}"}"
          puts "data: #{return_data(action, &payload)}"
          raw_response = ssl_post(live_url + "/Txn/#{@work_flow_id}", return_data(action, &payload), headers)
          response = parse(action, raw_response)

          response
        rescue ActiveMerchant::ResponseError => e
          return ActiveMerchant::Billing::Response.new(false, e.response.message, {:status_code => e.response.code, data: return_data(action, &payload)}, :test => test?)
        end
      end

      def handle_resp(response)
        case response.code.to_i
        when 200..499
          response.body
        else
          raise ResponseError.new(response)
        end
      end

      def success_from(response)
        [APPROVED, FRAUD_REVIEW].include?(response[:status_code])
      end

      def message_from(response, avs_result, cvv_result)
        if response[:transaction_state] == 'CaptureDeclined'
          if CARD_CODE_ERRORS.include?(cvv_result.code)
            return cvv_result.message
          elsif(AVS_REASON_CODES.include?(response[:status_code]) && AVS_ERRORS.include?(avs_result.code))
            return avs_result.message
          end
        end

        response[:status_message]
      end

      def authorization_from(action, response)
        [response[:transaction_id], response[:account_number], action].join("#")
      end

      def fraud_review?(response)
        (response[:status_code] == FRAUD_REVIEW)
      end

      def map_error_code(status_code)
        STANDARD_ERROR_CODE_MAPPING["#{status_code}"]
      end

      def not_acknowledged_data(action)
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.send(root_for(action), 'xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/DataServices/TMS/Rest', 'i:type' =>"QueryTransactionsSummary") do
            add_authentication(xml)
            yield(xml)
          end
        end.to_xml(indent: 0)
      end

      def post_data(action)
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.send(root_for(action), 'xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest', 'i:type' =>"AuthorizeAndCaptureTransaction") do
            add_authentication(xml)
            xml.Transaction('xmlns:ns1' => "http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Bankcard", 'i:type' => "ns1:BankcardTransaction" ) do
              yield(xml)
            end
          end
        end.to_xml(indent: 0)
      end

      def put_data(action)
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.send(root_for(action), 'xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest', 'i:type' =>"Acknowledge") do
            add_authentication(xml)
            yield(xml)
          end
        end.to_xml(indent: 0)
      end

      def undo_data(action)
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.send(root_for(action), 'xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest', 'i:type' =>"Undo") do
            xml.ApplicationProfileId @application_profile_id
            xml.BatchIds('xmlns:d2p1'=>"http://schemas.microsoft.com/2003/10/Serialization/Arrays", 'i:nil' =>"true")
            xml.DifferenceData('xmlns:d2p1' => "http://schemas.ipcommerce.com/CWS/v2.0/Transactions", 'i:nil' => "true")
            xml.MerchantProfileId @merchant_profile_id
            yield(xml)
          end
        end.to_xml(indent: 0)
      end

      def return_data(action)
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.send(root_for(action), 'xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest', 'i:type' =>"ReturnById") do
            xml.ApplicationProfileId @application_profile_id
            xml.BatchIds('xmlns:d2p1'=>"http://schemas.microsoft.com/2003/10/Serialization/Arrays", 'i:nil' =>"true")
            yield(xml)
            xml.MerchantProfileId @merchant_profile_id
          end
        end.to_xml(indent: 0)
      end

      def root_for(action)
        if action == :authorize_and_capture
          "AuthorizeAndCaptureTransaction"
        elsif action == :authorize
          "AuthorizeTransaction"
        elsif action == :acknowledge
          "Acknowledge"
        elsif action == :query_transactions_summary
          "QueryTransactionsSummary"
        elsif action == :undo
          "Undo"
        elsif action == :return
          "ReturnById"
        end
      end

      def add_authentication(xml)
        xml.ApplicationProfileId @application_profile_id
        xml.MerchantProfileId @merchant_profile_id
      end

      def headers(options = {})
        token = ssl_get(live_url + '/SvcInfo/token', {
          'Content-Type' => 'application/json',
          'Authorization' => "Basic #{Base64.strict_encode64(@identity_token.gsub(/"/, '').concat(":"))}"
        })
        puts "token: #{Base64.strict_encode64(token.gsub(/"/, '').concat(":"))}"
        {
          'Content-Type' => 'application/xml',
          'Authorization' => "Basic #{Base64.strict_encode64(token.gsub(/"/, '').concat(":"))}"
        }
      end

    end
  end
end
