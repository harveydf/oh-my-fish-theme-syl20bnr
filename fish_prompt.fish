# name: syl20bnr

# ----------------------------------------------------------------------------
# Utils
# ----------------------------------------------------------------------------

set -g __syl20bnr_display_rprompt 1

function toggle_right_prompt -d "Toggle the right prompt of the syl20bnr theme"
  if test $__syl20bnr_display_rprompt -eq 0
    echo "enable right prompt"
    set __syl20bnr_display_rprompt 1
  else
    echo "disable right prompt"
    set __syl20bnr_display_rprompt 0
  end
end

function __syl20bnr_git_branch_name
  echo (command git symbolic-ref HEAD ^/dev/null | sed -e 's|^refs/heads/||')
end

function __syl20bnr_is_git_dirty
  echo (command git status -s --ignore-submodules=dirty ^/dev/null)
end

function __syl20bnr_is_git_ahead
  echo (command git status -s -b ^/dev/null | grep ahead)
end

# ----------------------------------------------------------------------------
# Aliases
# ----------------------------------------------------------------------------

alias trp toggle_right_prompt

# ----------------------------------------------------------------------------
# Prompts
# ----------------------------------------------------------------------------

function fish_prompt -d "Write out the left prompt of the syl20bnr theme"
  set -l last_status $status

  # Init colors

  set -l colcyan   (set_color cyan)
  set -l colbcyan  (set_color -o cyan)
  set -l colgreen  (set_color green)
  set -l colbgreen (set_color -o green)
  set -l colnormal (set_color normal)
  set -l colred    (set_color red)
  set -l colbred   (set_color -o red)
  set -l colwhite  (set_color white)
  set -l colbwhite  (set_color -o white)
  
  # Segments
  
  # git
  # If inside a git repo then the pwd segment is replaced by the git
  # information.
  # The git segment format is X:Y@Z where:
  #   X is git:
  #   Y is the current branch
  #   Z is the name of the repo
  # Dirtyness is indicated by a little dot after the branch name.
  # Unpushed commits are indicated with up arrows
  set -l ps_git ""
  set -l git_branch_name (__syl20bnr_git_branch_name)
  if test -n "$git_branch_name"
    set -l git_info ""
    if test -n (__syl20bnr_is_git_ahead)
      set git_info $colbgreen"↑↑↑"
    end
    if test -n (__syl20bnr_is_git_dirty)
      set git_info $git_info$colbred"·"
    end
    set ps_git $colbwhite"git:"$colbcyan$git_branch_name$git_info$colnormal"@"$colbred(basename (prompt_pwd))
  end

  # pwd
  # The pwd segment format is X:Y(Z) where:
  #   X is either home: or /:
  #   Y is the current working path basename (name of the current directory)
  #   Z is the depth of the path starting from X
  # If the pwd is home then the prompt format is simplified to home:~ without
  # the depth.
  set -l ps_pwd ""
  if test -z "$ps_git"
    set -l depth (echo (pwd) | cut -d "/" --output-delimiter=" " -f 1- | wc -w)
    set -l in_home (echo (pwd) | grep ~)
    if test -n "$in_home"
      set ps_pwd $colbwhite"home:"
    else
      set ps_pwd $colbwhite"/:"
    end
    set ps_pwd $ps_pwd$colgreen(basename (prompt_pwd))
    if test (echo (pwd)) != ~
      if test -n "$in_home"
        set depth (math $depth - 2)
      end
      set ps_pwd $ps_pwd$colnormal"("$depth")"
    end
  end
      
  # vi mode
  # If vi_mode plugin is activated then print the vi mode in the prompt.
  set -l ps_vi ""
  if test -n "$vi_mode"
    set ps_vi $colnormal"["$vi_mode$colnormal"]"
  end

  # end of prompt
  # The color of the end of the prompt depends on the $status value of the
  # last executed command. It is green or red depending on the last command
  # success or failure respectively.
  # Since I often use ranger and use its 'shift+s' key binding to bring a shell
  # session, there is discreet indicator when the parent process on the current
  # shell pid is a ranger process. In this case the end of prompte is written
  # twice.
  # With this indicator I can quickly remember that I can "ctrl+d" to end the
  # the current shell process and get back to the ranger process.
  set -l ps_end ">"
  # indicator for ranger parent process
  set ranger ""
  if pstree -p -l | grep "fish("(echo %self)")" | grep 'ranger([0-9]*)' > /dev/null
    set ps_end $ps_end$ps_end
  end
  # last status give the color of the right arrows at the end of the prompt
  if test $last_status -ne 0 
    set ps_end $colnormal$colbred$ps_end
  else
    set ps_end $colnormal$colgreen$ps_end
  end

  # Left Prompt

  echo -n -s $ps_git $ps_pwd $ps_vi $ps_git_dirty $ps_end ' '
end


function fish_right_prompt -d "Write out the right prompt of the syl20bnr theme"
  set -l colnormal (set_color normal)

  # Segments

  # The where segment format is X@Y where:
  #   X is the username
  #   Y is the hostname
  set -l ps_where $colnormal(whoami)@(hostname|cut -d . -f 1)
  
  # Right Prompt

  if test $__syl20bnr_display_rprompt -eq 1
    echo -n -s $ps_where
  end
end