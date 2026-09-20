{
  runCommand,
  lib,
  opentofu,
}:
runCommand "terraform" { } ''
  mkdir -p $out/bin
  ln -s ${lib.getExe opentofu} $out/bin/terraform
''
