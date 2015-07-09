require 'net/http'
require 'json'

require "framed_uploader/version"
require 'aws-sdk'

module FramedUploader
  extend self

  class ConfigurationError < StandardError; end
  class CredentialsError < StandardError; end

  CREDS_ENDPOINT = 'https://app.framed.io/users/credentials'
  REGION = 'us-west-1'
  BUCKET = 'io.framed.users'

  @api_key = nil

  def configure(api_key)
    @api_key = api_key
  end

  def upload(filename)
    unless configured?
      raise ConfigurationError.new("Credentials not set; please call `configure` first!`")
    end

    creds_response = get_credentials
    company_id = creds_response["company_id"]
    access_key = creds_response["access_key"]
    secret_key = creds_response["secret_key"]
    session_token = creds_response["session_token"]

    s3 = Aws::S3::Client.new(client_config(access_key, secret_key, session_token))

    File.open(File.expand_path(filename), 'rb') do |body|
      s3.put_object(bucket: BUCKET, key: csv_key(company_id), body: body)
    end
  end

  private

  def client_config(access_key, secret_key, session_token)
    {
      region: REGION,
      credentials: Aws::Credentials.new(access_key, secret_key, session_token)
    }
  end

  def get_credentials
    uri = URI(CREDS_ENDPOINT)
    resp = Net::HTTP.post_form(uri, 'api_key' => @api_key)

    if resp.is_a?(Net::HTTPSuccess)
      JSON.parse(resp.body)
    else
      raise CredentialsError.new("Error retrieving credentials; please try again shortly (#{res.body})")
    end
  end

  def csv_key(company_id)
    time_str = Time.now.strftime("%Y-%m-%d")
    "#{company_id}/#{time_str}/users.csv"
  end

  def configured?
    !@api_key.nil?
  end

end
