###############################################################################
# GIT ALIASES: 
###############################################################################
### Git shortcuts
  # (G)it (A)dd
  alias ga="git add"
  # (G)it (S)tatus
  alias gs="git status --untracked-files --short --branch --ignore-submodules"
  # (G)it (B)ranch
  alias gb="git branch -vv"

###############################################################################
  # (G)it (D)iff
  # https://stackoverflow.com/a/1587952/622276
  # http://365git.tumblr.com/post/474079664/whats-the-difference-part-1
  # http://365git.tumblr.com/post/472624933/the-four-buckets-how-git-considers-content
  # http://365git.tumblr.com/post/3464927214/getting-a-diff-between-the-working-tree-and-other
  # diff Staged <--> Working
  alias gd="git diff -v --ignore-all-space"
  # diff HEAD <--> Staged
  alias gdc="git diff -v --ignore-all-space --cached"
  alias gds="git diff -v --ignore-all-space --staged"
  # diff HEAD <--> Working
  alias gdh="git diff -v --ignore-all-space HEAD"
  
###############################################################################
  # (G)it (C)ommit
  alias gc="git commit -v"
  alias gca="git commit -v -a"
  
gacp() {
  if [[ $# < 2 ]]; then
    echo "$FUNCNAME - Shorthand for: git add \$add_dirs && git commit -m \$commit_message && git push [\$push_args]"
    echo "USAGE: $FUNCNAME add_dirs commit_message [push_args...]"
    return 0
  else
    add_dir="$1"; shift
    commit_message="$1"; shift  
  fi
  git add "$add_dir" && git commit -m "$commit_message" && git push $@
}

gcp() {
  if [[ $# < 1 ]]; then
    echo "$FUNCNAME - Shorthand for: git add . && git commit -m \$commit_message && git push [\$push_args]"
    echo "USAGE: $FUNCNAME commit_message [push_args...]"
    return 0
  else
    commit_message="$1"; shift  
  fi
  git add . && git commit -m "$commit_message" && git push $@
}
  
###############################################################################
  # (G)it (M)aster
  alias gm=" git checkout master -f; git fetch -v --all --prune; git fetch --tags; git pull -v --all"
  alias gu=" git checkout $1 -f; git fetch -v --all --tags --prune; git pull -v --all"

###############################################################################
  # (G)it Pu(L)
  alias gl="git pull -v"
  alias gL="git pull -v --all"
  
###############################################################################
  # (G)it (P)ush
  alias gp="git push"
  alias gP="git push; git push --tags"
  alias gphm="git push heroku master"
  
###############################################################################
  # (G)it (F)etch
  alias gf="git fetch --prune --all"
  alias gF="git fetch --prune --all; git fetch --tags --prune --all"
  
###############################################################################
  # (G)it (T)ree see gitconfig for full details of git tree alias
  alias gt="git tree"
  # (G)it (G)raph, same as git tree above but backup option if not defined in git config
  #alias gl="git log --pretty=format:\"%C(bold blue)%h%x09%C(bold green)[%ad] %C(auto)%d%n%C(dim white)%an - %C(reset)%x20%s\" --graph --full-history --all --date=relative" 
  alias gg="git log --pretty=format:\"%C(bold blue)%h%x09%C(bold green)[%ad] %C(auto)%d%n%C(dim white)%an - %C(reset)%x20%s\" --graph --full-history --date=relative" 

