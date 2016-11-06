module Identity
  module Importer
    module Utils

      def self.format_array_for_sql array
        array.map do |value|
          "'#{value}'"
        end.join(",")
      end

    end
  end
end
