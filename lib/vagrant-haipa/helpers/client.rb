require 'vagrant-haipa/helpers/result'
require 'faraday'
require 'json'
module VagrantPlugins
  module Haipa
    module Helpers
      module Client
        def client
          @client ||= ApiClient.new(@machine)
        end
      end

      class ApiClient
        include Vagrant::Util::Retryable

        def initialize(machine)
          @logger = Log4r::Logger.new('vagrant::haipa::apiclient')
          @config = machine.provider_config
          @client = Faraday.new({
            :url => 'http://localhost:62189/',
            :ssl => {
              :ca_file => @config.ca_path
            }
          })
        end

        def delete(path, params = {})
          request(path, params, :delete)
        end

        def post(path, params = {})
          @client.headers['Content-Type'] = 'application/json'
          request(path, params, :post)
        end

        def request(path, params = {}, method = :get)
          begin
            @logger.info "Request: #{path}"
            result = @client.send(method) do |req|
              req.url path
              req.body = params.to_json unless method == :get
              req.params = params if method == :get

              req.headers['Authorization'] = "Bearer #{@config.token}"
            end
          rescue Faraday::Error::ConnectionFailed => e
            # TODO this is suspect but because farady wraps the exception
            #      in something generic there doesn't appear to be another
            #      way to distinguish different connection errors :(
            if e.message =~ /certificate verify failed/
              raise Errors::CertificateError
            end

            raise e
          end

          begin
            body = JSON.parse(result.body)
            body.delete_if { |key, _| key == '@odata.context' }

            @logger.info "Response: #{body}"
          rescue JSON::ParserError => e
            raise(Errors::JSONError, {
              :message => e.message,
              :path => path,
              :params => params,
              :response => result.body
            })
          end

          unless /^2\d\d$/ =~ result.status.to_s
            raise(Errors::APIStatusError, {
              :path => path,
              :params => params,
              :status => result.status,
              :response => body.inspect
            })
          end
          Result.new(body)
        end

        def wait_for_event(env, id)
          timestamp = '2018-09-01T23:47:17.50094+02:00'

          operation_error = nil
          retryable(:tries => 20, :sleep => 5) do
            # stop waiting if interrupted
            next if env[:interrupted]

            # check action status
            result = request("odata/Operations(#{id})", '$expand' => "LogEntries($filter=Timestamp gt #{timestamp})")

            result['LogEntries'].each do |entry|
              env[:ui].info(entry['Message'])

              timestamp = entry['Timestamp']
            end

            yield result if block_given?

            raise 'Operation not completed' if result['Status'] == 'Running' || result['Status'] == 'Queued'
            operation_error = result['StatusMessage'] if result['Status'] == 'Failed'
          end

          raise "Operation failed: #{operation_error}" if operation_error

        end
      end
    end
  end
end
