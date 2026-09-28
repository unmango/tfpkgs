{
  lib,
  writeShellApplication,
  terraform-backend-git,
}:

# Wraps a terraform or opentofu CLI so every invocation runs under
# terraform-backend-git's wrapper mode, storing state in a Git repository.
#
# Settings left null fall through to TF_BACKEND_GIT_* environment variables
# or a terraform-backend-git.hcl file at runtime.
{
  # terraform, opentofu, or either with `.withPlugins (...)`.
  terraform,
  # Name of the wrapped binary, "terraform" or "tofu".
  name ? terraform.meta.mainProgram or (lib.getName terraform),
  repository ? null,
  ref ? null,
  state ? null,
  amend ? false,
  address ? null,
  # Flags placed before the `git` storage subcommand.
  extraBackendArgs ? [ ],
  # Flags placed after the `git` storage subcommand.
  extraGitArgs ? [ ],
}:

let
  backendFlags = lib.cli.toCommandLineShellGNU { } { inherit address; };
  gitFlags = lib.cli.toCommandLineShellGNU { } {
    inherit
      repository
      ref
      state
      amend
      ;
  };
in
writeShellApplication {
  inherit name;

  runtimeEnv.TF_BACKEND_GIT_WRAPPER_TF_BIN = lib.getExe' terraform name;

  # `--` stops the wrapper's flag parsing so arguments such as `-chdir=` and
  # `-version` reach the CLI.
  text = ''
    exec ${lib.getExe terraform-backend-git} \
      ${backendFlags} ${lib.escapeShellArgs extraBackendArgs} \
      git ${gitFlags} ${lib.escapeShellArgs extraGitArgs} \
      terraform -- "$@"
  '';

  passthru = { inherit terraform; };

  meta = (terraform.meta or { }) // {
    mainProgram = name;
  };
}
