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

        def delete(path, params = {}, method = :delete)
          @client.request :url_encoded
          request(path, params, :delete)
        end

        def post(path, params = {}, method = :post)
          @client.headers['Content-Type'] = 'application/json'
          request(path, params, :post)
        end

        def request(path, params = {}, method = :get)
          begin
            @logger.info "Request: #{path}"
            result = @client.send(method) do |req|
              req.url path
              req.body = params.to_json if method == :post
              req.params = params unless method == :post || method == :delete
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
            body.delete_if {|key, value| key == '@odata.context' }

            @logger.info "Response: #{body}"
            next_page = body["links"]["pages"]["next"] rescue nil
            unless next_page.nil?
              uri = URI.parse(next_page)
              new_path = path.split("?")[0]
              next_result = self.request("#{new_path}?#{uri.query}")
              req_target = new_path.split("/")[-1]
              if req_target == 'keys'
                      req_target = 'ssh_keys'
              end
              body["#{req_target}"].concat(next_result["#{req_target}"])
            end
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

          retryable(:tries => 20, :sleep => 5) do
            # stop waiting if interrupted
            next if env[:interrupted]

            # check action status
            result = request("odata/OperationSet(#{id})", '$expand' => "LogEntries($filter=Timestamp gt #{timestamp})")

            result['LogEntries'].each do |entry|
              env[:ui].info(entry['Message'])

              timestamp = entry['Timestamp']
            end

            next if result['Status'] == 'Failed'

            yield result if block_given?
            raise 'Operation not completed' if result['Status'] == 'Running' || result['Status'] == 'Queued'
          end

          #raise "Operation failed: #{result['StatusMessage']}" if result['Status'] == 'Failed'

        end
      end
    end
  end
end
