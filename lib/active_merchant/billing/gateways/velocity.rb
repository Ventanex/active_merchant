# require 'active_merchant'
#
# gateway = ActiveMerchant::Billing::VelocityGateway.new({
#   identity_token: 'PHNhbWw6QXNzZXJ0aW9uIE1ham9yVmVyc2lvbj0iMSIgTWlub3JWZXJzaW9uPSIxIiBBc3NlcnRpb25JRD0iXzU4ZTM5MGFjLTE0OWItNDNiYS1iOGU0LTQ3ZmEzOWUyZWM3MCIgSXNzdWVyPSJJcGNBdXRoZW50aWNhdGlvbiIgSXNzdWVJbnN0YW50PSIyMDE2LTA5LTIwVDIxOjQ5OjE1LjI0MloiIHhtbG5zOnNhbWw9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjEuMDphc3NlcnRpb24iPjxzYW1sOkNvbmRpdGlvbnMgTm90QmVmb3JlPSIyMDE2LTA5LTIwVDIxOjQ5OjE1LjI0MloiIE5vdE9uT3JBZnRlcj0iMjA0Ni0wOS0yMFQyMTo0OToxNS4yNDJaIj48L3NhbWw6Q29uZGl0aW9ucz48c2FtbDpBZHZpY2U+PC9zYW1sOkFkdmljZT48c2FtbDpBdHRyaWJ1dGVTdGF0ZW1lbnQ+PHNhbWw6U3ViamVjdD48c2FtbDpOYW1lSWRlbnRpZmllcj4xMzEzODY4NTQxMzAwMDAxPC9zYW1sOk5hbWVJZGVudGlmaWVyPjwvc2FtbDpTdWJqZWN0PjxzYW1sOkF0dHJpYnV0ZSBBdHRyaWJ1dGVOYW1lPSJTQUsiIEF0dHJpYnV0ZU5hbWVzcGFjZT0iaHR0cDovL3NjaGVtYXMuaXBjb21tZXJjZS5jb20vSWRlbnRpdHkiPjxzYW1sOkF0dHJpYnV0ZVZhbHVlPjEzMTM4Njg1NDEzMDAwMDE8L3NhbWw6QXR0cmlidXRlVmFsdWU+PC9zYW1sOkF0dHJpYnV0ZT48c2FtbDpBdHRyaWJ1dGUgQXR0cmlidXRlTmFtZT0iU2VyaWFsIiBBdHRyaWJ1dGVOYW1lc3BhY2U9Imh0dHA6Ly9zY2hlbWFzLmlwY29tbWVyY2UuY29tL0lkZW50aXR5Ij48c2FtbDpBdHRyaWJ1dGVWYWx1ZT5hNWMyYmQ3ZS1iMTA3LTQ0YjYtODhhZS01YjM2ZTYxYjEyY2U8L3NhbWw6QXR0cmlidXRlVmFsdWU+PC9zYW1sOkF0dHJpYnV0ZT48c2FtbDpBdHRyaWJ1dGUgQXR0cmlidXRlTmFtZT0ibmFtZSIgQXR0cmlidXRlTmFtZXNwYWNlPSJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcyI+PHNhbWw6QXR0cmlidXRlVmFsdWU+MTMxMzg2ODU0MTMwMDAwMTwvc2FtbDpBdHRyaWJ1dGVWYWx1ZT48L3NhbWw6QXR0cmlidXRlPjwvc2FtbDpBdHRyaWJ1dGVTdGF0ZW1lbnQ+PFNpZ25hdHVyZSB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC8wOS94bWxkc2lnIyI+PFNpZ25lZEluZm8+PENhbm9uaWNhbGl6YXRpb25NZXRob2QgQWxnb3JpdGhtPSJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzEwL3htbC1leGMtYzE0biMiPjwvQ2Fub25pY2FsaXphdGlvbk1ldGhvZD48U2lnbmF0dXJlTWV0aG9kIEFsZ29yaXRobT0iaHR0cDovL3d3dy53My5vcmcvMjAwMC8wOS94bWxkc2lnI3JzYS1zaGExIj48L1NpZ25hdHVyZU1ldGhvZD48UmVmZXJlbmNlIFVSST0iI181OGUzOTBhYy0xNDliLTQzYmEtYjhlNC00N2ZhMzllMmVjNzAiPjxUcmFuc2Zvcm1zPjxUcmFuc2Zvcm0gQWxnb3JpdGhtPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwLzA5L3htbGRzaWcjZW52ZWxvcGVkLXNpZ25hdHVyZSI+PC9UcmFuc2Zvcm0+PFRyYW5zZm9ybSBBbGdvcml0aG09Imh0dHA6Ly93d3cudzMub3JnLzIwMDEvMTAveG1sLWV4Yy1jMTRuIyI+PC9UcmFuc2Zvcm0+PC9UcmFuc2Zvcm1zPjxEaWdlc3RNZXRob2QgQWxnb3JpdGhtPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwLzA5L3htbGRzaWcjc2hhMSI+PC9EaWdlc3RNZXRob2Q+PERpZ2VzdFZhbHVlPnRhbllYWlVzQmNibjhrYWhmREdwYTFkelZGUT08L0RpZ2VzdFZhbHVlPjwvUmVmZXJlbmNlPjwvU2lnbmVkSW5mbz48U2lnbmF0dXJlVmFsdWU+SGdsMktLR0VPcVBQUDAydnVTRnRHTTEwMkxoZEI2OXp2ZXh3ejZzN2VqQTBBNUl4NGk0U2FsUE1ZYW85MDJkUjZUSzY0eWxCb3oxRnJ2OXpFZUpHQW9hWjZWbktZSVNENTlmSU03dDJYME5SVk9YM1daRTFaRXhwaG1zL3JJL0EzcW41SDlBT1l5OUxhMXBlVHA2TytBenVWYzFONjdBM214WmpERlIyNGhlallwVHJ2TU9PNHQ3M1c2Tm9nMDlSaTRjclRLNERTN21Mekp2VkRzRlB1bkF1dVN4eVBDK0l4VDVNTXBaSDcxNkdzdXhmU0R1anVXaEk1YkV1bFVrNEQyL2s3MEE3RDdkRjJIV3VEMEtuUXhrV2dKM2pVNldyUHp2UC9Mc3djaFZSOWdqNHd6WnpqTXRpY3N3VXJMYnorVXpJY0h1S0IySkw2djdUZTNYb3JnPT08L1NpZ25hdHVyZVZhbHVlPjxLZXlJbmZvPjxvOlNlY3VyaXR5VG9rZW5SZWZlcmVuY2UgeG1sbnM6bz0iaHR0cDovL2RvY3Mub2FzaXMtb3Blbi5vcmcvd3NzLzIwMDQvMDEvb2FzaXMtMjAwNDAxLXdzcy13c3NlY3VyaXR5LXNlY2V4dC0xLjAueHNkIj48bzpLZXlJZGVudGlmaWVyIFZhbHVlVHlwZT0iaHR0cDovL2RvY3Mub2FzaXMtb3Blbi5vcmcvd3NzL29hc2lzLXdzcy1zb2FwLW1lc3NhZ2Utc2VjdXJpdHktMS4xI1RodW1icHJpbnRTSEExIj5ZREJlRFNGM0Z4R2dmd3pSLzBwck11OTZoQ2M9PC9vOktleUlkZW50aWZpZXI+PC9vOlNlY3VyaXR5VG9rZW5SZWZlcmVuY2U+PC9LZXlJbmZvPjwvU2lnbmF0dXJlPjwvc2FtbDpBc3NlcnRpb24+',
#   work_flow_id: '8D9DE00001',
#   application_profile_id: 71228,
#   merchant_profile_id: 'EPX Retail Test'
# })
#
# amount = 1000  # $10.00
#
# credit_card = ActiveMerchant::Billing::CreditCard.new(
#                 :first_name         => 'Bob',
#                 :last_name          => 'Bobsen',
#                 :number             => '4242424242424242',
#                 :month              => '8',
#                 :year               => Time.now.year+1,
#                 :verification_value => '000')
#
# gateway.purchase(amount, credit_card)

