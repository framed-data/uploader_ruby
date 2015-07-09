require 'net/http'
require 'json'
require 'aws-sdk'

module FramedUploader
  class CredentialsError < StandardError; end
  class FileNotFoundError < StandardError; end

  class Uploader
    CREDS_ENDPOINT = 'https://app.framed.io/users/credentials'

    REGION = 'us-west-1'
    BUCKET = 'io.framed.users'

    def initialize(api_key)
      @api_key = api_key
    end

  def upload(filename)
    path = File.expand_path(filename)
    if !File.exists?(path)
      raise FileNotFoundError.new("#{path} doesn't exist")
    end

    creds_response = get_credentials
    company_id = creds_response["company_id"]
    access_key = creds_response["access_key"]
    secret_key = creds_response["secret_key"]
    session_token = creds_response["session_token"]

    s3 = Aws::S3::Client.new(client_config(access_key, secret_key, session_token))

    File.open(path, 'rb') do |body|
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
      raise CredentialsError.new("Error retrieving credentials; please try again shortly (#{resp.body})")
    end
  end

  def csv_key(company_id)
    time_str = Time.now.strftime("%Y-%m-%d")
    "#{company_id}/#{time_str}/users.csv"
  end

  end
end
