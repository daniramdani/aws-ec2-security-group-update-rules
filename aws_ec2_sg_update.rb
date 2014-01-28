require 'rubygems'
require 'aws-sdk'

AWS.config(:access_key_id => YOUR_ACCESS_KEY,
           :secret_access_key => YOUR_SECRET_KEY)

ec2 = AWS::EC2.new
group, old_source, new_source = ARGV
groups = ec2.security_groups.filter('group-name', group)

groups.first.ip_permissions.each do |permission|
  unless permission.ip_ranges.include? old_source 
    new_sources = permission.ip_ranges.map { |source| source == old_source ? new_source : source }

    new_rule = AWS::EC2::SecurityGroup::IpPermission.new(
      permission.port_range,
      permission.security_group, {:ip_ranges => new_sources, :groups => permission.groups},
      permission.protocol
    )

    permission.revoke
    new_rule.authorize
  end
end

puts "--- Successfully Updated. ---"
