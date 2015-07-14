require 'net/http'
require 'json'
require 'aws-sdk'

module FramedUploader
  class CredentialsError < StandardError; end
  class FileNotFoundError < StandardError; end

  class Uploader
    CREDS_ENDPOINT = 'https://app.framed.io/uploads/credentials'

    def initialize(api_key)
      @api_key = api_key
    end

    def upload(filename_or_filenames)
      filenames = array_wrap(filename_or_filenames)

      creds_response = get_credentials!
      s3 = s3_client(creds_response)
      batch_timestamp = Time.now.to_i

      filenames.each do |filename|
        options = {
          :company_id => creds_response[:company_id],
          :batch_timestamp => batch_timestamp,
          :filename => filename,
          :bucket => creds_response[:bucket]
        }
        upload_file(s3, options)
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

      s3 = Aws::S3::Client.new({
        region: region,
        credentials: Aws::Credentials.new(access_key, secret_key, session_token)
      })
    end

    # options - Hash of
    #   :company_id
    #   :batch_timestamp
    #   :filename
    #   :bucket
    def upload_file(s3, options)
      company_id = options.fetch(:company_id)
      batch_timestamp = options.fetch(:batch_timestamp)
      filename = options.fetch(:filename)
      bucket = options.fetch(:bucket)

      path = File.expand_path(filename)
      if !File.exists?(path)
        raise FileNotFoundError.new("#{path} doesn't exist")
      end

      s3_key = "#{company_id}/#{batch_timestamp}/#{File.basename(path)}"

      File.open(path, 'rb') do |body|
        s3.put_object(bucket: bucket, key: s3_key, body: body)
      end
    end

    # Retrieve S3 credentials and information from the Framed API
    def get_credentials!
      uri = URI(CREDS_ENDPOINT)
      resp = Net::HTTP.post_form(uri, 'api_key' => @api_key)

      if resp.is_a?(Net::HTTPSuccess)
        JSON.parse(resp.body, {:symbolize_names => true})
      else
        raise CredentialsError.new("Error retrieving credentials; please try again shortly (#{resp.body})")
      end
    end

  end
end
