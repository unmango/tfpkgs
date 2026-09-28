{
  lib,
  makeBinaryWrapper,
  runCommand,
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
  amend ? null,
  address ? null,
  # Flags placed before the `git` storage subcommand.
  extraBackendArgs ? [ ],
  # Flags placed after the `git` storage subcommand.
  extraGitArgs ? [ ],
}:

let
  args =
    lib.cli.toCommandLineGNU { } { inherit address; }
    ++ extraBackendArgs
    ++ [ "git" ]
    ++ lib.cli.toCommandLineGNU { explicitBool = true; } {
      inherit
        repository
        ref
        state
        amend
        ;
    }
    ++ extraGitArgs
    # `--` stops the wrapper's flag parsing so arguments such as `-version`
    # reach the CLI.
    ++ [
      "terraform"
      "--"
    ];
in
runCommand name
  {
    nativeBuildInputs = [ makeBinaryWrapper ];

    passthru = { inherit terraform; };

    meta = (terraform.meta or { }) // {
      mainProgram = name;
    };
  }
  ''
    makeWrapper ${lib.getExe terraform-backend-git} $out/bin/${name} \
      --set TF_BACKEND_GIT_WRAPPER_TF_BIN ${lib.getExe' terraform name} \
      ${lib.concatMapStringsSep " " (arg: "--add-flag ${lib.escapeShellArg arg}") args}
  ''
