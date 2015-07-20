require 'addressable/template'
require 'net/http'
require 'json'
require 'aws-sdk'

module FramedUploader
  class CredentialsError < StandardError; end
  class FileNotFoundError < StandardError; end

  class Uploader
    CREDS_ENDPOINT = 'https://app.framed.io/uploads/1.0/credentials'.freeze

    def initialize(api_key)
      @api_key = api_key
    end

    def upload(*filenames)
      validate_files!(filenames)

      creds_response = get_credentials!
      tmpl = Addressable::Template.new(creds_response.fetch(:template))
      bucket = creds_response.fetch(:bucket)
      company_id = creds_response.fetch(:company_id)
      batch_timestamp = Time.now.to_i
      s3 = s3_client(creds_response)

      filenames.each do |filename|
        s3_key = tmpl.expand({"company_id" => company_id,
                              "timestamp" => batch_timestamp,
                              "filename" => filename}).path

        File.open(filename, 'rb') do |body|
          s3.put_object(bucket: bucket, key: s3_key, body: body)
        end
      end
    end

    private

    def validate_files!(filenames)
      filenames.each do |filename|
        path = File.expand_path(filename)
        if !File.exists?(path)
          raise FileNotFoundError.new("#{path} doesn't exist")
        end
      end
    end

    # options - Hash of
    #   :region
    #   :access_key
    #   :secret_key
    #   :session_token
    def s3_client(options)
      region = options.fetch(:region)
      access_key = options.fetch(:access_key)
      secret_key = options.fetch(:secret_key)
      session_token = options.fetch(:session_token)

      s3 = Aws::S3::Client.new(
        region: region,
        credentials: Aws::Credentials.new(access_key, secret_key, session_token)
      )
    end

    # Retrieve S3 credentials and information from the Framed API
    def get_credentials!
      uri = URI(CREDS_ENDPOINT)
      req = Net::HTTP::Post.new(uri.request_uri)
      req.basic_auth(@api_key, "")
      resp = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |https|
        https.request(req)
      end

      if resp.is_a?(Net::HTTPSuccess)
        JSON.parse(resp.body, {:symbolize_names => true})
      else
        raise CredentialsError.new("Error retrieving credentials; please try again shortly (#{resp.body})")
      end
    end

  end
end
