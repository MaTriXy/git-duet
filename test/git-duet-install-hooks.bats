#!/usr/bin/env bats

load test_helper

@test "writes the pre-commit hook to the pre-commit hook file" {
  run git duet-install-hook -q pre-commit
  assert_success
  [ -f .git/hooks/pre-commit ]
}

@test "writes the prepare-commit-msg hook to the prepare-commit-msg hook file" {
  run git duet-install-hook -q prepare-commit-msg
  assert_success
  [ -f .git/hooks/prepare-commit-msg ]
}

@test "writes the post-commit hook to the post-commit hook file" {
  git duet-install-hook -q post-commit
  [ -f .git/hooks/post-commit ]
}

@test "makes the pre-commit hook executable" {
  run git duet-install-hook -q pre-commit
  assert_success
  [ -x .git/hooks/pre-commit ]
}

@test "does not overwrite existing pre-commit hook file with other contents" {
  echo "Some content" > .git/hooks/pre-commit
  local EXPECTED_HELP_MESSAGE=$(cat << EOM
It seems you already have a "pre-commit" hook.
To enable the git-duet hook, please append:

  exec git duet-pre-commit "\$@"

to your $PWD/.git/hooks/pre-commit file.
EOM
)
  run git duet-install-hook -q pre-commit
  assert_output "$EXPECTED_HELP_MESSAGE"
  assert_failure
}

@test "does not overwrite existing prepare-commit-msg hook file with other contents" {
  echo "Some content" > .git/hooks/prepare-commit-msg
  local EXPECTED_HELP_MESSAGE=$(cat << EOM
It seems you already have a "prepare-commit-msg" hook.
To enable the git-duet hook, please append:

  exec git duet-prepare-commit-msg "\$@"

to your $PWD/.git/hooks/prepare-commit-msg file.
EOM
)
  run git duet-install-hook -q prepare-commit-msg
  assert_output "$EXPECTED_HELP_MESSAGE"
  assert_failure
}

@test "does not overwrite existing post-commit hook file with other contents" {
  echo "Some content" > .git/hooks/post-commit
  local EXPECTED_HELP_MESSAGE=$(cat << EOM
It seems you already have a "post-commit" hook.
To enable the git-duet hook, please append:

  exec git duet-post-commit "\$@"

to your $PWD/.git/hooks/post-commit file.
EOM
)
  run git duet-install-hook -q post-commit
  assert_output "$EXPECTED_HELP_MESSAGE"
  assert_failure
}

@test "does not fail when pre-commit-msg contains the correct command" {
  echo "Some content" > .git/hooks/pre-commit
  echo 'exec git duet-pre-commit "$@"' >> .git/hooks/pre-commit
  run git duet-install-hook -q pre-commit
  assert_success
}

@test "does not fail when prepare-commit-msg contains the correct command" {
  echo "Some content" > .git/hooks/prepare-commit-msg
  echo 'exec git duet-prepare-commit-msg "$@"' >> .git/hooks/prepare-commit-msg
  run git duet-install-hook -q prepare-commit-msg
  assert_success
}

@test "does not fail when post-commit-msg contains the correct command" {
  echo "Some content" > .git/hooks/post-commit
  echo 'exec git duet-post-commit "$@"' >> .git/hooks/post-commit
  run git duet-install-hook -q post-commit
  assert_success
}

@test "overwrites existing prepare-commit-msg hook file with empty contents" {
  touch .git/hooks/prepare-commit-msg
  run git duet-install-hook -q prepare-commit-msg
  assert_success
}

@test "overwrites existing post-commit hook file with empty contents" {
  touch .git/hooks/post-commit
  run git duet-install-hook -q post-commit
  assert_success
}

@test "does not write anything if prepare-commit-msg hook file with desired content already exists" {
  echo '#!/usr/bin/env bash
exec git duet-prepare-commit-msg "$@"' > .git/hooks/prepare-commit-msg
  run git duet-install-hook -q prepare-commit-msg
  assert_success
}

@test "does not write anything if post-commit hook file with desired content already exists" {
  echo '#!/usr/bin/env bash
exec git duet-post-commit "$@"' > .git/hooks/post-commit
  run git duet-install-hook -q post-commit
  assert_success
}

@test "requires hook file as argument" {
  run git duet-install-hook -q notAHookFile
  assert_failure
  assert_line "Usage: git-duet-install-hook [-hq] { pre-commit | prepare-commit-msg | post-commit }"
}

@test "writes global prepare-commit-msg hook file if GIT_DUET_GLOBAL is set" {
  GIT_DUET_GLOBAL=1 git duet-install-hook -q prepare-commit-msg
  assert_success
  [ -f $HOME/.git-template/hooks/prepare-commit-msg ]
}

@test "writes global pre-commit hook file if GIT_DUET_GLOBAL is set" {
  GIT_DUET_GLOBAL=1 git duet-install-hook -q pre-commit
  assert_success
  [ -f $HOME/.git-template/hooks/pre-commit ]
}

@test "writes global post-commit hook file if GIT_DUET_GLOBAL is set" {
  GIT_DUET_GLOBAL=1 git duet-install-hook -q post-commit
  assert_success
  [ -f $HOME/.git-template/hooks/post-commit ]
}

@test "writes global prepare-commit-msg hook file if GIT_DUET_GLOBAL is set respecting current init.templatedir" {
  git config --global init.templatedir .
  GIT_DUET_GLOBAL=1 git duet-install-hook -q prepare-commit-msg
  assert_success
  [ -f ./hooks/prepare-commit-msg ]
}

@test "writes global post-commit hook file if GIT_DUET_GLOBAL is set respecting current init.templatedir" {
  git config --global init.templatedir .
  GIT_DUET_GLOBAL=1 git duet-install-hook -q post-commit
  assert_success
  [ -f ./hooks/post-commit ]
}
