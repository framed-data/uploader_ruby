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

    def upload(filename_or_filenames)
      filenames = array_wrap(filename_or_filenames)

      creds_response = get_credentials
      company_id = creds_response["company_id"]
      access_key = creds_response["access_key"]
      secret_key = creds_response["secret_key"]
      session_token = creds_response["session_token"]

      s3 = Aws::S3::Client.new(client_config(access_key, secret_key, session_token))
      batch_timestamp = Time.now.to_i

      filenames.each do |filename|
        upload_file(s3, company_id, batch_timestamp, filename)
      end
    end

    private

    def array_wrap(object)
      if object.nil?
        []
      elsif object.respond_to?(:to_ary)
        object.to_ary || [object]
      else
        [object]
      end
    end

    def upload_file(s3, company_id, batch_timestamp, filename)
      path = File.expand_path(filename)
      if !File.exists?(path)
        raise FileNotFoundError.new("#{path} doesn't exist")
      end

      s3_key = "#{company_id}/#{batch_timestamp}/#{File.basename(path)}"

      File.open(path, 'rb') do |body|
        s3.put_object(bucket: BUCKET, key: s3_key, body: body)
      end
    end

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

  end
end
