require 'nokogiri'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class VelocityGateway < Gateway
      include Empty
      self.live_url = 'https://api.cert.nabcommerce.com/REST/2.0.18'

      self.supported_countries = ['US']
      self.default_currency = 'USD'
      self.supported_cardtypes = [:visa, :master, :american_express, :discover]

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

      def initialize(options={})
        requires!(options, :identity_token, :work_flow_id, :application_profile_id, :merchant_profile_id)
        @identity_token = options[:identity_token]
        @work_flow_id = options[:work_flow_id]
        @application_profile_id = options[:application_profile_id]
        @merchant_profile_id = options[:merchant_profile_id]
        super
      end

      def purchase(money, payment, options={})
        commit(:authorize_and_capture) do |xml|
          add_payment_source(xml, payment)
          # add_customer_data(xml, payment, options)
          # add_reporting_data(xml, options)
          add_invoice(xml, money, options)
        end
      end

      # def authorize(money, payment, options={})
      #   post = {}
      #   add_invoice(post, money, options)
      #   add_address(post, payment, options)
      #   add_customer_data(post, options)
      #
      #   commit('authorize', post)
      # end
      #
      # def capture(money, authorization, options={})
      #   commit('capture', post)
      # end
      #
      # def refund(money, authorization, options={})
      #   commit('refund', post)
      # end
      #
      # def void(authorization, options={})
      #   commit('void', post)
      # end
      #
      # def verify(credit_card, options={})
      #   MultiResponse.run(:use_first_response) do |r|
      #     r.process { authorize(100, credit_card, options) }
      #     r.process(:ignore_result) { void(r.authorization, options) }
      #   end
      # end

      def supports_scrubbing?
        true
      end

      def scrub(transcript)
        transcript
      end

      private

      def add_payment_source(xml, source)
        return unless source

        xml['ns1'].TenderData do
          # xml['ns4'].PaymentAccountDataToken('xmlns:ns4' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions", 'i:nil' =>"true")
          # xml['ns5'].SecurePaymentAccountData('xmlns:ns5' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions", 'i:nil' =>"true")
          # xml['ns6'].EncryptionKeyId('xmlns:ns6' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
          # xml['ns7'].SwipeStatus('xmlns:ns7' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
          xml['ns1'].CardData do
            xml['ns1'].CardType source.brand.titleize
            xml['ns1'].PAN truncate(source.number, 16)
            xml['ns1'].Expire source.expiry_date.expiration.strftime('%m%y')
            # xml['ns1'].Track1Data('i:nil' =>"true")
            # xml['ns1'].Track2Data('i:nil' =>"true")
          end
          # xml['ns1'].EcommerceSecurityData('i:nil' =>"true")
        end
      end

      def add_customer_data(xml, creditcard, options)
        options[:phone] ||= '9540123123'
        options[:email] ||= 'najeers@chetu.com'
        options[:street1] ||= '4 corporate sq'
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
              xml['ns2'].Street2('i:nil' =>"true")
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
          # xml.CampaignId('i:nil' =>"true")
          xml.CurrencyCode currency(money)
          xml.TransactionDateTime DateTime.now
          # xml['ns12'].Reference('xmlns:ns12' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('xyt')
          # xml['ns1'].AccountType 'NotSet'
          # xml['ns1'].ApprovalCode('i:nil' =>"true")
          # xml['ns1'].CashBackAmount '0.0'
          # xml['ns1'].CustomerPresent 'Present'
          # xml['ns1'].EmployeeId '11'
          xml['ns1'].EntryMode options[:entry_mode]
          # xml['ns1'].GoodsType 'NotSet'
          xml['ns1'].IndustryType options[:industry_type]
          # xml['ns1'].InternetTransactionData('i:nil' =>"true")
          xml['ns1'].InvoiceNumber options[:invoice_number]
          xml['ns1'].OrderNumber options[:order_number]
          # xml['ns1'].IsPartialShipment 'false'
          # xml['ns1'].SignatureCaptured 'false'
          # xml['ns1'].FeeAmount '0.0'
          # xml['ns1'].TerminalId('i:nil' =>"true")
          # xml['ns1'].LaneId('i:nil' =>"true")
          # xml['ns1'].TipAmount '0.0'
          # xml['ns1'].BatchAssignment('i:nil' =>"true")
          # xml['ns1'].PartialApprovalCapable 'NotSet'
          # xml['ns1'].ScoreThreshold('i:nil' =>"true")
          # xml['ns1'].IsQuasiCash 'false'
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

        response[:transaction_id] = if(element = doc.at_xpath("//ServiceTransactionId"))
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

        response
      end

      def commit(action, &payload)
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
          error_code: map_error_code(response[:status_code])
        )
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

      def root_for(action)
        if action == :authorize_and_capture
          "AuthorizeAndCaptureTransaction"
        elsif action == :authorize
          "AuthorizeTransaction"
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

        {
          'Content-Type' => 'text/xml',
          'Authorization' => "Basic #{Base64.strict_encode64(token.gsub(/"/, '').concat(":"))}"
        }
      end

      # def authorize_xml(params)
      #   Nokogiri::XML::Builder.new do |xml|
      #     xml.AuthorizeTransaction('xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest', 'i:type' =>"AuthorizeTransaction" ) do
      #       xml.ApplicationProfileId @application_profile_id
      #       xml.MerchantProfileId @merchant_profile_id
      #       xml.Transaction('xmlns:ns1' => "http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Bankcard", 'i:type' => "ns1:BankcardTransaction" ) do
      #         xml['ns1'].TenderData do
      #           xml['ns1'].CardData do
      #             xml['ns1'].CardType params[:card_type]
      #             xml['ns1'].CardholderName params[:card_holder_name]
      #             if params[:track_2_data].present?
      #               xml['ns1'].Track2Data params[:track_2_data]
      #               xml['ns1'].PAN('i:nil' =>"true")
      #               xml['ns1'].Expire('i:nil' =>"true")
      #               xml['ns1'].Track1Data('i:nil' =>"true")
      #             elsif params[:track_1_data].present?
      #               xml['ns1'].Track1Data params[:track_1_data]
      #               xml['ns1'].PAN('i:nil' =>"true")
      #               xml['ns1'].Expire('i:nil' =>"true")
      #               xml['ns1'].Track2Data('i:nil' =>"true")
      #             else
      #               xml['ns1'].PAN params[:pan]
      #               xml['ns1'].Expire params[:expire]
      #               xml['ns1'].Track1Data('i:nil' =>"true")
      #               xml['ns1'].Track2Data('i:nil' =>"true")
      #             end
      #           end
      #           xml['ns1'].CardSecurityData do
      #             xml['ns1'].AVSData do
      #               xml['ns1'].CardholderName('i:nil' =>"true")
      #               xml['ns1'].Street params[:Street]
      #               xml['ns1'].City params[:city]
      #               xml['ns1'].StateProvince params[:state_province]
      #               xml['ns1'].PostalCode params[:postal_code]
      #               xml['ns1'].Phone params[:phone]
      #               xml['ns1'].Email params[:email]
      #             end
      #             xml['ns1'].CVDataProvided 'Provided'
      #             xml['ns1'].CVData params[:cv_data]
      #             xml['ns1'].KeySerialNumber('i:nil' =>"true")
      #             xml['ns1'].PIN('i:nil' =>"true")
      #             xml['ns1'].IdentificationInformation('i:nil' =>"true")
      #           end
      #           xml['ns1'].EcommerceSecurityData('i:nil' =>"true")
      #         end
      #         xml['ns1'].TransactionData do
      #           if params[:amount] != ''
      #             xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:amount])
      #           else
      #             xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('0.00')
      #           end
      #           xml['ns9'].CurrencyCode('xmlns:ns9' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('USD')
      #           xml['ns10'].TransactionDateTime('xmlns:ns10' => "http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('2014-04-03T13:50:16')
      #           xml['ns1'].AccountType 'NotSet'
      #           xml['ns1'].CustomerPresent 'Present'
      #           xml['ns1'].EmployeeId '11'
      #           if params[:track_2_data].present? || params[:track_1_data].present?
      #             xml['ns1'].EntryMode params[:entry_mode]
      #           else
      #             xml['ns1'].EntryMode 'Keyed'
      #           end
      #           xml['ns1'].IndustryType params[:industry_type]
      #           xml['ns1'].InvoiceNumber('i:nil' =>"true")
      #           xml['ns1'].OrderNumber('i:nil' =>"true")
      #           xml['ns1'].TipAmount '0.0'
      #         end
      #       end
      #     end
      #   end
      # end
    end
  end
end
