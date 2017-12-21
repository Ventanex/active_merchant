require 'test_helper'

class CardConnectTest < Test::Unit::TestCase
  def setup
    @gateway = CardConnectGateway.new(username: 'username', password: 'password', merchant_id: 'merchand_id')
    @credit_card = credit_card
    @amount = 100

    @options = {
      order_id: '1',
      billing_address: address,
      description: 'Store Purchase'
    }
  end

  def test_successful_purchase
    @gateway.expects(:ssl_request).returns(successful_purchase_response)

    response = @gateway.purchase(@amount, @credit_card, @options)
    assert_success response

    assert_equal '363652261392', response.authorization
    assert response.test?
  end

  def test_failed_purchase
    @gateway.expects(:ssl_request).returns(failed_purchase_response)

    response = @gateway.purchase(@amount, @credit_card, @options)
    assert_failure response
    assert_equal Gateway::STANDARD_ERROR_CODE[:card_declined], response.error_code
  end

  def test_successful_authorize
    @gateway.expects(:ssl_request).returns(successful_authorize_response)

    response = @gateway.authorize(@amount, @credit_card, @options)
    assert_success response

    assert_equal '363168161558', response.authorization
    assert response.test?
  end

  def test_failed_authorize
  end

  def test_successful_capture
    @gateway.expects(:ssl_request).returns(successful_capture_response)

    response = @gateway.capture(@amount, @credit_card, @options)
    assert_success response

    assert_equal '363168161558', response.authorization
    assert response.test?

  end

  def test_failed_capture
  end

  def test_successful_refund
    @gateway.expects(:ssl_request).returns(successful_refund_response)

    response = @gateway.refund(@amount, @credit_card, @options)
    assert_success response

    assert_equal '363661261786', response.authorization
    assert response.test?

  end

  def test_failed_refund
  end

  def test_successful_void
    @gateway.expects(:ssl_request).returns(successful_void_response)

    response = @gateway.void('363750268295')
    assert_success response

    assert_equal '363664261982', response.authorization
    assert response.test?

  end

  def test_failed_void
    @gateway.expects(:ssl_request).returns(failed_void_response)

    response = @gateway.void('')
    assert_failure response

    assert response.test?

  end

  def test_successful_verify
    @gateway.expects(:ssl_request).returns(successful_verify_response)

    response = @gateway.verify(@credit_card, @options)
    assert_success response

    assert_equal '363272166977', response.authorization
    assert response.test?

  end

  def test_successful_purchase_with_echeck
    @gateway.expects(:ssl_request).returns(successful_echeck_purchase_response)

    response = @gateway.purchase(@amount, @check, @options)
    assert_success response

    assert_equal 'trn_bb7687a7-3d3a-40c2-8fa9-90727a814249#123456', response.authorization
    assert response.test?
  end

  def test_failed_purchase_with_echeck
    @gateway.expects(:ssl_request).returns(failed_echeck_purchase_response)

    response = @gateway.purchase(@amount, @credit_card, @options)
    assert_failure response
    assert_equal "INVALID CREDIT CARD NUMBER", response.message
  end

  def test_successful_verify_with_failed_void
  end

  def test_failed_verify
  end

  def test_scrub
    assert @gateway.supports_scrubbing?
    assert_equal @gateway.scrub(pre_scrubbed), post_scrubbed
  end

  private

  def pre_scrubbed
    %q(
      opening connection to fts.cardconnect.com:6443...
      opened
      starting SSL for fts.cardconnect.com:6443...
      SSL established
      <- "PUT /cardconnect/rest/auth HTTP/1.1\r\nAuthorization: Basic dGVzdGluZzp0ZXN0aW5nMTIz\r\nContent-Type: application/json\r\nAccept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3\r\nAccept: */*\r\nUser-Agent: Ruby\r\nConnection: close\r\nHost: fts.cardconnect.com:6443\r\nContent-Length: 298\r\n\r\n"
      <- "{\"orderid\":null,\"ecomind\":\"E\",\"amount\":\"1.00\",\"name\":\"Longbob Longsen\",\"account\":\"4000100011112224\",\"expiry\":\"0918\",\"cvv2\":\"123\",\"currency\":\"USD\",\"address\":\"456 My Street\",\"city\":\"Ottawa\",\"region\":\"ON\",\"country\":\"CA\",\"postal\":\"K1C2N6\",\"phone\":\"(555)555-5555\",\"capture\":\"Y\",\"merchid\":\"496160873888\"}"
      -> "HTTP/1.1 200 OK\r\n"
      -> "X-FRAME-OPTIONS: DENY\r\n"
      -> "Content-Type: application/json\r\n"
      -> "Content-Length: 281\r\n"
      -> "Date: Fri, 29 Dec 2017 23:51:22 GMT\r\n"
      -> "Server: CardConnect\r\n"
      -> "Connection: close\r\n"
      -> "Set-Cookie: BIGipServerphu-smb-vip_8080=!3EyEfCvmvK/UDgCOaMq7McVUJtfXHaj0/1BWyxbacLNntp1E0Upt2onAMTKRSSu6r6mZaKuZm7N9ais=; path=/; Httponly; Secure\r\n"
      -> "\r\n"
      reading 281 bytes...
      -> "{\"amount\":\"1.00\",\"resptext\":\"Approval\",\"commcard\":\" C \",\"cvvresp\":\"M\",\"batchid\":\"1900941444\",\"avsresp\":\" \",\"respcode\":\"00\",\"merchid\":\"496160873888\",\"token\":\"9405701444882224\",\"authcode\":\"PPS568\",\"respproc\":\"FNOR\",\"retref\":\"363743267882\",\"respstat\":\"A\",\"account\":\"9405701444882224\"}"
      read 281 bytes
      Conn close
    )
  end

  def post_scrubbed
    %q(
      opening connection to fts.cardconnect.com:6443...
      opened
      starting SSL for fts.cardconnect.com:6443...
      SSL established
      <- "PUT /cardconnect/rest/auth HTTP/1.1\r\nAuthorization: Basic [FILTERED]\r\nContent-Type: application/json\r\nAccept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3\r\nAccept: */*\r\nUser-Agent: Ruby\r\nConnection: close\r\nHost: fts.cardconnect.com:6443\r\nContent-Length: 298\r\n\r\n"
      <- "{\"orderid\":null,\"ecomind\":\"E\",\"amount\":\"1.00\",\"name\":\"Longbob Longsen\",\"account\":\"[FILTERED]\",\"expiry\":\"0918\",\"cvv2\":\"[FILTERED]\",\"currency\":\"USD\",\"address\":\"456 My Street\",\"city\":\"Ottawa\",\"region\":\"ON\",\"country\":\"CA\",\"postal\":\"K1C2N6\",\"phone\":\"(555)555-5555\",\"capture\":\"Y\",\"merchid\":\"[FILTERED]\"}"
      -> "HTTP/1.1 200 OK\r\n"
      -> "X-FRAME-OPTIONS: DENY\r\n"
      -> "Content-Type: application/json\r\n"
      -> "Content-Length: 281\r\n"
      -> "Date: Fri, 29 Dec 2017 23:51:22 GMT\r\n"
      -> "Server: CardConnect\r\n"
      -> "Connection: close\r\n"
      -> "Set-Cookie: BIGipServerphu-smb-vip_8080=!3EyEfCvmvK/UDgCOaMq7McVUJtfXHaj0/1BWyxbacLNntp1E0Upt2onAMTKRSSu6r6mZaKuZm7N9ais=; path=/; Httponly; Secure\r\n"
      -> "\r\n"
      reading 281 bytes...
      -> "{\"amount\":\"1.00\",\"resptext\":\"Approval\",\"commcard\":\" C \",\"cvvresp\":\"M\",\"batchid\":\"1900941444\",\"avsresp\":\" \",\"respcode\":\"00\",\"merchid\":\"[FILTERED]\",\"token\":\"[FILTERED]\",\"authcode\":\"PPS568\",\"respproc\":\"FNOR\",\"retref\":\"363743267882\",\"respstat\":\"A\",\"account\":\"[FILTERED]\"}"
      read 281 bytes
      Conn close
    )
  end

  def successful_purchase_response
    "{\"amount\":\"1.00\",\"resptext\":\"Approval\",\"commcard\":\" C \",\"cvvresp\":\"M\",\"batchid\":\"1900941444\",\"avsresp\":\" \",\"respcode\":\"00\",\"merchid\":\"496160873888\",\"token\":\"9405701444882224\",\"authcode\":\"PPS500\",\"respproc\":\"FNOR\",\"retref\":\"363652261392\",\"respstat\":\"A\",\"account\":\"9405701444882224\"}"
   end

  def failed_purchase_response
  end

  def successful_authorize_response
    "{\"amount\":\"1.00\",\"resptext\":\"Approval\",\"commcard\":\" C \",\"cvvresp\":\"M\",\"avsresp\":\" \",\"respcode\":\"00\",\"merchid\":\"496160873888\",\"token\":\"9405701444882224\",\"authcode\":\"PPS454\",\"respproc\":\"FNOR\",\"retref\":\"363168161558\",\"respstat\":\"A\",\"account\":\"9405701444882224\"}"
  end

  def failed_authorize_response
  end

  def successful_capture_response
    "{\"respproc\":\"FNOR\",\"amount\":\"1.00\",\"resptext\":\"Approval\",\"setlstat\":\"Queued for Capture\",\"commcard\":\" C \",\"retref\":\"363168161558\",\"respstat\":\"A\",\"respcode\":\"00\",\"batchid\":\"1900941444\",\"account\":\"9405701444882224\",\"merchid\":\"496160873888\",\"token\":\"9405701444882224\"}"
  end

  def failed_capture_response
  end

  def successful_refund_response
    "{\"respproc\":\"PPS\",\"amount\":\"1.00\",\"resptext\":\"Approval\",\"retref\":\"363661261786\",\"respstat\":\"A\",\"respcode\":\"00\",\"merchid\":\"496160873888\"}"
  end

  def failed_refund_response
  end

  def successful_void_response
    "{\"authcode\":\"REVERS\",\"respproc\":\"FNOR\",\"amount\":\"0.00\",\"resptext\":\"Approval\",\"currency\":\"USD\",\"retref\":\"363664261982\",\"respstat\":\"A\",\"respcode\":\"00\",\"merchid\":\"496160873888\"}"
  end

  def failed_void_response
    "{\"respproc\":\"PPS\",\"amount\":\"0.00\",\"resptext\":\"Invalid field\",\"currency\":\"\",\"retref\":\"\",\"respstat\":\"C\",\"respcode\":\"34\",\"merchid\":\"496160873888\"}"
  end

  def successful_verify_response
    "{\"amount\":\"0.00\",\"resptext\":\"Approval\",\"commcard\":\" C \",\"cvvresp\":\"M\",\"avsresp\":\" \",\"respcode\":\"00\",\"merchid\":\"496160873888\",\"token\":\"9405701444882224\",\"authcode\":\"PPS585\",\"respproc\":\"FNOR\",\"retref\":\"363272166977\",\"respstat\":\"A\",\"account\":\"9405701444882224\"}"
  end

  def failed_verify_response
  end


end