require 'byebug'
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

      STANDARD_ERROR_CODE_MAPPING = {}

      def initialize(options={})
        requires!(options, :identity_token, :work_flow_id, :application_profile_id, :merchant_profile_id)
        @identity_token = options[:identity_token]
        @work_flow_id = options[:work_flow_id]
        @application_profile_id = options[:application_profile_id]
        @merchant_profile_id = options[:merchant_profile_id]
        super
      end

      def purchase(money, payment, options={})
        post = {}
        add_invoice(post, money, options)
        add_address(post, payment, options)
        add_customer_data(post, options)

        commit('authorize_and_capture', post)
      end

      def authorize(money, payment, options={})
        post = {}
        add_invoice(post, money, options)
        add_address(post, payment, options)
        add_customer_data(post, options)

        commit('authorize', post)
      end

      def capture(money, authorization, options={})
        commit('capture', post)
      end

      def refund(money, authorization, options={})
        commit('refund', post)
      end

      def void(authorization, options={})
        commit('void', post)
      end

      def verify(credit_card, options={})
        MultiResponse.run(:use_first_response) do |r|
          r.process { authorize(100, credit_card, options) }
          r.process(:ignore_result) { void(r.authorization, options) }
        end
      end

      def supports_scrubbing?
        true
      end

      def scrub(transcript)
        transcript
      end

      private

      def add_customer_data(post, options)
        post[:Phone] = '9540123123'
        post[:Email] = 'najeers@chetu.com'
      end

      def add_address(post, creditcard, options)
        post[:Street1] = '4 corporate sq'
        post[:City] = 'dever'
        post[:CountryCode] = 'USA'
        post[:PostalCode] = '30329'
        post[:CardType] = 'Visa'
        post[:CVData] = '123'
        post[:PAN] = '4012888812348882'
        post[:Expire] = '0320'
      end

      def add_invoice(post, money, options)
        post[:Amount] = '539.99'
        post[:IndustryType] = 'Ecommerce'
        post[:InvoiceNumber] = '802'
        post[:OrderNumber] = '629203'
        post[:EntryMode] = 'Keyed'
        post[:currency] = currency(money)
      end


      def parse(body)
        Hash.from_xml(body)['BankcardTransactionResponsePro'].deep_transform_keys { |k| k.to_s.underscore.to_sym }.except(:xmlns, :"xmlns:i", :addendum)
      end

      def commit(action, parameters)
        response = parse(ssl_post(live_url + "/Txn/#{@work_flow_id}", post_data(action, parameters), headers))

        Response.new(
          success_from(response),
          message_from(response),
          response,
          authorization: authorization_from(response),
          avs_result: AVSResult.new(response["avs_result"]),
          cvv_result: CVVResult.new(response["cvv_result"]),
          test: test?,
          error_code: error_code_from(response)
        )
      end

      def success_from(response)
      end

      def message_from(response)
      end

      def authorization_from(response)
      end

      def error_code_from(response)
        unless success_from(response)
        end
      end

      def post_data(action, parameters = {})
        case action
        when 'authorize'
          authorize_xml(parameters).to_xml
        when 'authorize_and_capture'
          authorize_and_capture_xml(parameters).to_xml
        end
      end

      def headers(options = {})
        token = ssl_get(live_url + '/SvcInfo/token', {
          'Content-Type' => 'application/json',
          'Authorization' => "Basic #{Base64.strict_encode64(@identity_token.gsub(/"/, '').concat(":"))}"
        })

        {
          'Content-Type' => 'text/xml',
          "Authorization" => "Basic #{Base64.strict_encode64(token.gsub(/"/, '').concat(":"))}"
        }
      end

      def authorize_and_capture_xml(params)
        Nokogiri::XML::Builder.new do |xml|
          xml.AuthorizeAndCaptureTransaction('xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest', 'i:type' =>"AuthorizeAndCaptureTransaction" ) do
            xml.ApplicationProfileId @application_profile_id
            xml.MerchantProfileId @merchant_profile_id
            xml.Transaction('xmlns:ns1' => "http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Bankcard", 'i:type' => "ns1:BankcardTransaction" ) do
              xml['ns1'].TenderData do
              xml['ns4'].PaymentAccountDataToken('xmlns:ns4' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions", 'i:nil' =>"true")
              xml['ns5'].SecurePaymentAccountData('xmlns:ns5' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
              xml['ns6'].EncryptionKeyId('xmlns:ns6' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
              xml['ns7'].SwipeStatus('xmlns:ns7' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
              xml['ns1'].CardData do
                xml['ns1'].CardType params[:CardType]
                xml['ns1'].PAN params[:PAN]
                xml['ns1'].Expire params[:Expire]
                xml['ns1'].Track1Data('i:nil' =>"true")
                xml['ns1'].Track2Data('i:nil' =>"true")
              end
              xml['ns1'].EcommerceSecurityData('i:nil' =>"true")
            end
              xml['ns2'].CustomerData('xmlns:ns2' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions") do
                xml['ns2'].BillingData do
                  xml['ns2'].Name('i:nil' =>"true")
                  xml['ns2'].Address do
                    xml['ns2'].Street1 params[:Street1]
                    xml['ns2'].Street2('i:nil' =>"true")
                    xml['ns2'].City params[:City]
                    xml['ns2'].StateProvince params[:StateProvince]
                    xml['ns2'].PostalCode params[:PostalCode]
                    xml['ns2'].CountryCode params[:CountryCode]
                  end
                  xml['ns2'].BusinessName 'MomCorp'
                  xml['ns2'].Phone params[:Phone]
                  xml['ns2'].Fax('i:nil' =>"true")
                  xml['ns2'].Email params[:Email]
                end
                xml['ns2'].CustomerId 'cust123'
                xml['ns2'].CustomerTaxId('i:nil' =>"true")
                xml['ns2'].ShippingData('i:nil' =>"true")
              end
              xml['ns3'].ReportingData('xmlns:ns3' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions") do
                xml['ns3'].Comment 'a test comment'
                xml['ns3'].Description 'a test description'
                xml['ns3'].Reference '001'
              end
              xml['ns1'].TransactionData do
                if params[:Amount] != ''
                  xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:Amount])
                else
                  xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('0.00')
                end
                xml['ns9'].CurrencyCode('xmlns:ns9' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('USD')
                xml['ns10'].TransactionDateTime('xmlns:ns10' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(DateTime.now)
                xml['ns11'].CampaignId('xmlns:ns11' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
                xml['ns12'].Reference('xmlns:ns12' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('xyt')
                xml['ns1'].AccountType 'NotSet'
                xml['ns1'].ApprovalCode('i:nil' =>"true")
                xml['ns1'].CashBackAmount '0.0'
                xml['ns1'].CustomerPresent 'Present'
                xml['ns1'].EmployeeId '11'
                xml['ns1'].EntryMode params[:EntryMode]
                xml['ns1'].GoodsType 'NotSet'
                xml['ns1'].IndustryType params[:IndustryType]
                xml['ns1'].InternetTransactionData('i:nil' =>"true")
                xml['ns1'].InvoiceNumber params[:InvoiceNumber]
                xml['ns1'].OrderNumber params[:OrderNumber]
                xml['ns1'].IsPartialShipment 'false'
                xml['ns1'].SignatureCaptured 'false'
                xml['ns1'].FeeAmount '0.0'
                xml['ns1'].TerminalId('i:nil' =>"true")
                xml['ns1'].LaneId('i:nil' =>"true")
                xml['ns1'].TipAmount '0.0'
                xml['ns1'].BatchAssignment('i:nil' =>"true")
                xml['ns1'].PartialApprovalCapable 'NotSet'
                xml['ns1'].ScoreThreshold('i:nil' =>"true")
                xml['ns1'].IsQuasiCash 'false'
              end
            end
          end
        end
      end

      def authorize_xml(params)
        Nokogiri::XML::Builder.new do |xml|
          xml.AuthorizeTransaction('xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest', 'i:type' =>"AuthorizeTransaction" ) do
            xml.ApplicationProfileId @application_profile_id
            xml.MerchantProfileId @merchant_profile_id
            xml.Transaction('xmlns:ns1' => "http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Bankcard", 'i:type' => "ns1:BankcardTransaction" ) do
              xml['ns1'].TenderData do
                xml['ns1'].CardData do
                  xml['ns1'].CardType params[:CardType]
                  xml['ns1'].CardholderName params[:CardholderName]
                  if params[:Track2Data].present?
                    xml['ns1'].Track2Data params[:Track2Data]
                    xml['ns1'].PAN('i:nil' =>"true")
                    xml['ns1'].Expire('i:nil' =>"true")
                    xml['ns1'].Track1Data('i:nil' =>"true")
                  elsif params[:Track1Data].present?
                    xml['ns1'].Track1Data params[:Track1Data]
                    xml['ns1'].PAN('i:nil' =>"true")
                    xml['ns1'].Expire('i:nil' =>"true")
                    xml['ns1'].Track2Data('i:nil' =>"true")
                  else
                    xml['ns1'].PAN params[:PAN]
                    xml['ns1'].Expire params[:Expire]
                    xml['ns1'].Track1Data('i:nil' =>"true")
                    xml['ns1'].Track2Data('i:nil' =>"true")
                  end
                end
                xml['ns1'].CardSecurityData do
                  xml['ns1'].AVSData do
                    xml['ns1'].CardholderName('i:nil' =>"true")
                    xml['ns1'].Street params[:Street]
                    xml['ns1'].City params[:City]
                    xml['ns1'].StateProvince params[:StateProvince]
                    xml['ns1'].PostalCode params[:PostalCode]
                    xml['ns1'].Phone params[:Phone]
                    xml['ns1'].Email params[:Email]
                  end
                  xml['ns1'].CVDataProvided 'Provided'
                  xml['ns1'].CVData params[:CVData]
                  xml['ns1'].KeySerialNumber('i:nil' =>"true")
                  xml['ns1'].PIN('i:nil' =>"true")
                  xml['ns1'].IdentificationInformation('i:nil' =>"true")
                end
                xml['ns1'].EcommerceSecurityData('i:nil' =>"true")
              end
              xml['ns1'].TransactionData do
                if params[:Amount] != ''
                  xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:Amount])
                else
                  xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('0.00')
                end
                xml['ns9'].CurrencyCode('xmlns:ns9' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('USD')
                xml['ns10'].TransactionDateTime('xmlns:ns10' => "http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('2014-04-03T13:50:16')
                xml['ns1'].AccountType 'NotSet'
                xml['ns1'].CustomerPresent 'Present'
                xml['ns1'].EmployeeId '11'
                if params[:Track2Data].present? || params[:Track1Data].present?
                  xml['ns1'].EntryMode params[:EntryMode]
                else
                  xml['ns1'].EntryMode 'Keyed'
                end
                xml['ns1'].IndustryType params[:IndustryType]
                xml['ns1'].InvoiceNumber('i:nil' =>"true")
                xml['ns1'].OrderNumber('i:nil' =>"true")
                xml['ns1'].TipAmount '0.0'
              end
            end
          end
        end
      end
    end
  end
end
