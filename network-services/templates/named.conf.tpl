acl internal {
  {{- range $index, $subnet := .acl }}
  {{ $subnet }};
  {{- end }}
};

options {
  forwarders {
    {{- range $index, $ip := .forwarders }}
    {{ $ip }};
    {{- end }}
  };
  allow-query { internal; };
};

key "tsig-key" {
    algorithm hmac-sha256;
    secret "{{ .key }}";
};

zone "{{ .zone }}" IN {
  type master;
  file "/etc/bind/{{ .zonefile }}.zone";
  allow-policy { grant tsig-key zonesub any; };
};
