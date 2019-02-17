module VagrantPlugins
  module Haipa
    module Errors
      class HaipaError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_haipa.errors")
      end

      class APIStatusError < HaipaError
        error_key(:api_status)
      end

      class JSONError < HaipaError
        error_key(:json)
      end

      class ResultMatchError < HaipaError
        error_key(:result_match)
      end

      class CertificateError < HaipaError
        error_key(:certificate)
      end

      class LocalIPError < HaipaError
        error_key(:local_ip)
      end

      class PublicKeyError < HaipaError
        error_key(:public_key)
      end

      class RsyncError < HaipaError
        error_key(:rsync)
      end

      class OperationNotCompleted < HaipaError
        error_key(:rsync)
      end      
    end
  end
end
