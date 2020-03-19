require 'esign_identity/configuration'
require 'json'
require 'net/http'
require 'singleton'

module Esign

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end

  class Identity
    include Singleton
    attr_accessor :token_info

    class Unauthorized < StandardError; end

    # 个人银行四要素认证。因为没有让用户多录入银行预留手机号，所以直接用联系方式手机号。
    def identify_individual(name, id_no, bank_card_number, phone_number)
      post_with_token(
          esign_individual_url,
          { name: name, idNo: id_no, cardNo: bank_card_number, mobileNo: phone_number }
      )
    end

    def identify_enterprise(name, social_code, legal_person_name)
      post_with_token(
          esign_enterprise_url,
          { name: name, orgCode: social_code, legalRepName: legal_person_name }
      )
    end

    private

    # 获取易签宝认证服务token
    # token有效时长为120分钟。如果有多台机器建议使用分布式存储，新旧token会共存5分钟。
    # token_info: { 'refreshToken' => 'xx', 'token' => 'xxx', 'expiresIn' => 'xxx' }
    def retrieve_token
      return if self.token_info && self.token_info['expiresIn'].to_i > Time.now.to_i * 1000

      uri = URI.parse(esign_token_url)
      response = Net::HTTP.get(uri)
      self.token_info = JSON.parse(response)['data']
    end

    def post_with_token(url, payload, retry_times = 0)
      retrieve_token
      post!(url, payload)

    rescue Unauthorized
      post_with_token(url, payload, retry_times + 1) if retry_times < 2
    end

    def post!(url, payload)
      uri = URI.parse(url)
      req = Net::HTTP::Post.new(uri, 'Content-Type': 'application/json')
      req['X-Tsign-Open-App-Id'] = esign_app_id
      req['X-Tsign-Open-Token'] = self.token_info['token']
      req.body = payload.to_json
      resp = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') {|http| http.request(req) }

      if resp.instance_of?(Net::HTTPUnauthorized)
        raise Unauthorized
      end

      JSON.parse(resp.body)
    end

    def esign_identity_host
      Esign.configuration.identity_host
    end

    def esign_app_id
      Esign.configuration.app_id
    end

    def esign_app_secret
      Esign.configuration.app_secret
    end

    def esign_individual_url
      "https://#{esign_identity_host}/v2/identity/verify/individual/bank4Factors"
    end

    def esign_enterprise_url
      "https://#{esign_identity_host}/v2/identity/verify/organization/enterprise/bureau3Factors"
    end

    def esign_token_url
      "https://#{esign_identity_host}/v1/oauth2/access_token?appId=#{esign_app_id}&&secret=#{esign_app_secret}&&grantType=client_credentials"
    end
  end
end
