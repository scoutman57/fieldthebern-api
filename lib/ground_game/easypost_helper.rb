module GroundGame
  class EasyPostHelper
    def self.create_and_verify_address!(params)
      street1 = params.fetch(:street_1, "")
      street2 = params.fetch(:street_2, "")
      street_name = [street1, street2].reject(&:empty?).join(" ")

      EasyPost::Address.create_and_verify(
        :street1 => street_name,
        :city => params.fetch(:city, nil),
        :state => params.fetch(:state_code, nil),
        :zip => params.fetch(:zip_code, nil)
      )
    end

    def self.create_and_verify_address(params)
      begin
        address = create_and_verify_address! params
        return true, address
      rescue EasyPost::Error
        return false, nil
      end
    end

    def self.easypost_address_to_usps_hash(easypost_address)
      {
        usps_verified_street_1: easypost_address.street1,
        usps_verified_street_2: easypost_address.street2,
        usps_verified_city: easypost_address.city,
        usps_verified_state: easypost_address.state,
        usps_verified_zip: easypost_address.zip
      }
    end

    def self.extend_address_params_with_usps(params)
      success, easypost_address = create_and_verify_address(params)

      if (success)
        usps_hash = easypost_address_to_usps_hash(easypost_address)
        params = params.merge(usps_hash)
      end

      params
    end
  end
end
