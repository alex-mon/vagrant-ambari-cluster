# A recursive type for adding a variable amount of slave hostnames to
# the hosts file
define hosts::addnodes(
  $count,
  $base_ip,
  $base_name,
  $domain_subfix,
  ) {

  $end_ip_digit = 20 + $count

  host { "${base_name}${count}${domain_subfix}":
    ip            => "${base_ip}${end_ip_digit}",
  }

  $next = inline_template('<%= @count.to_i - 1 %>')
  if $next != '0' {
    addnodes { "add ${base_name}${next}${domain_subfix}":
      count         => $next,
      base_ip       => $base_ip,
      base_name     => $base_name,
      domain_subfix => $domain_subfix,
    }
  }
}
