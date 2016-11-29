require 'chef/knife/joyent_base'

class Chef
  class Knife
    class JoyentServerList < Knife

      include Knife::JoyentBase

      option :show,
        :long => '--show field1,field1,.',
        :description => 'Show additional fields. Supported: compute_node, tags',
        :proc => Proc.new {|key| Chef::Config[:knife][:show] = key.to_s.split(/,/).map(&:to_sym)}

      option :sort,
        :long => '--sort field',
        :description => 'Sort by field, default is name, supported also: compute_node, price',
        :proc => Proc.new {|key| Chef::Config[:knife][:sort] = key.to_sym}

      banner "knife joyent server list <options>"

      ADDITIONAL_FIELDS = [:compute_node, :tags]

      PRICE_COLUMN_WIDTH = 11

      def run

        sort_matrix = {
          :name => lambda do |a, b|
            (a.name || '') <=> (b.name || '')
          end,
          :compute_node => lambda do |a, b|
            (a.compute_node || '') <=> (b.compute_node || '')
          end,
          :price => lambda do |a, b|
            if a.package && b.package
              pricing.monthly_price(a.package) <=> pricing.monthly_price(b.package)
            end
          end
        }

        columns = 10 + num_of_extra_keys


        servers = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('State', :bold),
          ui.color('Type', :bold),
          ui.color('Image', :bold),
          ui.color('Flavor', :bold),
          ui.color('IPs', :bold),
          ui.color('      RAM', :bold),
          ui.color('    Disk', :bold),
          ui.color('Price $/Month')
        ]

        servers << ui.color('Compute Node', :bold) if show?(:compute_node)
        servers << ui.color('Tags', :bold) if show?(:tags)

        total_monthly_price = 0

        prev_compute_node = nil # only needed if sorting by compute_node
        self.connection.servers.sort(&sort_by(sort_matrix, sort_field)).each do |s|

          compute_node = s.compute_node
          columns.times { servers << "" } if sort_field == :compute_node && prev_compute_node && prev_compute_node != compute_node
          prev_compute_node = compute_node

          servers << s.id.to_s
          servers << s.name

          servers << case s.state
                       when 'running'
                         ui.color(s.state, :green)
                       when 'stopping', 'provisioning'
                         ui.color(s.state, :yellow)
                       when 'stopped'
                         ui.color(s.state, :red)
                       else
                         ui.color('unknown', :red)
                     end

          flavor = s.package || 'unknown'

          servers << s.type
          servers << s.dataset
          servers << flavor
          servers << s.ips.join(",")
          servers << "#{sprintf "%6.2f", s.memory/1024.0} GB"
          servers << "#{sprintf "%5.0f", s.disk/1024} GB"
          servers << pricing.format_monthly_price(flavor, PRICE_COLUMN_WIDTH)

          servers << compute_node if show?(:compute_node)
          servers << s.tags.map { |k, v| "#{k}:#{v}" }.join(' ') if (show?(:tags) && (s.tags rescue nil))

          total_monthly_price += pricing.monthly_price(flavor)
        end

        add_total_price(servers, total_monthly_price)

        puts ui.list(servers, :uneven_columns_across, columns)
      rescue => e
        output_error(e)
      end

      def add_total_price(servers, total_monthly_price)
        8.times { servers << "" }
        servers << "   Total"
        servers << pricing.format_price(total_monthly_price, PRICE_COLUMN_WIDTH)
      end

      def show?(key)
        (Chef::Config[:knife][:show] || []).include?(key)
      end

      def num_of_extra_keys
        ADDITIONAL_FIELDS.select{|k| show?(k)}.size
      end

      def sort_field
        Chef::Config[:knife][:sort] || :name
      end

      def sort_by(matrix, field)
        matrix[field.to_sym] || matrix[:name]
      end

    end
  end
end
