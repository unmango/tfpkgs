{
  lib,
  inputs,
  go,
  stdenv,
  runCommandLocal,
}:

# Upstream generates the provider's Go source from a pfrest OpenAPI spec at
# build time, so there is nothing to fetch and hand to buildTerraformProvider.
# Its flake output is relocated into the plugin layout instead.
let
  upstream = inputs.terraform-provider-pfsense.packages.${stdenv.hostPlatform.system}.default;

  registry = "registry.terraform.io";
  namespace = "unstoppablemango";
  name = "pfsense";
  providerSourceAddress = "${registry}/${namespace}/${name}";
  inherit (upstream) version;
in
runCommandLocal "terraform-provider-${name}-${version}"
  {
    passthru = {
      inherit upstream;
      provider-source-address = providerSourceAddress;
    };

    meta = upstream.meta or { } // {
      description = "Terraform provider for pfSense using pfrest";
      homepage = "https://github.com/UnstoppableMango/terraform-provider-pfsense";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
    };
  }
  ''
    dir=$out/libexec/terraform-providers/${providerSourceAddress}/${version}/${go.GOOS}_${go.GOARCH}
    mkdir -p "$dir"
    cp ${upstream}/bin/terraform-provider-${name} "$dir/terraform-provider-${name}_v${version}"
  ''
